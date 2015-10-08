//
//  ChatTableViewController.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatTableViewController.h"
#import "ChatTableViewCell.h"

typedef enum : NSUInteger {
    ScrollDirectionUp = 1,
    ScrollDirectionDown = 2,
} ScrollDirection;

@interface ChatTableViewController () <UITextViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maxInputTextViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *previewImageHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imagesCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesCollectionViewWidthConstraint;

@property (weak, nonatomic) IBOutlet UITextView *userInputTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *chatIsEmptyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIView *imagesCollectionView;

@end

@implementation ChatTableViewController

#pragma mark - Constants

static NSString * const kImageName = @"cat";
static NSString * const kImagePlaceholderName = @"placeholder";
static NSString * const kMessageCellReuseIdentifier = @"Chat Message Cell";
static NSUInteger const kPercentOfUserInputTextHeight = 10;
static int64_t const kUpdateLayoutTimeout = 200 * NSEC_PER_MSEC;

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    NSAssert(self == [(ChatManager *)self.chatHandler dataPresenter], @"Wrong Injection!");
    
    [self tuneUserInputView];
    [self addHideKeyboardGestureRecognizer];
    
    UIRefreshControl *refreshControl = [self addRefreshController];
    [self reloadChatList:refreshControl];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self setupConstraints];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self deregisterKeyboardNotifications];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotification];
    [self updateSendButtonState];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    __weak __typeof(self) weakSelf = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (weakSelf.imagesCollectionView.hidden) {
            [weakSelf hideImagesCollectionViewWithAnimation:NO];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [weakSelf scrollMessages:ScrollDirectionDown];
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.chatDataSource numberOfSections];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsNumber = [self.chatDataSource numberOfRowsInSection:section];
    return rowsNumber;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMessageCellReuseIdentifier forIndexPath:indexPath];
    [self tableView:tableView updateCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - Text view delegate

- (void)textViewDidChange:(UITextView *)textView {
    [self updateUserInputTextViewState:textView];
    [self updateSendButtonState];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self hideImagesCollectionViewWithAnimation:YES];
    return YES;
}

#pragma mark - Actions

- (IBAction)sendMessage:(UIButton *)sender {
    NSString *trimmedText = [self processTextToSend];
    __weak __typeof(self) weakSelf = self;
    [self.chatHandler sendTextMessage:trimmedText
                       withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (succeeded) {
                                   [weakSelf scrollMessages:ScrollDirectionDown];
                               } else {
                                   NSLog(@"Failed to send message: %@ %@", error, error.userInfo);
                               }
                           });
                       }];
}
- (IBAction)sendLocation:(UIBarButtonItem *)sender {
}
- (IBAction)makePhoto:(UIBarButtonItem *)sender {
}
- (IBAction)sendImage:(UIBarButtonItem *)sender {
    NSString *trimmedText = [self processTextToSend];
    __weak __typeof(self) weakSelf = self;
    [self.chatHandler sendTextMessage:trimmedText
                             andImage:[UIImage imageNamed:kImageName]
                       withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (succeeded) {
                                   [weakSelf scrollMessages:ScrollDirectionDown];
                               } else {
                                   NSLog(@"Failed to send message with image: %@ %@", error, error.userInfo);
                               }
                           });
                       }];
}
- (IBAction)selectImageFromGallery:(UIBarButtonItem *)sender {
    [self triggerImagesCollectionViewWithAnimation:YES];
}

#pragma mark - Private common

