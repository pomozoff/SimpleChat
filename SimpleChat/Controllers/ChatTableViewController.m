//
//  ChatTableViewController.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatTableViewController.h"
#import "ChatTableViewCell.h"

@interface ChatTableViewController () <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *userInputTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *chatIsEmptyLabel;
@property (weak, nonatomic) IBOutlet UIView *transparentView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *imagesButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *geoButton;

@property (strong, nonatomic) IBOutlet UIView *cameraPreviewContainerView;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIView *imagesCollectionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maxInputTextViewConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraPreviewContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraPreviewFullscreenConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesCollectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesCollectionViewWidthConstraint;

//@property (nonatomic, strong) id <ImagePresenter> imagePresenter;
@property (nonatomic, strong) id <CameraPresenter> cameraPresenter;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation ChatTableViewController

#pragma mark - Constants

static NSString * const kImagePlaceholderName = @"placeholder";
static NSString * const kMessageCellReuseIdentifier = @"Chat Message Cell";
static NSString * const kCameraSegueName = @"Camera Embedded Segue";
static NSString * const kImageSegueName = @"Image Embedded Segue";
static NSString * const kImagesCollectionSegueName = @"Images Collection Embedded Segue";
static NSUInteger const kPercentOfUserInputTextHeight = 10;
static UILayoutPriority const kMaxConstraintPriority = 800;
static UILayoutPriority const kMinConstraintPriority = 200;

static UILayoutPriority const kMaxMaxConstraintPriority = 900;
static UILayoutPriority const kMinMinConstraintPriority = 100;

static int64_t const kUpdateLayoutTimeout = 200 * NSEC_PER_MSEC;

#pragma mark - Properties

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self tuneUserInputView];
    [self addHideKeyboardGestureRecognizer];
    [self reloadChatList:[self addRefreshController]];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self hideAllPanesWithAnimation:YES];
    
    [self disableScrollsToTopPropertyOnAllSubviewsOf:self.view];
    self.tableView.scrollsToTop = YES;
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

    [self hideAllPanesWithAnimation:YES];
    self.imagePickerController = nil;
    [self.chatHandler freeMemory];
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    //__weak __typeof(self) weakSelf = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view layoutIfNeeded];
        });
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf scrollTable:ScrollDirectionDown];
        });
        */
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kCameraSegueName]) {
        self.cameraPresenter = segue.destinationViewController;
        self.cameraPresenter.cameraProcessor = self;
    } else if ([segue.identifier isEqualToString:kImagesCollectionSegueName]) {
        self.imagesCollectionPresenter = segue.destinationViewController;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.chatDataSource numberOfSections];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = [self.chatDataSource numberOfRowsInSection:section];
    return numberOfRows;
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
    [self hideAllPanesWithAnimation:YES];
    return YES;
}

#pragma mark - Image processor

- (void)processImage:(UIImage *)image {
    NSString *trimmedText = [self processTextToSend];
    [self sendText:trimmedText withImage:image];
    [self hideImagesCollectionViewWithAnimation:YES];
}

#pragma mark - Camera processor

- (void)toggleFullscreen {
    if (self.cameraPreviewFullscreenConstraint.priority < kMinConstraintPriority) {
        self.cameraPreviewFullscreenConstraint.priority = kMaxMaxConstraintPriority;
    } else {
        self.cameraPreviewFullscreenConstraint.priority = kMinMinConstraintPriority;
    }
    [self animateConstraintDefaultWithScroll:YES];
}
- (void)sendPhoto:(UIImage *)image {
    NSString *trimmedText = [self processTextToSend];
    [self sendText:trimmedText withImage:image];
    [self hideCameraPreviewViewWithAnimation:YES];
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController * _Nonnull)picker didFinishPickingMediaWithInfo:(NSDictionary <NSString *, id> * _Nonnull)info {
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];

    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSString *trimmedText = [self processTextToSend];
    [self sendText:trimmedText withImage:image];
}

#pragma mark - Actions

- (IBAction)sendMessage:(UIButton *)sender {
    NSString *trimmedText = [self processTextToSend];
    [self sendText:trimmedText];
}
- (IBAction)sendLocation:(UIBarButtonItem *)sender {
    NSString *trimmedText = [self processTextToSend];
    [self sendText: trimmedText withCoordinate:[self.locationManager currentCoordinate]];
}
- (IBAction)selectImageFromList:(UIBarButtonItem *)sender {
    [self triggerImagesCollectionViewWithAnimation:YES];
}
- (IBAction)selectImageFromGallery:(UIButton *)sender {
    self.imagePickerController.allowsEditing = NO;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}
- (IBAction)switchCameraOn:(UIBarButtonItem *)sender {
    [self triggerCameraPreviewViewWithAnimation:YES];
    [self.cameraPresenter showCamera];
}

#pragma mark - Private common

