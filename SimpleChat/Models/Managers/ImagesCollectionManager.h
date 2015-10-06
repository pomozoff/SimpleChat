//
//  ImagesCollectionManager.h
//  SimpleChat
//
//  Created by Антон on 05.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;

#import "ImageItem.h"
#import "ImagesDataSource.h"
#import "Common.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ImagesCollectionDataSource <NSObject>

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (id <ImageItem>)imageAtIndexPath:(NSIndexPath *)indexPath;
- (void)fetchImagesWithCompletion:(CompletionHandler)handler;

@end

@interface ImagesCollectionManager : NSObject <ImagesCollectionDataSource>

@property (nonatomic, strong) id <DataPresenter> dataPresenter;
@property (nonatomic, strong) id <ImagesDataSource> imagesDataSource;

@end

NS_ASSUME_NONNULL_END
