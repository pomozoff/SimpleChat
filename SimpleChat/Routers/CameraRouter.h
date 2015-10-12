//
//  CameraRouter.h
//  SimpleChat
//
//  Created by Антон on 11.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol CameraHandlerRouter <NSObject>

//- (void)didSelectImage:(UIImage *)image;

@end

@protocol CameraProcessor <NSObject>

- (void)toggleFullscreen;
- (void)sendPhoto:(UIImage *)image;

@end

@protocol CameraPresenter <NSObject>

@property (nonatomic, strong) id <CameraProcessor> cameraProcessor;

- (void)showCamera;
- (void)stopCamera;

@end

@interface CameraRouter : NSObject <CameraHandlerRouter>

//@property (nonatomic, strong) id <ImageProcessor> imageProcessor;

@end

NS_ASSUME_NONNULL_END
