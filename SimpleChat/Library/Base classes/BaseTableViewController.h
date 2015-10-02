//
//  BaseTableViewController.h
//  Accounts List
//
//  Created by Anton Pomozov on 24.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;

#import "ChatManager.h"

@interface BaseTableViewController : UIViewController <ChatPresenter>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
