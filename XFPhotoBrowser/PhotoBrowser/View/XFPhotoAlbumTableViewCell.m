//
//  XFPhotoAlbumTableViewCell.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFPhotoAlbumTableViewCell.h"
#import "XFAssetsLibraryModel.h"

@interface XFPhotoAlbumTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *photoNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;

@end

@implementation XFPhotoAlbumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(XFAssetsLibraryModel *)model {
    _model = model;
    
    self.groupImageView.image = model.image;
    self.photoNumberLabel.text = [NSString stringWithFormat:@"%@张",model.photosNumber];
    self.groupNameLabel.text = model.groupName;
}

- (void)dealloc {
    self.model = nil;
    self.groupImageView = nil;
    self.photoNumberLabel = nil;
    self.groupNameLabel = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
