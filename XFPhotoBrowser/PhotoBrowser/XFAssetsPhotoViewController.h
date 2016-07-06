//
//  XFAssetsPhotoViewController.h
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALAssetsGroup;

typedef void(^CallBack)(NSArray *selectedArray);

@interface XFAssetsPhotoViewController : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
/**
 *  选择图片的最大数,如果不设置就不作限制
 */
@property (assign, nonatomic) NSInteger maxPhotosNumber;

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property (copy, nonatomic) CallBack callback;
@end
