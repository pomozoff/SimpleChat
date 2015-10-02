//
//  ChatManager.h
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;

#import "ChatMessage.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CompletionHandler)(BOOL succeed, NSError * _Nullable error);

@protocol ChatPresnter <NSObject>

@property (nonatomic, strong) UIImage *backgroundImage;

@end

@protocol ChatDataSource <NSObject>

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (id <ChatMessage>)chatMessageAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isLastMessage:(NSIndexPath *)indexPath;

@end

@protocol ChatHandler <NSObject>

- (void)sendMessage:(NSString *)message withCompletion:(CompletionHandler)handler;
- (void)sendCurrentLocationWithCompletion:(CompletionHandler)handler;
- (void)sendImage:(UIImage *)image withCompletion:(CompletionHandler)handler;

@end

@interface ChatManager : NSObject <ChatDataSource, ChatHandler>

@end

NS_ASSUME_NONNULL_END
