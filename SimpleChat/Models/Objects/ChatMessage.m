//
//  ChatMessage.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatMessage.h"

@implementation ChatMessage

#pragma mark - Properties

@synthesize text = _text;
@synthesize image = _image;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize hasLocation = _hasLocation;
@synthesize hasImage = _hasImage;

#pragma mark - Initialization

- (instancetype)init {
    return [self initWithText:@""];
}
- (instancetype)initWithText:(NSString *)text {
    if (self = [super init]) {
        self.text = text;
    }
    return self;
}
- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        self.hasImage = YES;
        self.image = image;
    }
    return self;
}
- (instancetype)initWithLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude {
    if (self = [super init]) {
        self.hasLocation = YES;
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}

@end
