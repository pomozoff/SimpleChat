//
//  ImagesCollectionViewController.m
//  SimpleChat
//
//  Created by Anton Pomozov on 05.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ImagesCollectionViewController.h"
#import "ImageCollectionViewCell.h"

@implementation ImagesCollectionViewController

#pragma mark - Constants

static NSString * const kImagePlaceholderName = @"placeholder";
static NSString * const reuseIdentifier = @"Collection Image Cell";

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadImages];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.imagesCollectionDataSource numberOfSections];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imagesCollectionDataSource numberOfItemsInSection:section];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [self collectionView:collectionView updateCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = CGSizeMake(self.collectionView.bounds.size.height, self.collectionView.bounds.size.height);
    return cellSize;
}

#pragma mark - Private common

- (void)collectionView:(nonnull UICollectionView *)collectionView
            updateCell:(nonnull UICollectionViewCell *)cell
           atIndexPath:(nonnull NSIndexPath *)indexPath
{
    ImageCollectionViewCell *imageCell = (ImageCollectionViewCell *)cell;
    id <ImageItem> imageItem = [self.imagesCollectionDataSource imageAtIndexPath:indexPath];

    imageCell.imageItem = imageItem;
    [imageCell updateImage:imageItem.image];
}
- (void)reloadImages {
    __weak __typeof(self) weakSelf = self;
    [self.imagesCollectionDataSource fetchImagesWithCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            });
        } else {
            NSLog(@"Failed to reload images: %@ %@", error, error.userInfo);
        }
    }];
}

@end
