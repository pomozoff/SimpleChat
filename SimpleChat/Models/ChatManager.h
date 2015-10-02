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
    TableChangeInsert = 1,
    TableChangeDelete = 2,
    TableChangeMove   = 3,
    TableChangeUpdate = 4
} TableChangeType;

@protocol ChatPresenter <NSObject>

@property (nonatomic, strong) NSBlockOperation *updateOperation;

- (void)reloadData;
- (void)willChangeContent;
- (void)didChangeSectionatIndex:(NSUInteger)sectionIndex
                  forChangeType:(TableChangeType)type;
- (void)didChangeObject:(id)anObject
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(TableChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath;
- (void)didChangeContent;

@end

@protocol ChatDataSource <NSObject>

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (id <ChatMessage>)chatMessageAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isLastMessage:(NSIndexPath *)indexPath;
- (void)reloadChatListWithCompletion:(CompletionHandler)handler;

@end

@protocol ChatHandler <NSObject>

- (void)sendTextMessage:(NSString *)text withCompletion:(CompletionHandler)handler;
- (void)sendCurrentLocationWithCompletion:(CompletionHandler)handler;
- (void)sendImage:(UIImage *)image withCompletion:(CompletionHandler)handler;

@end

@interface ChatManager : NSObject <ChatDataSource, ChatHandler>

@property (nonatomic, strong) id <ChatPresenter> chatPresenter;
@property (nonatomic, strong) id <RemoteDataSource> remoteDataSource;

@end

NS_ASSUME_NONNULL_END
