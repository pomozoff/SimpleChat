//
//  RemoteDataSource.h
//  SimpleChat
//
//  Created by Anton Pomozov on 02.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;

#import "ChatMessage.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^FetchCompletionHandler)(BOOL succeeded, NSArray <id <ChatMessage>> *messages, NSError * _Nullable error);

@protocol RemoteDataSource <NSObject>

- (void)fetchMessagesWithCompletion:(FetchCompletionHandler)handler;
- (void)addChatMessage:(id <ChatMessage>)message andCompletion:(CompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END
