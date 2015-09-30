//
//  ChatMessage.h
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Parse;

NS_ASSUME_NONNULL_BEGIN

@protocol ChatMessage <NSObject>

@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) CLLocationDegrees latitude;
@property (nonatomic, assign, readonly) CLLocationDegrees longitude;

@end

@interface ChatMessage : NSObject <ChatMessage>

- (instancetype)initWithText:(NSString *)text NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
