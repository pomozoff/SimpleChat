//
//  ImagesCollectionManager.m
//  SimpleChat
//
//  Created by Антон on 05.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ImagesCollectionManager.h"

@interface ImagesCollectionManager ()

@property (nonatomic, strong) NSArray <id <ImageItem>> *imageItems;

@end

@implementation ImagesCollectionManager

#pragma mark - Images data source

- (NSInteger)numberOfSections {
    return 1;
}
- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    NSAssert([NSThread isMainThread], @"Not in main thread!");
    return (NSInteger)self.imageItems.count;
}
- (id <ImageItem>)imageAtIndexPath:(NSIndexPath *)indexPath {
    return self.imageItems[(NSUInteger)indexPath.row];
}
- (void)fetchImagesWithCompletion:(CompletionHandler)handler {
    [self.imagesDataSource fetchImagesWithCompletion:^(BOOL succeeded, NSArray <id <ImageItem>> *imageItems, NSError * _Nullable error) {
        self.imageItems = imageItems;
        handler(succeeded, error);
    }];
}
- (void)freeMemory {
    self.imageItems = nil;
}

@end
