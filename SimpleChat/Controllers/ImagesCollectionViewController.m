//
//  ImagesCollectionViewController.m
//  SimpleChat
//
//  Created by Anton Pomozov on 05.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ImagesCollectionViewController.h"
#import "ImageCollectionViewCell.h"

@interface ImagesCollectionViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation ImagesCollectionViewController

#pragma mark - Constants

static NSString * const kImagePlaceholderName = @"placeholder";
static NSString * const reuseIdentifier = @"Collection Image Cell";

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    [self.imagesCollectionDataSource freeMemory];
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self setupCollectionLayout];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.collectionViewLayout invalidateLayout];
        self.collectionView.alwaysBounceHorizontal = !self.collectionView.alwaysBounceHorizontal;
        self.collectionView.alwaysBounceVertical = !self.collectionView.alwaysBounceVertical;
    }];
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

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView * _Nonnull)collectionView didSelectItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath {
    id <ImageItem> imageItem = [self.imagesCollectionDataSource imageAtIndexPath:indexPath];
    [self.imageHandlerRouter didSelectImage:imageItem.image];
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [self collectionViewCellHeight];
    CGSize cellSize = CGSizeMake(height, height);
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
        dispatch_async(dispatch_get_main_queue(), ^{
            if (succeeded) {
                [weakSelf.collectionView reloadData];
                [weakSelf setupCollectionLayout];
            } else {
                NSLog(@"Failed to reload images: %@ %@", error, error.userInfo);
            }
        });
    }];
}
- (UIInterfaceOrientation)deviceOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}
- (void)setupCollectionLayout {
    UIInterfaceOrientation orientation = [self deviceOrientation];
    UICollectionViewScrollDirection direction = UIInterfaceOrientationIsPortrait(orientation) ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;
    ((UICollectionViewFlowLayout *)self.collectionViewLayout).scrollDirection = direction;
    [self.collectionViewLayout invalidateLayout];
}
- (CGFloat)collectionViewCellHeight {
    UIInterfaceOrientation orientation = [self deviceOrientation];
    return orientation = UIInterfaceOrientationIsPortrait(orientation) ? self.collectionView.bounds.size.height : self.collectionView.bounds.size.width;
}

@end
