//
//  Common.h
//  SimpleChat
//
//  Created by Антон on 05.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#ifndef Common_h
#define Common_h

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CollectionChangeInsert = 1,
    CollectionChangeDelete = 2,
    CollectionChangeMove   = 3,
    CollectionChangeUpdate = 4
} CollectionChangeType;

@protocol DataPresenter <NSObject>

@property (nonatomic, strong) NSBlockOperation *updateOperation;

- (void)reloadDataInSections:(NSIndexSet *)indexSet;
- (void)willChangeContent;
- (void)didChangeSectionatIndex:(NSUInteger)sectionIndex
                  forChangeType:(CollectionChangeType)type;
- (void)didChangeObject:(id)anObject
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(CollectionChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath;
- (void)didChangeContent;

@end

NS_ASSUME_NONNULL_END

#endif /* Common_h */