- (void)tableView:(nonnull UITableView *)tableView updateCell:(nonnull UITableViewCell *)cell atIndexPath:(nonnull NSIndexPath *)indexPath {
    ChatTableViewCell *chatCell = (ChatTableViewCell *)cell;
    id <ChatMessage> chatMessage = [self.chatDataSource chatMessageAtIndexPath:indexPath];
    
    chatCell.chatMessage = chatMessage;
    [chatCell updateImage:nil];
    
    if (chatMessage.hasImage) {
        [self tableView:tableView updateImageInCell:chatCell atIndexPath:indexPath];
    }
    chatCell.hasTail = [self.chatDataSource isLastMessage:indexPath];
}
- (void)tableView:(nonnull UITableView *)tableView updateImageInCell:(nonnull ChatTableViewCell *)chatCell atIndexPath:(nonnull NSIndexPath *)indexPath {
    id <ChatMessage> chatMessage = chatCell.chatMessage;
    if (chatMessage.image) {
        [chatCell updateImage:chatMessage.image];
    } else {
        [self.messageContoller fetchImageForChatMessage:chatMessage withCompletion:^(UIImage * _Nullable image, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ChatTableViewCell *oldChatCell = [tableView cellForRowAtIndexPath:indexPath];
                [oldChatCell updateImage:chatMessage.image];
                [tableView layoutIfNeeded];
            });
        }];
        [chatCell updateImage:[UIImage imageNamed:kImagePlaceholderName]];
    }
}
- (void)fetchMoreMessagesWithCompletion:(nullable CompletionHandler)handler {
    __weak __typeof(self) weakSelf = self;
    [self.chatDataSource fetchMoreMessagesWithCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf reloadDataInSections:[NSIndexSet indexSetWithIndex:0]];
            });
        } else {
            NSLog(@"Failed to fetch more mesages: %@ %@", error, error.userInfo);
        }
        if (handler) {
            handler(succeeded, error);
        }
    }];
}
- (void)updateLayoutForTableView:(UITableView *)tableView {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self animateConstraintsChangesDuration:0.1f withCompletion:^(BOOL finished) {
            if (finished) {
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView endUpdates];
                [weakSelf scrollMessages:ScrollDirectionDown];
            }
        }];
    });
}
- (void)reloadChatList:(UIRefreshControl *)refreshControl {
    __weak __typeof(self) weakSelf = self;
    [self.chatDataSource resetToNewestMessageWithCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [refreshControl beginRefreshing];
            [weakSelf fetchMoreMessagesWithCompletion:^(BOOL innerSucceeded, NSError * _Nullable innerError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (innerSucceeded) {
                        [weakSelf updateLayoutForTableView:weakSelf.tableView];
                    } else {
                        NSLog(@"Failed to fetch more mesages: %@ %@", innerError, innerError.userInfo);
                    }
                    [weakSelf finishRefreshing:refreshControl];
                });
            }];
        } else {
            NSLog(@"Failed to reset chat list to the newest message: %@ %@", error, error.userInfo);
        }
    }];
}
- (NSString *)processTextToSend {
    NSString *trimmedText = [self.userInputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.userInputTextView.text = @"";
    [self animateConstraintsChangesDuration:0.5f withCompletion:nil];
    [self updateSendButtonState];

    return trimmedText;
}
- (UIInterfaceOrientation)deviceOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

#pragma mark - Private keyboard

- (void)registerForKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)deregisterKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect endFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    BOOL isShowing = notification.name == UIKeyboardWillShowNotification;

    NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSNumber *animationCurveRawNSN = info[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationOptions animationCurve = animationCurveRawNSN == nil ? UIViewAnimationOptionCurveEaseInOut : [animationCurveRawNSN unsignedLongValue];
    
    self.imagesBottomConstraint.constant = isShowing ? endFrame.size.height : 0.0f;
    self.toolbarBottomConstraint.constant = self.imagesBottomConstraint.constant;
    
    [self.view setNeedsUpdateConstraints];
    
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:animationCurve
                     animations: ^{
                         [weakSelf.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [weakSelf scrollMessages:ScrollDirectionDown];
                         }
                     }];
}
- (void)addHideKeyboardGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(hideOpenedViews)];
    [self.tableView addGestureRecognizer:tap];
}
- (void)hideOpenedViews {
    [self hideImagesCollectionViewWithAnimation:YES];
    [self dismissKeyboard];
}
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Private interface

