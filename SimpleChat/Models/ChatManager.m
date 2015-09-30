//
//  ChatManager.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatManager.h"

@interface ChatManager ()

@property (nonatomic, strong) NSArray *messages;

@end

@implementation ChatManager

#pragma mark - Initialization

- (instancetype)init {
    if (self = [super init]) {
        self.messages = @[@"Привет", @"Это длинное сообщение для проверки корректности определения высоты ячейки", @"Пока"];
    }
    return self;
}

#pragma mark - ChatDataSource

- (NSInteger)numberOfSections {
    return 1;
}
- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}
- (id <ChatMessage>)chatMessageAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *chatMessage = [[ChatMessage alloc] initWithText:self.messages[indexPath.row]];
    return chatMessage;
}

@end