- (void)tableView:(nonnull UITableView *)tableView updateCell:(nonnull UITableViewCell *)cell atIndexPath:(nonnull NSIndexPath *)indexPath {
    ChatTableViewCell *chatCell = (ChatTableViewCell *)cell;
    id <ChatMessage> chatMessage = [self.chatDataSource chatMessageAtIndexPath:indexPath];
    
    chatCell.chatMessage = chatMessage;
    [chatCell updateImage:nil];
    
    if (chatMessage.hasImage || chatMessage.hasLocation) {
        [chatCell showProgress];
        if (chatMessage.hasImage) {
            [self tableView:tableView updateImageInCell:chatCell atIndexPath:indexPath];
        }
        if (chatMessage.hasLocation) {
            [self tableView:tableView updateImageLocationInCell:chatCell atIndexPath:indexPath];
        }
    }
    chatCell.hasTail = [self.chatDataSource isLastMessage:indexPath];
}
- (void)tableView:(nonnull UITableView *)tableView updateImageInCell:(nonnull ChatTableViewCell *)chatCell atIndexPath:(nonnull NSIndexPath *)indexPath {
    id <ChatMessage> chatMessage = chatCell.chatMessage;
    if (chatMessage.image) {
        [chatCell updateImage:chatMessage.image];
        [chatCell hideProgress];
    } else {
        [self.messageContoller fetchImageForChatMessage:chatMessage withCompletion:^(UIImage * _Nullable image, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ChatTableViewCell *oldChatCell = [tableView cellForRowAtIndexPath:indexPath];
                [oldChatCell hideProgress];
                [oldChatCell updateImage:image];
                [tableView layoutIfNeeded];
            });
        }];
        [chatCell updateImage:[UIImage imageNamed:kImagePlaceholderName]];
    }
}
- (void)tableView:(nonnull UITableView *)tableView updateImageLocationInCell:(nonnull ChatTableViewCell *)chatCell atIndexPath:(nonnull NSIndexPath *)indexPath {
    id <ChatMessage> chatMessage = chatCell.chatMessage;
    if (chatMessage.image) {
        [chatCell updateImage:chatMessage.image];
        [chatCell hideProgress];
    } else {
        [self.messageContoller makeImageLocationForChatMessage:chatMessage
                                                       forSize:chatCell.locationPreviewSize
                                                withCompletion:^(UIImage * _Nullable image, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ChatTableViewCell *oldChatCell = [tableView cellForRowAtIndexPath:indexPath];
                [oldChatCell hideProgress];
                [oldChatCell updateImage:image];
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
                [weakSelf scrollTable:ScrollDirectionDown];
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

- (void)sendText:(NSString *)text {
    __weak __typeof(self) weakSelf = self;
    [self.chatHandler sendTextMessage:text
                       withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (succeeded) {
                                   weakSelf.scrollToIndexPath = [self.chatDataSource lastIndexPath];
                               } else {
                                   NSLog(@"Failed to send text: %@, error: %@, %@", text, error, error.userInfo);
                               }
                           });
                       }];
}
- (void)sendText:(NSString *)text withImage:(UIImage *)image {
    __weak __typeof(self) weakSelf = self;
    [self.chatHandler sendTextMessage:text
                             andImage:image
                       withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (succeeded) {
                                   weakSelf.scrollToIndexPath = [self.chatDataSource lastIndexPath];
                               } else {
                                   NSLog(@"Failed to send text: %@ with image: %@, error: %@, %@", text, image, error, error.userInfo);
                               }
                           });
                       }];
}
- (void)sendText:(NSString *)text withCoordinate:(CLLocationCoordinate2D)coordinate {
    __weak __typeof(self) weakSelf = self;
    [self.chatHandler sendTextMessage:text
                          andLocation:coordinate
                       withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if (succeeded) {
                                   weakSelf.scrollToIndexPath = [self.chatDataSource lastIndexPath];
                               } else {
                                   NSLog(@"Failed to send text: %@ with coordinate, error: %@, %@", text, error, error.userInfo);
                               }
                           });
                       }];
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
    self.transparentView.hidden = !isShowing;

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
                         if (finished && isShowing) {
                             [weakSelf scrollTable:ScrollDirectionDown];
                         }
                     }];
}
- (void)addHideKeyboardGestureRecognizer {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(hideOpenedViews)];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(hideOpenedViews)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.transparentView addGestureRecognizer:tap];
    [self.transparentView addGestureRecognizer:swipe];
}
- (void)hideOpenedViews {
    [self hidePanesOnTapWithAnimation:YES];
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
- (void)triggerEmptyChatMessage {
    NSInteger numberOfSections = [self.chatDataSource numberOfSections];
    NSInteger numberOfRows = [self.chatDataSource numberOfRowsInSection:numberOfSections - 1];
    self.chatIsEmptyLabel.hidden = numberOfRows > 0;
}
- (void)finishRefreshing:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
    [self triggerEmptyChatMessage];
}
- (void)disableScrollsToTopPropertyOnAllSubviewsOf:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)subview).scrollsToTop = NO;
        }
        [self disableScrollsToTopPropertyOnAllSubviewsOf:subview];
    }
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
- (void)animateConstraintDefaultWithScroll:(BOOL)needsToScroll {
    __weak __typeof(self) weakSelf = self;
    [self animateConstraintsChangesDuration:0.5f withCompletion:^(BOOL finished) {
        if (finished && needsToScroll) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf scrollTable:ScrollDirectionDown];
            });
        }
    }];
}
- (BOOL)isConstraintPrioritized:(nonnull NSLayoutConstraint *)constraint {
    return constraint.priority >= kMaxConstraintPriority;
}
- (BOOL)isImagesViewCollectionPresent {
    return [self isConstraintPrioritized:self.imagesCollectionViewHeightConstraint] || [self isConstraintPrioritized:self.imagesCollectionViewWidthConstraint];
}
- (BOOL)isCameraPreviewContainerPresent {
    return [self isConstraintPrioritized:self.cameraPreviewContainerHeightConstraint];
}
- (void)triggerConstraint:(nonnull NSLayoutConstraint *)constraint {
    if ([self isConstraintPrioritized:constraint]) {
        constraint.priority = kMinConstraintPriority;
    } else {
        constraint.priority = kMaxConstraintPriority;
    }
    [self.view setNeedsUpdateConstraints];
}
- (void)triggerView:(UIView *)view withConstraint:(NSArray <NSLayoutConstraint *> *)constraints withScroll:(BOOL)needsToScroll andAnimation:(BOOL)animation {
    [self dismissKeyboard];
    
    for (NSLayoutConstraint *constraint in constraints) {
        [self triggerConstraint:constraint];
    }
    if (animation) {
        [self animateConstraintDefaultWithScroll:needsToScroll];
    }
}
- (void)triggerImagesCollectionViewWithAnimation:(BOOL)animation {
    BOOL needsToScroll = UIInterfaceOrientationIsPortrait([self deviceOrientation]);
    BOOL isShowing = !([self isConstraintPrioritized:self.imagesCollectionViewHeightConstraint] || [self isConstraintPrioritized:self.imagesCollectionViewWidthConstraint]);
    
    [self triggerView:self.imagesCollectionView
       withConstraint:@[self.imagesCollectionViewHeightConstraint, self.imagesCollectionViewWidthConstraint]
           withScroll:(needsToScroll && isShowing)
         andAnimation:animation];

    self.cameraButton.enabled = !isShowing;
    self.geoButton.enabled = !isShowing;
    
    if (isShowing) {
        [self.imagesCollectionPresenter reloadImages];
    }
    self.transparentView.hidden = !isShowing;
}
- (void)triggerCameraPreviewViewWithAnimation:(BOOL)animation {
    BOOL needsToScroll = UIInterfaceOrientationIsPortrait([self deviceOrientation]);
    BOOL isShowing = ![self isConstraintPrioritized:self.cameraPreviewContainerHeightConstraint];
    
    [self triggerView:self.cameraPreviewContainerView
       withConstraint:@[self.cameraPreviewContainerHeightConstraint]
           withScroll:(needsToScroll && isShowing)
         andAnimation:animation];
    self.transparentView.hidden = !isShowing;
}
- (void)hideImagesCollectionViewWithAnimation:(BOOL)animation {
    self.imagesCollectionViewHeightConstraint.priority = kMinConstraintPriority;
    self.imagesCollectionViewWidthConstraint.priority = kMinConstraintPriority;
    
    self.cameraButton.enabled = YES;
    self.geoButton.enabled = YES;

    if (animation) {
        [self animateConstraintDefaultWithScroll:NO];
    }
    self.transparentView.hidden = YES;
}
- (void)hideCameraPreviewViewWithAnimation:(BOOL)animation {
    self.cameraPreviewFullscreenConstraint.priority = kMinMinConstraintPriority;
    self.cameraPreviewContainerHeightConstraint.priority = kMinConstraintPriority;

    if (animation) {
        [self animateConstraintDefaultWithScroll:NO];
    }
    self.transparentView.hidden = YES;
}
- (void)hideAllPanesWithAnimation:(BOOL)animation {
    [self hideImagesCollectionViewWithAnimation:animation];
    [self hideCameraPreviewViewWithAnimation:animation];
}
- (void)hidePanesOnTapWithAnimation:(BOOL)animation {
    if ([self isCameraPreviewContainerPresent]) {
        [self hideCameraPreviewViewWithAnimation:animation];
        [self.cameraPresenter stopCamera];
    } else if ([self isImagesViewCollectionPresent]) {
        if (UIInterfaceOrientationIsPortrait([self deviceOrientation])) {
            [self hideImagesCollectionViewWithAnimation:animation];
        }
    }
}

@end
