//
//  SimpleChatAssembly.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "SimpleChatAssembly.h"
#import "ParseMessagesDataSource.h"
#import "LocalImagesDataSource.h"

@implementation SimpleChatAssembly

#pragma mark - Public

- (ChatTableViewController *)chatTableViewController {
    return [TyphoonDefinition withClass:[ChatTableViewController class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition injectProperty:@selector(chatDataSource) with:[self chatManager]];
                              [definition injectProperty:@selector(chatHandler) with:[self chatManager]];
                              [definition injectProperty:@selector(messageContoller) with:[self chatManager]];
                          }];
}
- (ChatManager *)chatManager {
    return [TyphoonDefinition withClass:[ChatManager class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(dataPresenter) with:[self chatTableViewController]];
        [definition injectProperty:@selector(messagesDataSource) with:[self parseMessagesDataSource]];
    }];
}

- (ImagesCollectionViewController *)imagesCollectionViewController {
    return [TyphoonDefinition withClass:[ImagesCollectionViewController class]
                          configuration:^(TyphoonDefinition *definition) {
                              [definition injectProperty:@selector(imagesCollectionDataSource) with:[self imagesCollectionManager]];
                          }];
}
- (ImagesCollectionManager *)imagesCollectionManager {
    return [TyphoonDefinition withClass:[ImagesCollectionManager class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(dataPresenter) with:[self imagesCollectionViewController]];
        [definition injectProperty:@selector(imagesDataSource) with:[self localImagesDataSource]];
    }];
}

#pragma mark - Private

- (id <MessagesDataSource>)parseMessagesDataSource {
    return [TyphoonDefinition withClass:[ParseMessagesDataSource class] configuration:^(TyphoonDefinition *definition) {
        definition.scope = TyphoonScopeSingleton;
    }];
}
- (id <ImagesDataSource>)localImagesDataSource {
    return [TyphoonDefinition withClass:[LocalImagesDataSource class] configuration:^(TyphoonDefinition *definition) {
        definition.scope = TyphoonScopeSingleton;
    }];
}

@end
