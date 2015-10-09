//
//  ImageRouter.m
//  SimpleChat
//
//  Created by Anton Pomozov on 09.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ImageRouter.h"

@implementation ImageRouter

- (void)didSelectImage:(UIImage *)image {
    [self.imageProcessor processImage:image];
}

@end
