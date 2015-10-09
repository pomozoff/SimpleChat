//
//  ImagesCollectionViewController.h
//  SimpleChat
//
//  Created by Anton Pomozov on 05.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import UIKit;

#import "ImagesCollectionManager.h"
#import "imageRouter.h"

@interface ImagesCollectionViewController : UICollectionViewController

@property (nonatomic, strong) id <ImagesCollectionDataSource> imagesCollectionDataSource;
@property (nonatomic, strong) id <ImageHandlerRouter> imageHandlerRouter;

@end
