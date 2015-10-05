//
//  ChatManager.h
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;

#import "ChatMessage.h"
#import "RemoteDataSource.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CollectionChangeInsert = 1,
    CollectionChangeDelete = 2,
    CollectionChangeMove   = 3,
    CollectionChangeUpdate = 4
} CollectionChangeType;

@protocol ChatPresenter <NSObject>

@property (nonatomic, strong) NSBlockOperation *updateOperation;

- (void)reloadData;
- (void)willChangeContent;
- (void)didChangeSectionatIndex:(NSUInteger)sectionIndex
                  forChangeType:(CollectionChangeType)type;
- (void)didChangeObject:(id)anObject
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(CollectionChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath;
- (void)didChangeContent;

@end

@protocol ChatDataSource <NSObject>

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (id <ChatMessage>)chatMessageAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isLastMessage:(NSIndexPath *)indexPath;
- (void)fetchMessagesWithCompletion:(CompletionHandler)handler;

@end

@protocol ChatHandler <NSObject>

- (void)sendTextMessage:(NSString *)text withCompletion:(CompletionHandler)handler;
- (void)sendTextMessage:(nullable NSString *)text andImage:(UIImage *)image withCompletion:(CompletionHandler)handler;
- (void)sendTextMessage:(NSString *)text andCurrentLocationWithCompletion:(CompletionHandler)handler;

@end

@protocol MessageController <NSObject>

- (void)fetchImageForChatMessage:(id <ChatMessage>)chatMessage withCompletion:(FetchImageCompletionHandler)handler;

@end

@interface ChatManager : NSObject <ChatDataSource, ChatHandler, MessageController>

@property (nonatomic, strong) id <ChatPresenter> chatPresenter;
@property (nonatomic, strong) id <RemoteDataSource> remoteDataSource;

@end

NS_ASSUME_NONNULL_END
