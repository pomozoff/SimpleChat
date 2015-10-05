//
//  ChatMessage.h
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Parse;

NS_ASSUME_NONNULL_BEGIN

typedef void (^CompletionHandler)(BOOL succeeded, NSError * _Nullable error);
typedef void (^FetchImageCompletionHandler)(UIImage * _Nullable image, NSError * _Nullable error);

@protocol ChatMessage <NSObject>

@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIImage *image;
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
