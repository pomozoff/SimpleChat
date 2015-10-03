//
//  ParseDataSource.m
//  SimpleChat
//
//  Created by Anton Pomozov on 02.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Parse;

#import "ParseDataSource.h"

@interface ParseDataSource ()

@property (nonatomic, strong) PFQuery *query;

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
    self.query.limit += kFetchedObjectsLimit;
    [self fetchMessagesWithCompletion:handler];
}
- (void)fetchNextMessagesWithCompletion:(FetchCompletionHandler)handler {
    self.query.skip = 0;
    [self fetchMessagesWithCompletion:handler];
}
- (void)addChatMessage:(id <ChatMessage>)message andCompletion:(CompletionHandler)handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PFObject *objectMessage = [PFObject objectWithClassName:NSStringFromClass([ChatMessage class])];
        
        if (message.text) {
            objectMessage[@"text"] = message.text;
        }
        objectMessage[@"hasImage"] = [NSNumber numberWithBool:message.hasImage];
        if (message.hasImage && message.image) {
            [self saveImage:message.image toParseObject:objectMessage];
        }
        objectMessage[@"hasLocation"] = [NSNumber numberWithBool:message.hasLocation];
        if (message.hasLocation) {
            objectMessage[@"latitude"] = [NSNumber numberWithDouble:message.latitude];
            objectMessage[@"longitude"] = [NSNumber numberWithDouble:message.longitude];
        }
        
        [objectMessage saveEventually:^(BOOL succeeded, NSError *error) {
            handler(succeeded, error);
        }];
    });
}

#pragma mark - Private

- (NSArray <id <ChatMessage>> *)messagesFromObjects: (NSArray <PFObject *> *)objects {
    NSMutableArray <id <ChatMessage>> *mutableMessages = [NSMutableArray arrayWithCapacity:objects.count];
    for (PFObject *object in objects) {
        id <ChatMessage> chatMessage = [[ChatMessage alloc] initWithText:object[@"text"]];
        chatMessage.image = object[@"image"];
        chatMessage.latitude = [object[@"latitude"] doubleValue];
        chatMessage.longitude = [object[@"longitude"] doubleValue];
        chatMessage.hasLocation = [object[@"hasLocation"] boolValue];
        chatMessage.hasImage = [object[@"image"] boolValue];
        
        [mutableMessages addObject:chatMessage];
    }
    return [mutableMessages copy];
}
- (void)saveImage:(UIImage *)image toParseObject:(PFObject *)object {
    NSData *thumbnailData = UIImageJPEGRepresentation(image, 0.5f);
    PFFile *thumbnailImageFile = [PFFile fileWithName:@"ThumbnailImage.jpg" data:thumbnailData];
    [thumbnailImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            object[@"thumbnail"] = thumbnailImageFile;
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"The thumbnail image was successfuly saved to the parse object");
                } else {
                    NSLog(@"Failed to save the thumbnail image to the parse object: %@ %@", error, error.userInfo);
                }
            }];
        } else {
            NSLog(@"Failed to upload the thumbnail image to Parse: %@ %@", error, error.userInfo);
        }
    }];
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    PFFile *imageFile = [PFFile fileWithName:@"ThumbnailImage.jpg" data:data];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            PFObject *newImageObject = [PFObject objectWithClassName:@"ChatImage"];
            newImageObject[@"image"] = imageFile;
            newImageObject[@"chatMessage"] = object;
            [newImageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
