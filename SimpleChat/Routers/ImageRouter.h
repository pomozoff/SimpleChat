//
//  ImageRouter.h
//  SimpleChat
//
//  Created by Anton Pomozov on 09.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol ImageHandlerRouter <NSObject>

- (void)didSelectImage:(UIImage *)image;

@end

@protocol ImageProcessor <NSObject>

- (void)processImage:(UIImage *)image;

@end

@protocol ImagePresenter <NSObject>

- (void)presentImage:(UIImage *)image;

@end

@interface ImageRouter : NSObject <ImageHandlerRouter>

@property (nonatomic, strong) id <ImageProcessor> imageProcessor;

@end

NS_ASSUME_NONNULL_END
