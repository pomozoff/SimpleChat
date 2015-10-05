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

- (void)fetchLastMessagesWithCompletion:(FetchCompletionHandler)handler;
- (void)fetchNextMessagesWithCompletion:(FetchCompletionHandler)handler;
- (void)addChatMessage:(id <ChatMessage>)chatMessage andCompletion:(CompletionHandler)handler;
- (void)fetchImageForChatMessage:(id <ChatMessage>)chatMessage withCompletion:(FetchImageCompletionHandler _Nonnull)handler;

@end

NS_ASSUME_NONNULL_END
