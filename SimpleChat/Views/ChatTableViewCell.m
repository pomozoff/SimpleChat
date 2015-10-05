//
//  ChatTableViewCell.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatTableViewCell.h"

@interface ChatTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *bubbleView;
@property (weak, nonatomic) IBOutlet UILabel *messageTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleTail;
@property (weak, nonatomic) IBOutlet UIImageView *chatImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gapBetweenImageAndTextConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gapBetweenTextAndSuperviewConstraint;

@end

@implementation ChatTableViewCell

#pragma mark - Properties

- (void)setChatMessage:(id<ChatMessage>)chatMessage {
    _chatMessage = chatMessage;
    self.messageTextLabel.text = _chatMessage.text;

    if (!_chatMessage.hasImage || _chatMessage.text.length == 0) {
        self.gapBetweenImageAndTextConstraint.constant = 0.0f;
    } else if (_chatMessage.hasImage && _chatMessage.text.length > 0) {
        self.gapBetweenImageAndTextConstraint.constant = self.gapBetweenTextAndSuperviewConstraint.constant;
    }
}
- (void)setHasTail:(BOOL)hasTail {
    _hasTail = hasTail;
    self.bubbleTail.hidden = !hasTail;
}

#pragma mark - Public

- (void)updateImage:(nullable UIImage *)image {
    CGFloat scale = self.chatImageView.frame.size.width / image.size.width;
    UIImage *scaledImage = [UIImage imageWithCGImage:[image CGImage]
                                               scale:(image.scale / scale)
                                         orientation:image.imageOrientation];
    self.chatImageView.image = scaledImage;
    //NSLog(@"Message id: %@, cell: %p, image: %@", self.chatMessage.messageId, self, image);
}

#pragma mark - Lifecycle

- (void)awakeFromNib {
    // Initialization code
    self.bubbleView.layer.cornerRadius = 10.0f;
    self.bubbleView.layer.masksToBounds = YES;
    
    self.chatImageView.layer.cornerRadius = 5.0f;
    self.chatImageView.layer.masksToBounds = YES;
}

@end
