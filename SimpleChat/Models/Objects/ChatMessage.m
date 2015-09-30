//
//  ChatMessage.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatMessage.h"

@interface ChatMessage ()

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;

@end

@implementation ChatMessage

#pragma mark - Properties

@synthesize text = _text;
@synthesize image = _image;
@synthesize latitude = _latitude;
@synthesize  longitude = _longitude;

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

@end
