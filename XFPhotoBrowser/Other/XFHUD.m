//
//  XFHUD.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/6.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFHUD.h"
#import "SVProgressHUD.h"

@implementation XFHUD

+ (void)showInOpenLibary {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:0.3]];
    [SVProgressHUD setBackgroundLayerColor:[UIColor whiteColor]];
    [SVProgressHUD show];
}

+ (void)overMaxNumberWithNumber:(NSInteger)number {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setMinimumDismissTimeInterval:0.15];
    [SVProgressHUD setBackgroundLayerColor:[UIColor clearColor]];
    [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"选择图片不能超出%ld张",number]];
}

+ (void)dismiss {
    [SVProgressHUD dismiss];
}

@end
