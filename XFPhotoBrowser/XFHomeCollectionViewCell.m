//
//  XFHomeCollectionViewCell.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/6.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFHomeCollectionViewCell.h"
#import "XFAssetsModel.h"

@interface XFHomeCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation XFHomeCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressImageView:)];
    [self.imageView addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
    [self.imageView addGestureRecognizer:tap];
}

- (void)setModel:(XFAssetsModel *)model {
    _model = model;
    
    self.imageView.image = model.thumbnailImage;
}

- (void)longPressImageView:(UILongPressGestureRecognizer *)press {
    if ( self.longPressBlock ) {
        self.longPressBlock(press);
    }
}

- (void)tapImageView:(UITapGestureRecognizer *)tap {
    if ( self.tapBlock ) {
        self.tapBlock();
    }
}

- (IBAction)didDeleteButtonAction:(UIButton *)sender {
    if ( self.deleteBlock ) {
        self.deleteBlock(self.model);
    }
}

@end
