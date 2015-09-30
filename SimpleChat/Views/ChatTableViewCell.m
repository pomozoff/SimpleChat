//
//  ChatTableViewCell.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatTableViewCell.h"

@interface ChatTableViewCell ()

@property (nonatomic, weak) IBOutlet UIView *bubbleView;
@property (nonatomic, weak) IBOutlet UILabel *messageTextLabel;

@end

@implementation ChatTableViewCell

#pragma mark - Properties

- (void)setChatMessage:(id<ChatMessage>)chatMessage {
    _chatMessage = chatMessage;
    self.messageTextLabel.text = _chatMessage.text;
    [self.messageContoller updateImageWithCompletion:^(UIImage * _Nullable image, NSError * _Nullable error) {
    }];
}

#pragma mark - Lifecycle

- (void)awakeFromNib {
    // Initialization code
    self.bubbleView.layer.cornerRadius = 10.0f;
    self.bubbleView.layer.masksToBounds = YES;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)prepareForReuse {
    
}

@end
