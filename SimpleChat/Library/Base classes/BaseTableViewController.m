//
//  BaseTableViewController.m
//  Accounts List
//
//  Created by Anton Pomozov on 24.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "BaseTableViewController.h"

@implementation BaseTableViewController

#pragma mark - Properties

@synthesize updateOperation = _updateOperation;

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Chat presenter

- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}
- (void)willChangeContent {
    NSAssert([NSThread isMainThread], @"Not in main thread!");
    [self.tableView beginUpdates];
    self.updateOperation = [[NSBlockOperation alloc] init];
    
    __weak UITableView *weakTableView = self.tableView;
    self.updateOperation.completionBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakTableView endUpdates];
        });
    };
}
- (void)didChangeSectionatIndex:(NSUInteger)sectionIndex
                  forChangeType:(CollectionChangeType)type
{
    __weak UITableView *weakTableView = self.tableView;
    switch(type) {
        case CollectionChangeInsert: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case CollectionChangeDelete: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case CollectionChangeMove: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                [weakTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case CollectionChangeUpdate: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        default:
            break;
    }
}
- (void)didChangeObject:(id)anObject
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(CollectionChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak UITableView *weakTableView = self.tableView;
    switch(type) {
        case CollectionChangeInsert: {
            NSAssert(self.updateOperation, @"Update operation is nil!");
            [self.updateOperation addExecutionBlock:^{
                [weakTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case CollectionChangeDelete: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView deleteRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case CollectionChangeMove: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView deleteRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                [weakTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case CollectionChangeUpdate: {
            [self.updateOperation addExecutionBlock:^{
                [weakTableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        default:
            break;
    }
}
- (void)didChangeContent {
    NSAssert([NSThread isMainThread], @"Not in main thread!");
    [self.updateOperation start];
}

@end
