//
//  SimpleChatAssembly.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "SimpleChatAssembly.h"

@implementation SimpleChatAssembly

#pragma mark - Public

- (ChatTableViewController *)chatTableViewController {
    return [TyphoonDefinition withClass:[ChatTableViewController class] configuration:^(TyphoonDefinition *definition) {
        [definition injectProperty:@selector(chatDataSource) with:[self chatDataSourceGenerator]];
    }];
}

#pragma mark - Private

- (id <ChatDataSource>)chatDataSourceGenerator {
    return [TyphoonDefinition withClass:[ChatManager class]];
}

@end
