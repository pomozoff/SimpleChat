//
//  CameraViewController.m
//  SimpleChat
//
//  Created by Антон on 11.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import AVFoundation;

#import "CameraViewController.h"

@interface CameraViewController ()

@property (nonatomic, strong) AVCaptureSession *session;

@end

@implementation CameraViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Session
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    // Device
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        NSLog(@"No Input: %@", error);
    } else {
        [self.session addInput:input];
    }
    
    // Output
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [self.session addOutput:output];
    output.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    
    // Preview layer
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    previewLayer.frame = self.view.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:previewLayer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Camera presenter

- (void)showCamera {
    [self.session startRunning];
}
- (void)stopCamera {
    [self.session stopRunning];
}

#pragma mark - Action


#pragma mark - Private

- (void)switchCamera {
    
}

@end
