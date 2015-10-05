//
//  ChatTableViewController.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatTableViewController.h"
#import "ChatTableViewCell.h"

@interface ChatTableViewController () <UITextViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *userInputTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomImagesConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maxInputTextViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewImageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *chatIsEmptyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@property (nonatomic, assign) CGFloat imagesCollectionViewHeight;
@property (nonatomic, assign) CGFloat previewImageHeight;

@end

@implementation ChatTableViewController

#pragma mark - Constants

static NSString * const kMessageCellReuseIdentifier = @"Chat Message Cell";
static NSUInteger const kPercentOfUserInputTextHeight = 10;
static NSString * const kImageName = @"cat";

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    NSAssert(self == [(ChatManager *)self.chatHandler dataPresenter], @"Wrong Injection!");
    
    [self tuneUserInputView];
    [self addRefreshController];
    [self addHideKeyboardGestureRecognizer];
    [self reloadChatList];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.imagesCollectionViewHeight = self.imagesCollectionViewHeightConstraint.constant;
    self.previewImageHeight = self.previewImageHeightConstraint.constant;
    
    [self triggerImagesCollectionViewWithAnimation:YES];
    [self triggerImagePreviewView];
    [self animateConstraintsChanges];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self registerForKeyboardNotification];
    [self updateSendButtonState];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self deregisterKeyboardNotifications];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.chatDataSource numberOfSections];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsNumber = [self.chatDataSource numberOfRowsInSection:section];
    self.chatIsEmptyLabel.hidden = rowsNumber > 0;
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
    [self hideImagesCollectionView];
    return YES;
}

#pragma mark - Actions

- (IBAction)sendMessage:(UIButton *)sender {
    NSString *trimmedText = [self processTextToSend];
    __weak __typeof(self) weakSelf = self;
    [self.chatHandler sendTextMessage:trimmedText
                       withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                           if (succeeded) {
                               [weakSelf scrollMessagesUp];
                           } else {
                               NSLog(@"Failed to send message: %@ %@", error, error.userInfo);
                           }
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
                           if (succeeded) {
                               [weakSelf scrollMessagesUp];
                           } else {
                               NSLog(@"Failed to send message with image: %@ %@", error, error.userInfo);
                           }
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
        [chatCell updateImage:[UIImage imageNamed:@"placeholder"]];
    }
}
- (void)reloadChatList {
    __weak __typeof(self) weakSelf = self;
    [self.chatDataSource fetchMessagesWithCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 200 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                [weakSelf.tableView layoutIfNeeded];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf scrollMessagesUp];
                });
            });
        } else {
            NSLog(@"Failed to reload chat list: %@ %@", error, error.userInfo);
        }
    }];
}
- (NSString *)processTextToSend {
    NSString *trimmedText = [self.userInputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.userInputTextView.text = @"";
    [self updateSendButtonState];

    return trimmedText;
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
    
    self.bottomImagesConstraint.constant = isShowing ? endFrame.size.height : 0.0f;
    
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:animationCurve
                     animations: ^{
                         [weakSelf.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [weakSelf scrollMessagesUp];
                         }
                     }];
}
- (void)addHideKeyboardGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(hideOpenedViews)];
    [self.view addGestureRecognizer:tap];
}
- (void)hideOpenedViews {
    [self hideImagesCollectionView];
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
- (void)addRefreshController {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor purpleColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self
                       action:@selector(reloadChatList)
             forControlEvents:UIControlEventValueChanged];

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
- (void)scrollMessagesUp {
    NSInteger sectionsNumber = [self.chatDataSource numberOfSections];
    NSInteger rowsNumber = [self.chatDataSource numberOfRowsInSection:sectionsNumber - 1];
    if (rowsNumber > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:rowsNumber - 1 inSection:sectionsNumber - 1]
                              atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
- (void)animateConstraintsChanges {
    CGFloat damping = 0.7f;
    CGFloat velocity = 0.8f;

    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3f
                          delay:0.0f
         usingSpringWithDamping:damping
          initialSpringVelocity:velocity
                        options:0
                     animations:^{
                         [weakSelf.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [weakSelf scrollMessagesUp];
                         }
                     }];
}
- (void)triggerImagesCollectionViewWithAnimation:(BOOL)animation {
    self.imagesCollectionViewHeightConstraint.constant = (NSInteger)self.imagesCollectionViewHeightConstraint.constant == 0 ? self.imagesCollectionViewHeight : 0;
    [self.view setNeedsUpdateConstraints];
    [self dismissKeyboard];
    if (animation) {
        [self animateConstraintsChanges];
    }
}
- (void)triggerImagePreviewView {
    self.previewImageView.hidden = !self.previewImageView.hidden;
    self.previewImageHeightConstraint.constant = (NSInteger)self.previewImageHeightConstraint.constant == 0 ? self.imagesCollectionViewHeight : 0;
    [self.view setNeedsUpdateConstraints];
}
- (void)hideImagesCollectionView {
    if ((NSInteger)self.imagesCollectionViewHeightConstraint.constant == self.imagesCollectionViewHeight) {
        [self triggerImagesCollectionViewWithAnimation:YES];
    }
}

@end
