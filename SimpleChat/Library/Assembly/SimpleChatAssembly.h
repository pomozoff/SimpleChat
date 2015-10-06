//
//  SimpleChatAssembly.h
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Typhoon;

#import "ChatTableViewController.h"
#import "ImagesCollectionViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SimpleChatAssembly : TyphoonAssembly

- (ChatTableViewController *)chatTableViewController;
- (ChatManager *)chatManager;

- (ImagesCollectionViewController *)imagesCollectionViewController;
- (ImagesCollectionManager *)imagesCollectionManager;

@end

NS_ASSUME_NONNULL_END
