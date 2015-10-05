//
//  ParseDataSource.m
//  SimpleChat
//
//  Created by Anton Pomozov on 02.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Parse;

#import "ParseDataSource.h"

typedef void (^FetchImageCompletionHandler)(UIImage * _Nullable image, NSError * _Nullable error);

@interface ParseDataSource ()

@property (nonatomic, strong) PFQuery *query;
@property (nonatomic, strong) NSMutableDictionary *images;

@end

@implementation ParseDataSource

#pragma mark - Constants

static NSString *kSortKey = @"createdAt";
static NSUInteger const kFetchedObjectsLimit = 10;

#pragma mark - Properties

- (PFQuery *)query {
    if (!_query) {
        _query = [PFQuery queryWithClassName:NSStringFromClass([ChatMessage class])];
        _query.limit = kFetchedObjectsLimit;
        _query.skip = 0;
    }
    return _query;
}
- (NSMutableDictionary *)images {
    if (!_images) {
        _images = [NSMutableDictionary dictionary];
    }
    return _images;
}

#pragma mark - Remote data source

- (void)fetchMessagesWithCompletion:(FetchCompletionHandler)handler {
    [self.query orderByDescending:kSortKey];
    [self.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, error.userInfo);
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray <id <ChatMessage>> *messages = [self messagesFromObjects:objects];
            handler(!error, messages, error);
        });
    }];
}
- (void)fetchLastMessagesWithCompletion:(FetchCompletionHandler)handler {
    self.images = [NSMutableDictionary dictionary];
    self.query.skip = 0;
    [self fetchMessagesWithCompletion:handler];
}
- (void)fetchNextMessagesWithCompletion:(FetchCompletionHandler)handler {
    self.query.skip += kFetchedObjectsLimit;
    [self fetchMessagesWithCompletion:handler];
}
- (void)fetchImageForChatMessage:(id <ChatMessage>)chatMessage withCompletion:(FetchImageCompletionHandler)handler {
    PFFile *file = self.images[chatMessage.messageId];
    [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (!data && error) {
            NSLog(@"Failed to get image from Parse: %@ %@", error, error.userInfo);
        }
        UIImage *image = [UIImage imageWithData:data];
        chatMessage.image = image;
        handler(image, error);
    }];
    if (!file) {
        UIImage *image = [UIImage imageNamed:@"placeholder"];
        chatMessage.image = image;
        handler(image, nil);
    }
}
- (void)addChatMessage:(id <ChatMessage>)chatMessage andCompletion:(CompletionHandler)handler {
    PFObject *object = [PFObject objectWithClassName:NSStringFromClass([ChatMessage class])];
    if (chatMessage.text) {
        object[@"text"] = chatMessage.text;
    }
    object[@"hasImage"] = [NSNumber numberWithBool:chatMessage.hasImage];
    if (chatMessage.hasImage && chatMessage.image) {
        [self saveImage:chatMessage.image toParseObject:object];
    }
    object[@"hasLocation"] = [NSNumber numberWithBool:chatMessage.hasLocation];
    if (chatMessage.hasLocation) {
        object[@"latitude"] = [NSNumber numberWithDouble:chatMessage.latitude];
        object[@"longitude"] = [NSNumber numberWithDouble:chatMessage.longitude];
    }
    [object saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [object fetch];
                dispatch_async(dispatch_get_main_queue(), ^{
                    chatMessage.messageId = object.objectId;
                });
            });
        }
        handler(succeeded, error);
    }];
}

#pragma mark - Private

- (NSArray <id <ChatMessage>> *)messagesFromObjects:(nonnull NSArray <PFObject *> *)objects {
    NSMutableArray <id <ChatMessage>> *mutableMessages = [NSMutableArray arrayWithCapacity:objects.count];
    for (PFObject *object in objects) {
        ChatMessage *chatMessage = [[ChatMessage alloc] initWithText:object[@"text"]];
        chatMessage.messageId = object.objectId;
        chatMessage.hasLocation = [object[@"hasLocation"] boolValue];
        if (chatMessage.hasLocation) {
            chatMessage.latitude = [object[@"latitude"] doubleValue];
            chatMessage.longitude = [object[@"longitude"] doubleValue];
        }
        chatMessage.hasImage = [object[@"hasImage"] boolValue];
        if (chatMessage.hasImage) {
            self.images[object.objectId] = object[@"image"];
        }
        [mutableMessages addObject:chatMessage];
    }
    return [mutableMessages copy];
}
/*
- (PFObject *)objectWithId:(NSString *)objectId {
    NSError *error = nil;
    PFObject *object = [PFQuery getObjectOfClass:NSStringFromClass([ChatMessage class]) objectId:objectId error:&error];
    if (!object && error) {
        NSLog(@"Failed get object with id: %@, %@ %@", objectId, error, error.userInfo);
    }
    return object;
}
*/
- (void)saveImage:(nonnull UIImage *)image toParseObject:(nonnull PFObject *)object {
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            object[@"image"] = imageFile;
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"The image was successfuly saved to the parse object");
                } else {
                    NSLog(@"Failed to save the image to the parse object: %@ %@", error, error.userInfo);
                }
            }];
        } else {
            NSLog(@"Failed to upload the image to Parse: %@ %@", error, error.userInfo);
        }
    }];
}

@end
