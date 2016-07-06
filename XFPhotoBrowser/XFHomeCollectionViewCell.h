//
//  XFHomeCollectionViewCell.h
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/6.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XFAssetsModel;

typedef void(^DeleteBlock)(XFAssetsModel *model);
typedef void(^LongPressBlock)(UILongPressGestureRecognizer *longPress);
typedef void(^TapBlock)();

@interface XFHomeCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (strong, nonatomic) XFAssetsModel *model;
@property (copy, nonatomic) DeleteBlock deleteBlock;
@property (copy, nonatomic) LongPressBlock longPressBlock;
@property (copy, nonatomic) TapBlock tapBlock;
@end
