//
//  SimpleChatAssembly.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "SimpleChatAssembly.h"
#import "ParseDataSource.h"

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
        [definition injectProperty:@selector(remoteDataSource) with:[self parseDataSource]];
    }];
}

#pragma mark - Private

- (id <RemoteDataSource>)parseDataSource {
    return [TyphoonDefinition withClass:[ParseDataSource class] configuration:^(TyphoonDefinition *definition) {
        definition.scope = TyphoonScopeSingleton;
    }];
}

@end
