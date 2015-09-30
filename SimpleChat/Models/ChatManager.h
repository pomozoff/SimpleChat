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

@protocol Presnter <NSObject>

@property (nonatomic, strong) UIImage *backgroundImage;

@end

@protocol ChatDataSource <NSObject>

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (id <ChatMessage>)chatMessageAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isLastMessage:(NSIndexPath *)indexPath;

@end

@interface ChatManager : NSObject <ChatDataSource>

@end

NS_ASSUME_NONNULL_END
