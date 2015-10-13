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
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIImageView *panningImageView;

@property (nonatomic, assign) CGFloat panDeltaX;
@property (nonatomic, assign) CGFloat panDeltaY;

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

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(didTapOnImage:)];
        _tapGestureRecognizer.delegate = self;
    }
    return _tapGestureRecognizer;
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
        CGFloat scale = image.size.width / self.chatImageView.frame.size.width;
        scaledImage = [UIImage imageWithCGImage:[image CGImage]
                                          scale:(image.scale * scale)
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
        [self.activityIndicatorOfImageLoading startAnimating];
    }
}
- (void)hideProgress {
    [self.activityIndicatorOfImageLoading stopAnimating];
}

#pragma mark - Lifecycle

- (void)awakeFromNib {
    // Initialization code
    self.bubbleView.layer.cornerRadius = 10.0f;
    self.bubbleView.layer.masksToBounds = YES;
    
    self.chatImageView.layer.cornerRadius = 5.0f;
    self.chatImageView.layer.masksToBounds = YES;
    
    [self.chatImageView addGestureRecognizer:self.tapGestureRecognizer];
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
               || (!self.isImageTapped && gestureRecognizer == self.tapGestureRecognizer)
               || (self.isImageTapped && gestureRecognizer == self.panGestureRecognizer);
    return result;
}

#pragma mark - Private

- (void)animateConstraintsChangesDuration:(CGFloat)duration withAnimation:(void(^)(void))animation withCompletion:(void (^)(BOOL))completion {
    [UIView animateWithDuration:duration
                          delay:0.0f
         usingSpringWithDamping:0.8f
          initialSpringVelocity:0.5f
                        options:0
                     animations:animation
                     completion:completion];
}
- (void)didTapOnImage:(UITapGestureRecognizer *)recognizer {
    self.panningImageView = [[UIImageView alloc] initWithImage:self.chatMessage.image];
    self.panningImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.panningImageView.backgroundColor = [UIColor blackColor];
    self.panningImageView.userInteractionEnabled = YES;
    self.panningImageView.frame = [self.window convertRect:self.chatImageView.frame fromView:self.chatImageView.superview];

    __weak __typeof(self) weakSelf = self;
    [self animateConstraintsChangesDuration:0.5f withAnimation:^{
        [weakSelf.window addSubview:weakSelf.panningImageView];
        weakSelf.panningImageView.frame = weakSelf.window.frame;
    }
                             withCompletion:^(BOOL finished) {
                                 UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf
                                                                                                                        action:@selector(didTapOnFullscreenImage:)];
                                 [weakSelf.panningImageView addGestureRecognizer:tapGestureRecognizer];
                             }];
}
- (void)didTapOnFullscreenImage:(UITapGestureRecognizer *)recognizer {
    __weak __typeof(self) weakSelf = self;
    self.panningImageView.layer.cornerRadius = 5.0f;
    self.panningImageView.layer.masksToBounds = YES;
    self.panningImageView.backgroundColor = [UIColor clearColor];

    [self animateConstraintsChangesDuration:0.3f withAnimation:^{
        weakSelf.panningImageView.frame = [self.window convertRect:self.chatImageView.frame fromView:self.chatImageView.superview];
    }
                             withCompletion:^(BOOL finished) {
                                 [weakSelf.panningImageView removeFromSuperview];
                                 weakSelf.panningImageView = nil;
                             }];
}
- (void)didLongTapOnImage:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self moveImageStartWithCoordinate:[recognizer locationInView:self.window]];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self moveImageBack];
    }
}
- (void)panHandler:(UIPanGestureRecognizer *)recognizer {
    if (self.isImageTapped) {
        CGPoint coordinate = [recognizer locationInView:self.window];
        coordinate.x += self.panDeltaX;
        coordinate.y += self.panDeltaY;
        [self updateFrameOfView:self.panningImageView toCoordinate:coordinate];
    }
}
- (void)updateFrameOfView:(UIView *)view withNewFrame:(CGRect)newFrame {
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
    
    CGRect frame = [self.window convertRect:self.chatImageView.frame fromView:self.chatImageView.superview];
    self.panningImageView.frame = frame;
    [self.window addSubview:self.panningImageView];
    
    self.panDeltaX = frame.origin.x + frame.size.width / 2 - coordinate.x;
    self.panDeltaY = frame.origin.y + frame.size.height / 2 - coordinate.y;
    
    __weak __typeof(self) weakSelf = self;
    [self animateConstraintsChangesDuration:0.5f withAnimation:^{
        [weakSelf growView:weakSelf.panningImageView];
    }
                             withCompletion:nil];
}
- (void)moveImageBack {
    self.isImageTapped = NO;
    
    CGRect oldFrame = [self.window convertRect:self.chatImageView.frame fromView:self.chatImageView.superview];
    __weak __typeof(self) weakSelf = self;
    [self animateConstraintsChangesDuration:0.5f withAnimation:^{
        weakSelf.panningImageView.frame = oldFrame;
        weakSelf.chatImageView.image = weakSelf.panningImageView.image;
        [weakSelf.panningImageView removeFromSuperview];
        weakSelf.panningImageView = nil;
    }
                             withCompletion:^(BOOL finished) {
                             }];
}

@end
