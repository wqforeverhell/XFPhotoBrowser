//
//  XFAssetsLibraryAccessFailureView.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFAssetsLibraryAccessFailureView.h"

@implementation XFAssetsLibraryAccessFailureView

+ (instancetype)makeView {
    return loadSelfXib;
}

- (void)awakeFromNib {
    
}

- (IBAction)didPushPrivilegeButtonAction:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}


@end
