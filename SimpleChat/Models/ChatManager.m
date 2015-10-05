//
//  ChatManager.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatManager.h"

@interface ChatManager ()

@property (nonatomic, strong) NSMutableArray <id <ChatMessage>> *messages;

@end

@implementation ChatManager

#pragma mark - Properties

- (NSMutableArray <id <ChatMessage>> *)messages {
    if (!_messages) {
        _messages = [NSMutableArray arrayWithCapacity:1];
    }
    return _messages;
}

#pragma mark - Chat data source

- (NSInteger)numberOfSections {
    return 1;
}
- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    NSAssert([NSThread isMainThread], @"Not in main thread!");
    return self.messages.count;
}
- (id <ChatMessage>)chatMessageAtIndexPath:(NSIndexPath *)indexPath {
    return self.messages[indexPath.row];
}
- (BOOL)isLastMessage:(NSIndexPath *)indexPath {
    return indexPath.row == self.messages.count - 1;
}
- (void)fetchMessagesWithCompletion:(CompletionHandler)handler {
    [self.remoteDataSource fetchLastMessagesWithCompletion:^(BOOL succeeded, NSArray <id <ChatMessage>> *messages, NSError * _Nullable error) {
        if (succeeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self mergeMessages:messages];
            });
        } else {
            NSLog(@"Failed to fetch messages: %@ %@", error, error.userInfo);
        }
        handler(succeeded, error);
    }];
}

#pragma mark - Chat handler

- (void)sendTextMessage:(NSString *)text withCompletion:(CompletionHandler)handler {
    id <ChatMessage> chatMessage = [self addNewMessageWithText:text];
    [self processNewMessage:chatMessage withCompletion:handler];
}
- (void)sendTextMessage:(nullable NSString *)text andImage:(UIImage *)image withCompletion:(CompletionHandler)handler {
    id <ChatMessage> chatMessage = [self addNewMessageWithText:text];
    chatMessage.hasImage = YES;
    chatMessage.image = image;
    [self processNewMessage:chatMessage withCompletion:handler];
}
- (void)sendTextMessage:(NSString *)text andCurrentLocationWithCompletion:(CompletionHandler)handler {
    
}

#pragma mark - Message controller

- (void)fetchImageForChatMessage:(id <ChatMessage>)chatMessage withCompletion:(FetchImageCompletionHandler)handler {
    [self.remoteDataSource fetchImageForChatMessage:chatMessage withCompletion:handler];
}

#pragma mark - Private

- (void)mergeMessages:(nonnull NSArray <id <ChatMessage>> *)newMessages {
    for (id <ChatMessage> chatMessage in newMessages) {
        [self.messages insertObject:chatMessage atIndex:0];
    }
}
- (id <ChatMessage>)addNewMessageWithText:(nullable NSString *)text {
    NSAssert([NSThread isMainThread], @"Not in main thread!");
    id <ChatMessage> chatMessage = [[ChatMessage alloc] initWithText:text];
    [self.messages addObject:chatMessage];
    
    return chatMessage;
}
- (void)processNewMessage:(nonnull id <ChatMessage>)chatMessage withCompletion:(nonnull CompletionHandler)handler {
    [self.remoteDataSource addChatMessage:chatMessage andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        handler(succeeded, error);
    }];

    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
    [self.chatPresenter willChangeContent];
    [self.chatPresenter didChangeObject:chatMessage
                            atIndexPath:newIndexPath
                          forChangeType:TableChangeInsert
                           newIndexPath:newIndexPath];
    [self.chatPresenter didChangeContent];
}

@end
