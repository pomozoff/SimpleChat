//
//  SpringTableView.m
//  SpringTableView
//
//  Created by Christian Sampaio on 8/26/13.
//  Copyright (c) 2013 Christian Sampaio. All rights reserved.
//

#import "CFSSpringTableView.h"

@interface CFSSpringTableView()

@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) NSMutableDictionary *behaviors;

@end

static CGFloat const kSpringTableViewDefaultDamping = 0.8f;
static CGFloat const kSpringTableViewDefaultFrequency = 0.8f;
static CGFloat const kSpringTableViewDefaultResistance = 0.001f;

@implementation CFSSpringTableView

#pragma mark - Properties

- (NSMutableDictionary *)behaviors {
    if (!_behaviors) {
        _behaviors = [NSMutableDictionary dictionary];
    }
    return _behaviors;
}
- (UIDynamicAnimator *)dynamicAnimator {
    if (!_dynamicAnimator) {
        _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    }
    return _dynamicAnimator;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [self setup];
}

#pragma mark - Public

- (void)prepareCellForShow:(UITableViewCell *)cell {
    NSNumber *key = @([cell hash]);
    UIAttachmentBehavior *springBehavior = self.behaviors[key];
    if (springBehavior) {
        [self.dynamicAnimator removeBehavior:springBehavior];
    }
    springBehavior = [[UIAttachmentBehavior alloc] initWithItem:cell attachedToAnchor:cell.center];
    
    springBehavior.length = 0;
    springBehavior.damping = self.springDamping;
    springBehavior.frequency = self.springFrequency;
    [self.dynamicAnimator addBehavior:springBehavior];
    self.behaviors[key] = springBehavior;
    
    self.lastContentOffset = self.contentOffset;
}

#pragma mark - Private

- (void)setup {
    self.springDamping = kSpringTableViewDefaultDamping;
    self.springFrequency = kSpringTableViewDefaultFrequency;
    self.springResistance = kSpringTableViewDefaultResistance;
    
    [self.panGestureRecognizer addTarget:self action:@selector(onPan:)];
}
- (void)onPan:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state != UIGestureRecognizerStateBegan) {
        CGFloat scrollDelta = self.contentOffset.y - self.lastContentOffset.y;
        CGPoint touchLocation = [panGesture locationInView:self];
        
        for (UIAttachmentBehavior *spring in self.dynamicAnimator.behaviors) {
            UITableViewCell *currentItem = (UITableViewCell *)[spring.items firstObject];
            if ([self.visibleCells containsObject:(UITableViewCell *)currentItem]) {
                CGPoint anchorPoint = spring.anchorPoint;
                CGFloat touchDistance = fabs(touchLocation.y - anchorPoint.y);
                CGFloat resistanceFactor = self.springResistance;
                
                CGPoint center = currentItem.center;
                float resistedScroll = scrollDelta * touchDistance * resistanceFactor;
                float simpleScroll = scrollDelta;
                
                float actualScroll = MIN(fabsf(simpleScroll), fabsf(resistedScroll));
                if (simpleScroll < 0) {
                    actualScroll = fabsf(actualScroll);
                }
                
                center.y += actualScroll;
                currentItem.center = center;
                [self.dynamicAnimator updateItemUsingCurrentState:currentItem];
            }
        }
        
        self.lastContentOffset = (CGPoint){self.contentOffset.x, self.contentOffset.y};
    }
}
- (void)reloadData {
    [self.dynamicAnimator removeAllBehaviors];
    [super reloadData];
}

@end
