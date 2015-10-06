//
//  ImagesDataSource.h
//  SimpleChat
//
//  Created by Anton Pomozov on 06.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#ifndef ImagesDataSource_h
#define ImagesDataSource_h

@import Foundation;

#import "ImageItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^FetchCompletionHandler)(BOOL succeeded, NSArray <id <ImageItem>> *messages, NSError * _Nullable error);

@protocol ImagesDataSource <NSObject>

- (void)fetchImagesWithCompletion:(FetchCompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END

#endif /* ImagesDataSource_h */