//
//  XFSelectedAssetsView.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFSelectedAssetsView.h"
#import "XFAssetsModel.h"
#import "XFSelectedAssetsCollectionViewCell.h"

static NSString *identifier = @"XFSelectedAssetsCollectionViewCell";

@interface XFSelectedAssetsView ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@property (strong, nonatomic) NSMutableArray *dataArray;
@end

@implementation XFSelectedAssetsView

+ (instancetype)makeView {
    return loadSelfXib;
}

- (void)awakeFromNib {
    [self.collectionView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellWithReuseIdentifier:identifier];
    self.confirmButton.titleLabel.numberOfLines = 0;
}

- (void)setMaxPhotosNumber:(NSInteger)maxPhotosNumber {
    _maxPhotosNumber = maxPhotosNumber;
    
    self.numberLabel.text = [NSString stringWithFormat:@"0/%ld",maxPhotosNumber];
}

- (void)removeData {
    [self.dataArray removeAllObjects];
    [self.collectionView reloadData];
}

#pragma mark - 确定按钮事件
- (IBAction)didConfirmButtonAction:(UIButton *)sender {
    if ( self.confirmBlock ) {
        self.confirmBlock();
    }
}

- (void)addModelWithData:(NSArray<XFAssetsModel *> *)data {
    XFWeakSelf;
    
    [self.collectionView performBatchUpdates:^{
        NSMutableArray *tempArray = [NSMutableArray array];
        for ( int i = 0; i < data.count ; i++ ) {
            [tempArray addObject:[NSIndexPath indexPathForItem:wself.dataArray.count + i inSection:0]];
        }
        [wself.dataArray addObjectsFromArray:data];
        [wself.collectionView insertItemsAtIndexPaths:[tempArray copy]];
    } completion:^(BOOL finished) {
        [wself.collectionView reloadData];
        if ( wself.dataArray.count ) {
            [wself.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:wself.dataArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }
        [wself setupButtonTitle];
    }];
}

- (void)deleteModelWithData:(NSArray<XFAssetsModel *> *)data {
    XFWeakSelf;
    [self.collectionView performBatchUpdates:^{
        NSMutableArray *tempArray = [NSMutableArray array];
        NSArray *tempData = [self.dataArray copy];
        for ( XFAssetsModel *model in data ) {
            for (int i = 0; i < tempData.count; i++ ) {
                XFAssetsModel *dmodel = tempData[i];
                if ( [model.modelID isEqual: dmodel.modelID] ) {
                    NSLog(@"%d",i);
                    [tempArray addObject:[NSIndexPath indexPathForItem:i inSection:0]];
                    [wself.dataArray removeObjectAtIndex:i];
                }
            }
        }
        [wself.collectionView deleteItemsAtIndexPaths:[tempArray copy]];
    } completion:^(BOOL finished) {
        [wself.collectionView reloadData];
        if ( wself.dataArray.count ) {
            [wself.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:wself.dataArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }
        [wself setupButtonTitle];
    }];
}

- (void)setupButtonTitle {
    if ( self.maxPhotosNumber != 0 ) {
        self.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.dataArray.count,self.maxPhotosNumber];
    }else {
        self.numberLabel.text = [NSString stringWithFormat:@"%ld",self.dataArray.count];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XFSelectedAssetsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    XFAssetsModel *model = self.dataArray[indexPath.item];
    cell.model = model;
    XFWeakSelf;
    cell.deleteAssetBlock = ^(XFAssetsModel *deleteModel) {
        [wself deleteModelWithData:@[deleteModel]];
        if ( wself.deleteAssetsBlock ) {
            wself.deleteAssetsBlock(deleteModel);
        }
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( 0 == indexPath.item ) {
        
    }
}

- (NSMutableArray *)dataArray {
    if ( !_dataArray ) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)dealloc {
    [self.dataArray removeAllObjects];
    self.dataArray = nil;
}

@end
