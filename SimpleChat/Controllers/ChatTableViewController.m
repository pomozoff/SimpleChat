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
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *chatIsEmptyLabel;

@end

@implementation ChatTableViewController

#pragma mark - Constants

static NSString * const kMessageCellReuseIdentifier = @"Chat Message Cell";
static NSUInteger const kPercentOfUserInputTextHeight = 10;
static NSString * const kImageName = @"cat";

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    NSAssert(self == [(ChatManager *)self.chatHandler chatPresenter], @"Wrong Injection!");
    
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self tuneUserInputView];
    [self addRefreshController];
    [self addHideKeyboardGestureRecognizer];
    [self reloadChatList];
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

#pragma mark - Actions

- (IBAction)sendMessage:(UIButton *)sender {
    NSString *trimmedText = [self processTextToSend];
    [self.chatHandler sendTextMessage:trimmedText
                       withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                           if (succeeded) {
                               [self scrollMessagesUp];
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
    [self.chatHandler sendTextMessage:trimmedText
                             andImage:[UIImage imageNamed:kImageName]
                       withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                           if (succeeded) {
                               [self scrollMessagesUp];
                           } else {
                               NSLog(@"Failed to send message with image: %@ %@", error, error.userInfo);
                           }
                       }];
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
            });
        }];
        [chatCell updateImage:[UIImage imageNamed:@"placeholder"]];
    }
}
- (void)reloadChatList {
    [self.chatDataSource fetchMessagesWithCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                [self scrollMessagesUp];
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
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:animationCurve
                     animations: ^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self scrollMessagesUp];
                         }
                     }];
}
- (void)addHideKeyboardGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
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

@end
