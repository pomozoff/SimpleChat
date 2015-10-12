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
#import "LocationManager.h"

@implementation SimpleChatAssembly

#pragma mark - Public

- (ChatTableViewController *)chatTableViewController {
    return [TyphoonDefinition withClass:[ChatTableViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(chatDataSource) with:[self chatManager]];
        [definition injectProperty:@selector(chatHandler) with:[self chatManager]];
        [definition injectProperty:@selector(messageContoller) with:[self chatManager]];
        [definition injectProperty:@selector(locationManager) with:[self locationManager]];

        definition.scope = TyphoonScopeLazySingleton;
    }];
}
- (ChatManager *)chatManager {
    return [TyphoonDefinition withClass:[ChatManager class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(dataPresenter) with:[self chatTableViewController]];
        [definition injectProperty:@selector(messagesDataSource) with:[self parseMessagesDataSource]];

        definition.scope = TyphoonScopeLazySingleton;
    }];
}
- (ImagesCollectionViewController *)imagesCollectionViewController {
    return [TyphoonDefinition withClass:[ImagesCollectionViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(imagesCollectionDataSource) with:[self imagesCollectionManager]];
        [definition injectProperty:@selector(imageHandlerRouter) with:[self imageRouter]];
        
        definition.scope = TyphoonScopeLazySingleton;
    }];
}
- (ImagesCollectionManager *)imagesCollectionManager {
    return [TyphoonDefinition withClass:[ImagesCollectionManager class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(dataPresenter) with:[self imagesCollectionViewController]];
        [definition injectProperty:@selector(imagesDataSource) with:[self localImagesDataSource]];
        
        definition.scope = TyphoonScopeLazySingleton;
    }];
}

#pragma mark - Private

- (id <MessagesDataSource>)parseMessagesDataSource {
    return [TyphoonDefinition withClass:[ParseMessagesDataSource class] configuration:^(TyphoonDefinition *definition) {
        definition.scope = TyphoonScopeLazySingleton;
    }];
}
- (id <ImagesDataSource>)localImagesDataSource {
    return [TyphoonDefinition withClass:[LocalImagesDataSource class] configuration:^(TyphoonDefinition *definition) {
        definition.scope = TyphoonScopeLazySingleton;
    }];
}
- (id <ImageHandlerRouter>)imageRouter {
    return [TyphoonDefinition withClass:[ImageRouter class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(imageProcessor) with:[self chatTableViewController]];
        
        definition.scope = TyphoonScopeLazySingleton;
    }];
}
- (id <LocationManager>)locationManager {
    return [TyphoonDefinition withClass:[LocationManager class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(locationManager) with:[[CLLocationManager alloc] init]];
        definition.scope = TyphoonScopeLazySingleton;
    }];
}

@end
