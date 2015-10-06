//
//  ImageCollectionViewCell.m
//  SimpleChat
//
//  Created by Anton Pomozov on 06.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@interface ImageCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ImageCollectionViewCell

#pragma mark - Constants

static NSString * const kImagePlaceholderName = @"placeholder";

#pragma mark - Properties

- (void)setImageItem:(id<ImageItem>)imageItem {
    _imageItem = imageItem;
}

#pragma mark - Public

- (void)updateImage:(nullable UIImage *)image {
    if (!image) {
        image = [UIImage imageNamed:kImagePlaceholderName];
    }
    CGFloat scale = self.imageView.frame.size.width / image.size.width;
    UIImage *scaledImage = [UIImage imageWithCGImage:[image CGImage]
                                               scale:(image.scale / scale)
                                         orientation:image.imageOrientation];
    self.imageView.image = scaledImage;
}

@end
