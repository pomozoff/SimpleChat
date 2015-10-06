//
//  LocalImagesDataSource.m
//  SimpleChat
//
//  Created by Anton Pomozov on 06.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Photos;

#import "LocalImagesDataSource.h"
#import "Common.h"

@implementation LocalImagesDataSource

#pragma mark - Constants

static NSString * const kImageName = @"cat";
static NSString * const kImage2Name = @"cat2";

#pragma mark - Messages data source

- (void)fetchImagesWithCompletion:(FetchImagesCompletionHandler)handler {
    NSMutableArray <id <ImageItem>> *imageItems = [NSMutableArray arrayWithCapacity:1];
    if ([self hasPermissions]) {

    } else {
        id <ImageItem> imageItem = [[ImageItem alloc] init];
        imageItem.image = [UIImage imageNamed:kImageName];
        [imageItems addObject:imageItem];
        imageItem = [[ImageItem alloc] init];
        imageItem.image = [UIImage imageNamed:kImage2Name];
        [imageItems addObject:imageItem];
    }
    handler(YES, [imageItems copy], nil);
}

#pragma mark - Private

- (BOOL)hasPermissions {
    return [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized;
}
//- (NSArray <id <ImageItem>> *)imageItems

@end
