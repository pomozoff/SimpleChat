//
//  ChatTableViewCell.h
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;

#import "ChatMessage.h"
#import "MessageController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatTableViewCell : UITableViewCell

@property (nonatomic, strong) id <ChatMessage> chatMessage;
@property (nonatomic, strong) id <MessageController> messageContoller;
@property (nonatomic, assign) BOOL hasTail;

@end

NS_ASSUME_NONNULL_END
