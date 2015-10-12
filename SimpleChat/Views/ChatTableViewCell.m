//
//  ChatTableViewCell.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import MapKit;

#import "ChatTableViewCell.h"

@interface ChatTableViewCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@property (weak, nonatomic) IBOutlet UILabel *messageTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleTail;
@property (weak, nonatomic) IBOutlet UIImageView *chatImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorOfImageLoading;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gapBetweenTextAndSuperviewConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gapBetweenImageAndTextConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatImageHeightConstraint;

@property (nonatomic, assign) BOOL isImageTapped;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIImageView *panningImageView;

@end

@implementation ChatTableViewCell

#pragma mark - Constants

#pragma mark - Properties

- (void)setChatMessage:(id<ChatMessage>)chatMessage {
    _chatMessage = chatMessage;
    self.messageTextLabel.text = _chatMessage.text;

    BOOL textOnly = !_chatMessage.hasImage && !_chatMessage.hasLocation;
    BOOL hasImageOrMap = _chatMessage.hasImage || _chatMessage.hasLocation;
    
    if (textOnly || _chatMessage.text.length == 0) {
        self.gapBetweenImageAndTextConstraint.constant = 0.0f;
    } else if (hasImageOrMap && _chatMessage.text.length > 0) {
        self.gapBetweenImageAndTextConstraint.constant = self.gapBetweenTextAndSuperviewConstraint.constant;
    }

    self.chatImageHeightConstraint.constant = 0;
}
- (void)setHasTail:(BOOL)hasTail {
    _hasTail = hasTail;
    self.bubbleTail.hidden = !hasTail;
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(didLongTapOnImage:)];
        _longPressGestureRecognizer.delegate = self;
    }
    return _longPressGestureRecognizer;
}
- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(panHandler:)];;
        _panGestureRecognizer.delegate = self;
    }
    return _panGestureRecognizer;
}

#pragma mark - Public

- (void)updateImage:(nullable UIImage *)image {
    UIImage *scaledImage;
    CGFloat imageHeight;
    if (image) {
        CGFloat scale = self.chatImageView.frame.size.width / image.size.width;
        scaledImage = [UIImage imageWithCGImage:[image CGImage]
                                          scale:(image.scale / scale)
                                    orientation:image.imageOrientation];
        imageHeight = scaledImage.size.height;
    } else {
        imageHeight = 0;
    }
    self.chatImageHeightConstraint.constant = imageHeight;
    self.chatImageView.image = scaledImage;
}
- (void)showProgress {
    if (self.chatMessage.hasImage || self.chatMessage.hasLocation) {
        self.activityIndicatorOfImageLoading.hidden = NO;
        [self.activityIndicatorOfImageLoading startAnimating];
    }
}
- (void)hideProgress {
    [self.activityIndicatorOfImageLoading stopAnimating];
    self.activityIndicatorOfImageLoading.hidden = YES;
}

#pragma mark - Lifecycle

- (void)awakeFromNib {
    // Initialization code
    self.bubbleView.layer.cornerRadius = 10.0f;
    self.bubbleView.layer.masksToBounds = YES;
    
    self.chatImageView.layer.cornerRadius = 5.0f;
    self.chatImageView.layer.masksToBounds = YES;
    
    [self.chatImageView addGestureRecognizer:self.longPressGestureRecognizer];
    [self.chatImageView addGestureRecognizer:self.panGestureRecognizer];
    
    self.locationPreviewSize = CGSizeMake(self.chatImageView.frame.size.width, self.chatImageView.frame.size.width);
}
- (void)prepareForReuse {
    [self hideProgress];
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer {
    BOOL result = gestureRecognizer == self.longPressGestureRecognizer && otherGestureRecognizer == self.panGestureRecognizer;
    return result;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL result = (!self.isImageTapped && gestureRecognizer == self.longPressGestureRecognizer)
               || (self.isImageTapped && gestureRecognizer == self.panGestureRecognizer);
    return result;
}

#pragma mark - Private

- (void)animateConstraintsChangesDuration:(CGFloat)duration withAnimation:(void(^)(void))animation withCompletion:(void (^)(BOOL))completion {
    [UIView animateWithDuration:duration
                          delay:0.0f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.5f
                        options:0
                     animations:animation
                     completion:completion];
}
- (void)didLongTapOnImage:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self moveImageStartWithCoordinate:[sender locationInView:self.window]];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self moveImageBack];
    }
}
- (void)panHandler:(UIPanGestureRecognizer *)sender {
    if (self.isImageTapped) {
        CGPoint coordinate = [sender locationInView:self.window];
        [self updateFrameOfView:self.panningImageView toCoordinate:coordinate];
    }
}
- (void)updateFrameOfView:(UIView *)view withNewFrame:(CGRect)newFrame {
    //NSLog(@"New frame: %@", NSStringFromCGRect(newFrame));
    view.frame = newFrame;
    [self setNeedsDisplay];
}
- (void)updateFrameOfView:(UIView *)view toCoordinate:(CGPoint)coordinate {
    CGSize viewSize = view.frame.size;
    CGRect newFrame = CGRectMake(coordinate.x - viewSize.width / 2,
                                 coordinate.y - viewSize.height / 2,
                                 viewSize.width,
                                 viewSize.height);
    [self updateFrameOfView:view withNewFrame:newFrame];
}
- (void)growView:(UIView *)view {
    CGFloat delta = 10.0f;
    CGRect oldFrame = view.frame;
    CGRect newFrame = CGRectMake(oldFrame.origin.x - delta,
                                 oldFrame.origin.y - delta,
                                 oldFrame.size.width + delta * 2,
                                 oldFrame.size.height + delta * 2);
    [self updateFrameOfView:view withNewFrame:newFrame];
}
- (void)moveImageStartWithCoordinate:(CGPoint)coordinate {
    self.isImageTapped = YES;

    self.panningImageView = [[UIImageView alloc] initWithImage:self.chatImageView.image];
    self.panningImageView.layer.cornerRadius = 5.0f;
    self.panningImageView.layer.masksToBounds = YES;
    self.chatImageView.image = [UIImage imageNamed:@"placeholder"];
    
    [self updateFrameOfView:self.panningImageView toCoordinate:coordinate];
    [self.window addSubview:self.panningImageView];
    
    __weak __typeof(self) weakSelf = self;
    [self animateConstraintsChangesDuration:0.5f withAnimation:^{
        [self growView:weakSelf.panningImageView];
    }
                             withCompletion:nil];
}
- (void)moveImageBack {
    self.isImageTapped = NO;
    
    __weak __typeof(self) weakSelf = self;
    [self animateConstraintsChangesDuration:0.5f withAnimation:^{
        weakSelf.chatImageView.image = self.panningImageView.image;
        [weakSelf.panningImageView removeFromSuperview];
        weakSelf.panningImageView = nil;
    }
                             withCompletion:^(BOOL finished) {
                             }];
}

@end
