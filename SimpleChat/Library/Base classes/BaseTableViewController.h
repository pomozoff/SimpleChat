//
//  BaseTableViewController.h
//  Accounts List
//
//  Created by Anton Pomozov on 24.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;

#import "Common.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ScrollDirectionUp = 1,
    ScrollDirectionDown = 2,
} ScrollDirection;

@interface BaseTableViewController : UIViewController <DataPresenter>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong, nullable) NSIndexPath *scrollToIndexPath;

- (void)scrollTable:(ScrollDirection)scrollDirection;

@end

NS_ASSUME_NONNULL_END
