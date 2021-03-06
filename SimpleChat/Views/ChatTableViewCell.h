//
//  ChatTableViewCell.h
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;

#import "ChatMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatTableViewCell : UITableViewCell

@property (nonatomic, strong, nullable) id <ChatMessage> chatMessage;
@property (nonatomic, assign) BOOL hasTail;
@property (nonatomic, assign) CGSize locationPreviewSize;

- (void)updateImage:(nullable UIImage *)image;
- (void)showProgress;
- (void)hideProgress;
//- (void)updateLocation;

@end

NS_ASSUME_NONNULL_END
