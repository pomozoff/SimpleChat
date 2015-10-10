//
//  ImageViewController.m
//  SimpleChat
//
//  Created by Anton Pomozov on 09.10.15.
//  Copyright © 2015 Akademon Ltd. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ImageViewController

#pragma mark - Life cycle

- (instancetype)init {
    self = [super init];
    NSLog(@"Init self = %@", self);
    return self;
}
- (void)awakeFromNib {
    NSLog(@"Awake self = %@", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"View did load self = %@", self);
    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Image presenter

- (void)presentImage:(UIImage *)image {
    NSLog(@"Present self = %@", self);
    self.imageView.image = image;
}

@end
