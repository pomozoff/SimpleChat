//
//  MessagesDataSource.h
//  SimpleChat
//
//  Created by Anton Pomozov on 02.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#ifndef MessagesDataSource_h
#define MessagesDataSource_h

@import Foundation;

#import "ChatMessage.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^FetchMessagesCompletionHandler)(BOOL succeeded, NSArray <id <ChatMessage>> * _Nullable messages, NSError * _Nullable error);

@protocol MessagesDataSource <NSObject>

- (void)resetToNewestMessageWithCompletion:(CompletionHandler)handler;
- (void)fetchMoreMessagesWithCompletion:(FetchMessagesCompletionHandler)handler;
- (void)addChatMessage:(id <ChatMessage>)chatMessage andCompletion:(CompletionHandler)handler;
- (void)fetchImageForChatMessage:(id <ChatMessage>)chatMessage withCompletion:(FetchImageCompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END

#endif /* MessagesDataSource_h */
