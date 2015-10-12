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
    
    // Device
    AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    [self addVideoInput:camera];
    
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
    [self switchCamera];
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
- (void)addVideoInput:(AVCaptureDevice *)camera {
    NSError *error = nil;
    AVCaptureDeviceInput *newVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
    if (!newVideoInput || error) {
        NSLog(@"Error creating capture device input: %@", error.localizedDescription);
    } else {
        if ([self.session canAddInput:newVideoInput]) {
            [self.session addInput:newVideoInput];
        } else {
            NSLog(@"Can't add device input to a session: %@", error.localizedDescription);
        }
    }
}
- (void)switchCamera {
    [self.session beginConfiguration];
    
    AVCaptureInput *currentCameraInput = [self.session.inputs firstObject];
    [self.session removeInput:currentCameraInput];
    AVCaptureDevice *newCamera = [self nextCamera:currentCameraInput];
    
    [self addVideoInput:newCamera];
    [self.session commitConfiguration];
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
