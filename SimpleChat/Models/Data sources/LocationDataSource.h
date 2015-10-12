//
//  LocationDataSource.h
//  SimpleChat
//
//  Created by Антон on 13.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

@import Foundation;

#import "ChatMessage.h"

@protocol LocationDataSource <NSObject>

- (void)makeImageLocationForChatMessage:(id <ChatMessage>)chatMessage forSize:(CGSize)size withCompletion:(FetchImageCompletionHandler)handler;

@end

@interface LocationDataSource : NSObject <LocationDataSource>

@end
