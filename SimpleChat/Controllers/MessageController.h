//
//  MessageController.h
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef void (^ImageUpdateCompletionHandler)(UIImage * _Nullable image, NSError * _Nullable error);

@protocol MessageController <NSObject>

- (void)updateImageWithCompletion:(ImageUpdateCompletionHandler)handler;

@end

@interface MessageController : NSObject

@end

NS_ASSUME_NONNULL_END
