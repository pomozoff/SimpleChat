//
//  ChatTableViewController.h
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;

#import "ChatManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, Presnter>

@property (nonatomic, strong) id <ChatDataSource> chatDataSource;

@end

NS_ASSUME_NONNULL_END
