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

@interface LocalImagesDataSource ()

@property (nonatomic, strong) NSArray *cats;

@end

@implementation LocalImagesDataSource

#pragma mark - Constants

static NSString * const kCatsFileName = @"cats";

#pragma mark - Properties

- (NSArray *)cats {
    if (!_cats) {
        _cats = [self loadJsonWithCats];
    }
    return _cats;
}

#pragma mark - Messages data source

- (void)fetchImagesWithCompletion:(FetchImagesCompletionHandler)handler {
    NSMutableArray <id <ImageItem>> *imageItems = [NSMutableArray arrayWithCapacity:1];
    if ([self hasPermissions]) {

    } else {
        for (NSDictionary *cat in self.cats) {
            id <ImageItem> imageItem = [[ImageItem alloc] init];
            imageItem.image = [UIImage imageNamed:cat[@"name"]];
            [imageItems addObject:imageItem];
        }
    }
    handler(YES, [imageItems copy], nil);
}

#pragma mark - Private

- (BOOL)hasPermissions {
    return [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized;
}
- (NSArray *)loadJsonWithCats {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kCatsFileName ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return jsonDictionary[@"cats"];
}

@end
