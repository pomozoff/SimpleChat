//
//  BaseCollectionViewController.m
//  Accounts List
//
//  Created by Anton Pomozov on 24.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "BaseCollectionViewController.h"
#import "ChatManager.h"

@interface BaseCollectionViewController () <ChatPresenter>

@end

@implementation BaseCollectionViewController

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
        [self.collectionView reloadData];
    });
}
- (void)willChangeContent {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView beginUpdates];
        self.updateOperation = [[NSBlockOperation alloc] init];
    });
}
- (void)didChangeSectionatIndex:(NSUInteger)sectionIndex
                  forChangeType:(TableChangeType)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak UICollectionView *weakCollectionView = self.collectionView;
        switch(type) {
            case TableChangeInsert: {
                [self.updateOperation addExecutionBlock:^{
                    [weakCollectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                }];
                break;
            }
            case TableChangeDelete: {
                [self.updateOperation addExecutionBlock:^{
                    [weakCollectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                }];
                break;
            }
            case TableChangeUpdate: {
                [self.updateOperation addExecutionBlock:^{
                    [weakCollectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                }];
                break;
            }
            case TableChangeMove: {
                [self.updateOperation addExecutionBlock:^{
                    [weakCollectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                    [weakCollectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                }];
                break;
            }
            default:
                break;
        }
    });
}
- (void)didChangeObject:(id)anObject
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(TableChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak UICollectionView *weakCollectionView = self.collectionView;
        switch(type) {
            case TableChangeInsert: {
                [self.updateOperation addExecutionBlock:^{
                    [weakCollectionView insertItemsAtIndexPaths:@[newIndexPath]];
                }];
                break;
            }
            case TableChangeDelete: {
                [self.updateOperation addExecutionBlock:^{
                    [weakCollectionView deleteItemsAtIndexPaths:@[newIndexPath]];
                }];
                break;
            }
            case TableChangeUpdate: {
                [self.updateOperation addExecutionBlock:^{
                    [weakCollectionView reloadItemsAtIndexPaths:@[newIndexPath]];
                }];
                break;
            }
            case TableChangeMove: {
                [self.updateOperation addExecutionBlock:^{
                    [weakCollectionView deleteItemsAtIndexPaths:@[newIndexPath]];
                    [weakCollectionView insertItemsAtIndexPaths:@[newIndexPath]];
                }];
                break;
            }
            default:
                break;
        }
    });
}
- (void)didChangeContent {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.updateOperation start];
    });
}

@end