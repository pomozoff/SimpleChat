//
//  ChatTableViewController.m
//  SimpleChat
//
//  Created by Anton Pomozov on 29.09.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ChatTableViewController.h"
#import "ChatTableViewCell.h"

@interface ChatTableViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation ChatTableViewController

#pragma mark - Constants

static NSString * const kCellReuseIdentifier = @"Chat Message Cell";

#pragma mark - Properties

@synthesize backgroundImage = _backgroundImage;

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    [self updateBackgroundImage:backgroundImage];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.chatDataSource numberOfSections];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatDataSource numberOfRowsInSection:section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    [self updateCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - Private

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ChatTableViewCell *chatCell = (ChatTableViewCell *)cell;
    
    chatCell.chatMessage = [self.chatDataSource chatMessageAtIndexPath:indexPath];
    chatCell.hasTail = [self.chatDataSource isLastMessage:indexPath];
}
- (void)updateBackgroundImage:(UIImage *)backgroundImage {
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;}

@end
