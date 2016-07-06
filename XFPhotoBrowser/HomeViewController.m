//
//  HomeViewController.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "HomeViewController.h"
#import "XFAssetsPhotoViewController.h"
#import "XFHUD.h"
#import "XFHomeCollectionViewCell.h"
#import "XFAssetsModel.h"
#import "XFPushAnimation.h"

static NSString *identifier = @"XFHomeCollectionViewCell";

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (assign, nonatomic) BOOL isEdit;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellWithReuseIdentifier:identifier];
    
    self.isEdit = NO;
}

- (IBAction)didRightBarButtonAction {
    self.isEdit = !self.isEdit;
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( 0 == indexPath.item ) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 75, 75)];
        label.font = [UIFont fontWithName:@"light" size:33];
        label.text = @"+";
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
        return cell;
    }else {
        XFHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        XFAssetsModel *model = self.dataArray[indexPath.item - 1];
        cell.model = model;
        cell.deleteButton.hidden = !self.isEdit;
        XFWeakSelf;
        cell.deleteBlock = ^(XFAssetsModel *dmodel) {
            [wself.collectionView performBatchUpdates:^{
                [wself.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                [wself.dataArray removeObject:model];
            } completion:^(BOOL finished) {
                [wself.collectionView reloadData];
            }];
        };
        cell.longPressBlock = ^(UILongPressGestureRecognizer *longPress) {
            switch (longPress.state) {
                case UIGestureRecognizerStateBegan:{
                    //判断手势落点位置是否在路径上
                    NSIndexPath *cindexPath = [wself.collectionView indexPathForItemAtPoint:[longPress locationInView:wself.collectionView]];
                    if (indexPath == nil) {
                        break;
                    }
                    //在路径上则开始移动该路径上的cell
                    [wself.collectionView beginInteractiveMovementForItemAtIndexPath:cindexPath];
                }
                    break;
                case UIGestureRecognizerStateChanged: {
                    //移动过程当中随时更新cell位置

                    NSIndexPath *cindexPath = [wself.collectionView indexPathForItemAtPoint:[longPress locationInView:wself.collectionView]];
                    if ( cindexPath.item != 0 ) {
                        [wself.collectionView updateInteractiveMovementTargetPosition:[longPress locationInView:wself.collectionView]];
                    }
                }
                    break;
                case UIGestureRecognizerStateEnded:
                    //移动结束后关闭cell移动
                    [wself.collectionView endInteractiveMovement];
                    break;
                default:
                    [wself.collectionView cancelInteractiveMovement];
                    [wself.collectionView reloadData];
                    break;
            }
        };
        cell.tapBlock = ^() {
            wself.isEdit = NO;
            [wself.collectionView reloadData];
        };
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( 0 == indexPath.item ) {
        
        [XFHUD showInOpenLibary];
        XFAssetsPhotoViewController *assetsPhotoViewController = [XFAssetsPhotoViewController new];
//        assetsPhotoViewController.maxPhotosNumber = 3;
        XFWeakSelf;
        assetsPhotoViewController.callback = ^(NSArray *selectedArray) {
            [wself.dataArray removeAllObjects];
            [wself.dataArray addObjectsFromArray:selectedArray];
            [wself.collectionView reloadData];
        };
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:assetsPhotoViewController];
        [self presentViewController:nav animated:YES completion:nil];
    }else {
        
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item == 0?NO:self.isEdit;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
//    NSLog(@"sourceIndexPath===%ld,destinationIndexPath===%ld",sourceIndexPath.item,destinationIndexPath.item);
    XFAssetsModel *model = [self.dataArray objectAtIndex:sourceIndexPath.item - 1];
    //从资源数组中移除该数据
    [self.dataArray removeObject:model];
    //将数据插入到资源数组中的目标位置上
    [self.dataArray insertObject:model atIndex:destinationIndexPath.item - 1];
}

- (NSMutableArray *)dataArray {
    if ( !_dataArray ) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
