//
//  CameraViewController.m
//  SimpleChat
//
//  Created by Антон on 11.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import AVFoundation;

#import "CameraViewController.h"

@interface CameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) IBOutlet UIButton *toggleFullscreenButton;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, copy) NSString *toggleFullscreenCurrentImageName;

@end

@implementation CameraViewController

#pragma mark - Constants

static NSString * const kSwitchToFullscreenImageName = @"camera_interface_fullscreen";
static NSString * const kSwitchToPreviewImageName = @"fullscreen_close";

#pragma mark - Properties

@synthesize cameraProcessor = _cameraProcessor;

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetPhoto;
    }
    return _session;
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.toggleFullscreenCurrentImageName = kSwitchToFullscreenImageName;
    
    // Input
    [self switchCameraToDesiredPosition:AVCaptureDevicePositionBack];
    
    // Output
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [self.session addOutput:output];
    output.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    // Preview layer
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Camera presenter

- (void)showCamera {
    self.previewLayer.frame = self.view.bounds;
    [self.session startRunning];
}
- (void)stopCamera {
    [self.session stopRunning];
}

#pragma mark - Action

- (IBAction)toggleFullscreen:(UIButton *)sender {
    [self switchFullscreenButtons];
    [self.cameraProcessor toggleFullscreen];
    self.previewLayer.frame = self.view.bounds;
}
- (IBAction)sendButton:(UIButton *)sender {
    [self.cameraProcessor sendPhoto:self.image];
}
- (IBAction)switchCameraButton:(UIButton *)sender {
    AVCaptureInput *currentCameraInput = [self.session.inputs firstObject];
    AVCaptureDevicePosition currentCameraPosition = ((AVCaptureDeviceInput *)currentCameraInput).device.position;
    AVCaptureDevicePosition desiredPosition = currentCameraPosition == AVCaptureDevicePositionFront ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    
    [self switchCameraToDesiredPosition:desiredPosition];
}

#pragma mark - <AVCaptureVideoDataOutputSampleBufferDelegate>

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.image = image;
    });
}

#pragma mark - Private

- (AVCaptureDevice *)nextCamera:(AVCaptureInput *)currentCameraInput {
    AVCaptureDevicePosition currentCameraPosition = ((AVCaptureDeviceInput *)currentCameraInput).device.position;
    AVCaptureDevicePosition nextCameraPosition = currentCameraPosition == AVCaptureDevicePositionFront ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    return [self cameraWithPosition:nextCameraPosition];
}
- (AVCaptureDeviceInput *)videoInputForDevice:(AVCaptureDevice *)device {
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input || error) {
        NSLog(@"Error creating capture device input: %@", error.localizedDescription);
    }
    return input;
}
- (void)switchCameraToDesiredPosition:(AVCaptureDevicePosition)desiredPosition {
    NSArray <AVCaptureDevice *> *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == desiredPosition) {
            AVCaptureDeviceInput *input = [self videoInputForDevice:device];
            [self replaceVideoInput:input forDevice:device];
            
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut
                             animations:^(void) {
                                 self.view.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
                                 self.view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             }
                             completion:nil];
            break;
        }
    }
}
- (void)replaceVideoInput:(AVCaptureInput *)input forDevice:(AVCaptureDevice *)device {
    [device lockForConfiguration:nil];
    [self.session beginConfiguration];
    
    for (AVCaptureInput *oldInput in self.session.inputs) {
        [self.session removeInput:oldInput];
    }
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    } else {
        NSLog(@"Can't add device input to a session: %@", self.session);
    }

    [self.session commitConfiguration];
    [device unlockForConfiguration];
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    uint8_t *base = CVPixelBufferGetBaseAddress(buffer);
    size_t width = CVPixelBufferGetWidth(buffer);
    size_t height = CVPixelBufferGetHeight(buffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace,
                                                   kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(cgContext);
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:UIImageOrientationRight];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    return image;
}
- (void)switchFullscreenButtons {
    self.toggleFullscreenCurrentImageName = [self.toggleFullscreenCurrentImageName isEqualToString:kSwitchToFullscreenImageName] ? kSwitchToPreviewImageName : kSwitchToFullscreenImageName;
    UIImage *image = [UIImage imageNamed:self.toggleFullscreenCurrentImageName];
    [self.toggleFullscreenButton setImage:image forState:UIControlStateNormal];
}

@end
