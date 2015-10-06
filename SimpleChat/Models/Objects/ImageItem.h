//
//  ImageItem.h
//  SimpleChat
//
//  Created by Anton Pomozov on 06.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;
@import Foundation;

#import "Common.h"

@protocol ImageItem <NSObject>

@property (nonatomic, strong) UIImage *image;

@end

@interface ImageItem : NSObject <ImageItem>

@end
