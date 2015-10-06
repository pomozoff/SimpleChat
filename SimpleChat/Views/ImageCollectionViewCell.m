//
//  ImageCollectionViewCell.m
//  SimpleChat
//
//  Created by Anton Pomozov on 06.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@implementation ImageCollectionViewCell

#pragma mark - Properties

- (void)setImageItem:(id<ImageItem>)imageItem {
    _imageItem = imageItem;
}

#pragma mark - Public

- (void)updateImage:(nullable UIImage *)image {
    
}

@end
