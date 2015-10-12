//
//  ChatTableViewController.h
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;

#import "ChatManager.h"
#import "BaseTableViewController.h"
#import "ImageRouter.h"
#import "cameraRouter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatTableViewController : BaseTableViewController <UITableViewDataSource, UITableViewDelegate, ImageProcessor, CameraProcessor>

@property (nonatomic, strong) id <ChatDataSource> chatDataSource;
@property (nonatomic, strong) id <ChatHandler> chatHandler;
@property (nonatomic, strong) id <MessageController> messageContoller;

@end

NS_ASSUME_NONNULL_END
