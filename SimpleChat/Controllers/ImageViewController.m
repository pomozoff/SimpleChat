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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Image presenter

- (void)presentImage:(UIImage *)image {
    self.imageView.image = image;
}

@end
