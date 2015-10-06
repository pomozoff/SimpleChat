//
//  ImageCollectionViewCell.h
//  SimpleChat
//
//  Created by Anton Pomozov on 06.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;

#import "ImageItem.h"

@interface ImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, nullable) id <ImageItem> imageItem;

- (void)updateImage:(nullable UIImage *)image;

@end
