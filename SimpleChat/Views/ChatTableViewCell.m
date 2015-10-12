//
//  ChatTableViewCell.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import MapKit;

#import "ChatTableViewCell.h"

@interface ChatTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@property (weak, nonatomic) IBOutlet UILabel *messageTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleTail;
@property (weak, nonatomic) IBOutlet UIImageView *chatImageView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gapBetweenTextAndSuperviewConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gapBetweenImageAndTextConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatImageHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gapBetweenMapAndTextConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapAspectRatioConstraint;

@end

@implementation ChatTableViewCell

#pragma mark - Constants

static UILayoutPriority const kMaxConstraintPriority = 800;
static UILayoutPriority const kMinConstraintPriority = 200;

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
        self.gapBetweenMapAndTextConstraint.constant = self.gapBetweenTextAndSuperviewConstraint.constant;
    }

    self.chatImageHeightConstraint.constant = 0;

    self.mapHeightConstraint.priority = kMaxConstraintPriority;
    self.mapAspectRatioConstraint.priority = kMinConstraintPriority;
}
- (void)setHasTail:(BOOL)hasTail {
    _hasTail = hasTail;
    self.bubbleTail.hidden = !hasTail;
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
- (void)updateLocation {
    [self.mapView removeAnnotations:self.mapView.annotations];

    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(self.chatMessage.latitude, self.chatMessage.longitude);
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = location;
    
    [self.mapView addAnnotation:annotation];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.015f, 0.015f);
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
    self.mapView.region = region;

    self.mapHeightConstraint.priority = kMinConstraintPriority;
    self.mapAspectRatioConstraint.priority = kMaxConstraintPriority;
}

#pragma mark - Lifecycle

- (void)awakeFromNib {
    // Initialization code
    self.bubbleView.layer.cornerRadius = 10.0f;
    self.bubbleView.layer.masksToBounds = YES;
    
    self.chatImageView.layer.cornerRadius = 5.0f;
    self.chatImageView.layer.masksToBounds = YES;
    
    self.mapView.layer.cornerRadius = 5.0f;
    self.mapView.layer.masksToBounds = YES;
}

@end