- (void)tuneUserInputView {
    self.userInputTextView.layer.borderWidth = 0.2f;
    self.userInputTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.userInputTextView.layer.cornerRadius = 5.0f;
}
- (void)refreshControllTriggered:(UIRefreshControl *)refreshControl {
    __weak __typeof(self) weakSelf = self;
    [self fetchMoreMessagesWithCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kUpdateLayoutTimeout), dispatch_get_main_queue(), ^{
                [weakSelf.tableView layoutIfNeeded];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView beginUpdates];
                    [weakSelf.tableView endUpdates];
                });
            });
        } else {
            NSLog(@"Failed to fetch more mesages: %@ %@", error, error.userInfo);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishRefreshing:refreshControl];
        });
    }];
}
- (UIRefreshControl *)addRefreshController {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(refreshControllTriggered:)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    return refreshControl;
}
- (void)updateUserInputTextViewState:(UITextView *)textView {
    CGRect rect = [textView.text boundingRectWithSize:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName: textView.font}
                                              context:nil];
    CGFloat maxHeight = self.maxInputTextViewConstraint.constant - self.maxInputTextViewConstraint.constant / kPercentOfUserInputTextHeight;
    self.userInputTextView.scrollEnabled = rect.size.height > maxHeight;
}
- (void)updateSendButtonState {
    self.sendButton.enabled = self.userInputTextView.text.length > 0;
}
- (void)scrollMessages:(ScrollDirection)scrollDirection {
    NSInteger sectionsNumber = [self.chatDataSource numberOfSections];
    NSInteger rowsNumber = [self.chatDataSource numberOfRowsInSection:sectionsNumber - 1];
    if (sectionsNumber > 0 && rowsNumber > 0) {
        NSInteger rowIndex = scrollDirection == ScrollDirectionUp ? 0 : rowsNumber - 1;
        UITableViewScrollPosition scrollPosition = scrollDirection == ScrollDirectionUp ? UITableViewScrollPositionTop : UITableViewScrollPositionBottom;
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:rowIndex inSection:sectionsNumber - 1]
                              atScrollPosition:scrollPosition animated:YES];
    }
}
- (void)triggerEmptyChatMessage {
    NSInteger sectionsNumber = [self.chatDataSource numberOfSections];
    NSInteger rowsNumber = [self.chatDataSource numberOfRowsInSection:sectionsNumber - 1];
    self.chatIsEmptyLabel.hidden = rowsNumber > 0;
}
- (void)finishRefreshing:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
    [self triggerEmptyChatMessage];
}

#pragma mark - Private Constraints

- (void)animateConstraintsChangesDuration:(CGFloat)duration withCompletion:(void (^)(BOOL))completion {
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration
                          delay:0.0f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:0.8f
                        options:0
                     animations:^{
                         [weakSelf.view layoutIfNeeded];
                     }
                     completion:completion];
}
- (void)animateConstraintDefault {
    __weak __typeof(self) weakSelf = self;
    [self animateConstraintsChangesDuration:0.5f withCompletion:^(BOOL finished) {
        if (finished) {
            [weakSelf scrollMessages:ScrollDirectionDown];
        }
    }];
}
- (BOOL)isConstraintVisible:(nonnull NSLayoutConstraint *)constraint {
    return [self.backgroundView.constraints containsObject:constraint];
}
- (void)triggerConstraint:(nonnull NSLayoutConstraint *)constraint {
    if ([self isConstraintVisible:constraint]) {
        [self.backgroundView removeConstraint:constraint];
    } else {
        [self.backgroundView addConstraint:constraint];
    }
    [self.view setNeedsUpdateConstraints];
}
- (void)hideConstraint:(nonnull NSLayoutConstraint *)constraint {
    if ([self isConstraintVisible:constraint]) {
        [self.backgroundView removeConstraint:constraint];
        [self.view setNeedsUpdateConstraints];
    }
}
- (NSLayoutConstraint *)currentImagesCollectionViewConstraint {
    UIInterfaceOrientation orientation = [self deviceOrientation];
    return UIInterfaceOrientationIsPortrait(orientation) ? self.imagesCollectionViewHeightConstraint : self.imagesCollectionViewWidthConstraint;
}
- (void)triggerImagesCollectionViewWithAnimation:(BOOL)animation {
    [self dismissKeyboard];

    self.imagesCollectionView.hidden = !self.imagesCollectionView.hidden;

    NSLayoutConstraint *constraint = [self currentImagesCollectionViewConstraint];
    [self triggerConstraint:constraint];

    if (animation) {
        [self animateConstraintDefault];
    }
}
- (void)triggerImagePreviewView {
    self.previewImageView.hidden = !self.previewImageView.hidden;
    
    NSLayoutConstraint *constraint = self.previewImageHeightConstraint;
    [self triggerConstraint:constraint];
}
- (void)hideImagesCollectionViewWithAnimation:(BOOL)animation {
    self.imagesCollectionView.hidden = YES;
    [self hideConstraint:self.imagesCollectionViewHeightConstraint];
    [self hideConstraint:self.imagesCollectionViewWidthConstraint];

    if (animation) {
        [self animateConstraintDefault];
    }
}
- (void)hideImagePreviewView {
    self.previewImageView.hidden = YES;
    [self hideConstraint:self.previewImageHeightConstraint];
}
- (void)setupConstraints {
    [self hideImagesCollectionViewWithAnimation:YES];
    [self hideImagePreviewView];
}

@end
