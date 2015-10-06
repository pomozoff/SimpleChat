//
//  ImagesCollectionManager.m
//  SimpleChat
//
//  Created by Антон on 05.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ImagesCollectionManager.h"

@interface ImagesCollectionManager ()

@property (nonatomic, strong) NSMutableArray <id <ImageItem>> *images;

@end

@implementation ImagesCollectionManager

#pragma mark - Properties

- (NSMutableArray <id <ImageItem>> *)images {
    if (!_images) {
        _images = [NSMutableArray arrayWithCapacity:1];
    }
    return _images;
}

#pragma mark - Images data source

- (NSInteger)numberOfSections {
    return 1;
}
- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    NSAssert([NSThread isMainThread], @"Not in main thread!");
    return (NSInteger)self.images.count;
}
- (id <ImageItem>)imageAtIndexPath:(NSIndexPath *)indexPath {
    return self.images[(NSUInteger)indexPath.row];
}
- (void)fetchImagesWithCompletion:(CompletionHandler)handler {
    
}

@end
