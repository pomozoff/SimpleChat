//
//  BaseTableViewController.m
//  Accounts List
//
//  Created by Anton Pomozov on 24.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()

@end

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

#pragma mark - Data presenter

- (void)reloadDataInSections:(NSIndexSet *)indexSet {
    NSAssert([NSThread isMainThread], @"Not in main thread!");
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)willChangeContent {
    NSAssert([NSThread isMainThread], @"Not in main thread!");
    [self.tableView beginUpdates];
    self.updateOperation = [[NSBlockOperation alloc] init];
    
    __weak __typeof(self) weakSelf = self;
    self.updateOperation.completionBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView endUpdates];
        });
    };
}
- (void)didChangeSectionatIndex:(NSUInteger)sectionIndex
                  forChangeType:(CollectionChangeType)type
{
    __weak __typeof(self) weakSelf = self;
    switch(type) {
        case CollectionChangeInsert: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case CollectionChangeDelete: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case CollectionChangeMove: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case CollectionChangeUpdate: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
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
    __weak __typeof(self) weakSelf = self;
    switch(type) {
        case CollectionChangeInsert: {
            NSAssert(self.updateOperation, @"Update operation is nil!");
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case CollectionChangeDelete: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView deleteRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case CollectionChangeMove: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView deleteRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            break;
        }
        case CollectionChangeUpdate: {
            [self.updateOperation addExecutionBlock:^{
                [weakSelf.tableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
