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

@property (nonatomic, strong) PFQuery *queryLocal;
@property (nonatomic, strong) PFQuery *queryRemote;
@property (nonatomic, strong) NSMutableDictionary *images;

@end

@implementation ParseDataSource

#pragma mark - Constants

static NSString *kSortKey = @"createdAt";
static NSInteger const kFetchedLocalObjectsLimit = 20;
static NSInteger const kFetchedRemoteObjectsLimit = 4;

#pragma mark - Properties

- (PFQuery *)queryLocal {
    if (!_queryLocal) {
        _queryLocal = [PFQuery queryWithClassName:NSStringFromClass([ChatMessage class])];
        _queryLocal.limit = kFetchedLocalObjectsLimit;
        _queryLocal.skip = 0;
        [_queryLocal orderByDescending:kSortKey];
        [_queryLocal fromLocalDatastore];
    }
    return _queryLocal;
}
- (PFQuery *)queryRemote {
    if (!_queryRemote) {
        _queryRemote = [PFQuery queryWithClassName:NSStringFromClass([ChatMessage class])];
        _queryRemote.limit = kFetchedRemoteObjectsLimit;
        _queryRemote.skip = 0;
        [_queryRemote orderByDescending:kSortKey];
    }
    return _queryRemote;
}
- (NSMutableDictionary *)images {
    if (!_images) {
        _images = [NSMutableDictionary dictionary];
    }
    return _images;
}

#pragma mark - Remote data source

- (void)resetToNewestMessageWithCompletion:(CompletionHandler)handler {
    self.queryRemote.skip = 0;
    handler(YES, nil);
}
- (void)fetchMoreMessagesWithCompletion:(FetchCompletionHandler)handler {
    [self fetchMessagesFromQuery:self.queryRemote withCompletion:handler];
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

- (nonnull NSArray <id <ChatMessage>> *)messagesFromObjects:(nonnull NSArray <PFObject *> *)objects {
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
- (void)saveImage:(nonnull UIImage *)image toParseObject:(nonnull PFObject *)object {
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            object[@"image"] = imageFile;
            [object saveInBackgroundWithBlock:^(BOOL innerSucceeded, NSError *innerError) {
                if (!innerError) {
                    NSLog(@"The image was successfuly saved to the parse object");
                } else {
                    NSLog(@"Failed to save the image to the parse object: %@ %@", innerError, innerError.userInfo);
                }
            }];
        } else {
            NSLog(@"Failed to upload the image to Parse: %@ %@", error, error.userInfo);
        }
    }];
}
- (void)fetchMessagesFromQuery:(nonnull PFQuery *)query withCompletion:(FetchCompletionHandler)handler {
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            query.skip += kFetchedRemoteObjectsLimit;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray <id <ChatMessage>> *messages = [weakSelf messagesFromObjects:objects];
                handler(!error, messages, error);
            });
        } else {
            NSLog(@"Error: %@ %@", error, error.userInfo);
        }
    }];
}

@end
