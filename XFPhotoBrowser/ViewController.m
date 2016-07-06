//
//  ViewController.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "ViewController.h"
#import "XFPhotoAlbumViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)didButtonAction:(UIButton *)sender {
    XFPhotoAlbumViewController *assetViewController = [XFPhotoAlbumViewController new];
    UINavigationController *assetNavigationController = [[UINavigationController alloc] initWithRootViewController:assetViewController];
    [self presentViewController:assetNavigationController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
