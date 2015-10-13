//
//  ChatManager.h
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;

#import "ChatMessage.h"
#import "MessagesDataSource.h"
#import "LocationDataSource.h"
#import "Common.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ChatDataSource <NSObject>

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (id <ChatMessage>)chatMessageAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isLastMessage:(NSIndexPath *)indexPath;
- (void)resetToNewestMessageWithCompletion:(CompletionHandler)handler;
- (void)fetchMoreMessagesWithCompletion:(CompletionHandler)handler;

@end

@protocol ChatHandler <NSObject>

- (void)sendTextMessage:(NSString *)text withCompletion:(CompletionHandler)handler;
- (void)sendTextMessage:(nullable NSString *)text andImage:(UIImage *)image withCompletion:(CompletionHandler)handler;
- (void)sendTextMessage:(NSString *)text andLocation:(CLLocationCoordinate2D)coordinate withCompletion:(CompletionHandler)handler;
- (void)freeMemory;

@end

@protocol MessageController <NSObject>

- (void)fetchImageForChatMessage:(id <ChatMessage>)chatMessage withCompletion:(FetchImageCompletionHandler)handler;
- (void)makeImageLocationForChatMessage:(id <ChatMessage>)chatMessage forSize:(CGSize)size withCompletion:(FetchImageCompletionHandler)handler;

@end

@interface ChatManager : NSObject <ChatDataSource, ChatHandler, MessageController, LocationDataSource>

@property (nonatomic, strong) id <DataPresenter> dataPresenter;
@property (nonatomic, strong) id <MessagesDataSource> messagesDataSource;
@property (nonatomic, strong) id <LocationDataSource> locationDataSource;

@end

NS_ASSUME_NONNULL_END
