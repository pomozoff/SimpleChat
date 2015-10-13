//
//  ChatMessage.h
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;
@import Foundation;
@import CoreLocation;

#import "Common.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ChatMessage <NSObject>

@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;
@property (nonatomic, assign) BOOL hasLocation;
@property (nonatomic, assign) BOOL hasImage;

@end

@interface ChatMessage : NSObject <ChatMessage>

- (instancetype)initWithText:(NSString *)text NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithImage:(UIImage *)image NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
