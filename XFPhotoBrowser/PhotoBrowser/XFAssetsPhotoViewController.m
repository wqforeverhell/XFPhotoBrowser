//
//  XFAssetsPhotoViewController.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFAssetsPhotoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "XFAssetsModel.h"
#import "XFSelectedAssetsView.h"
#import "XFAssetsCollectionViewCell.h"
#import "XFTakePhotoCollectionViewCell.h"
#import "XFAssetsModel.h"
#import "UIView+SDAutoLayout.h"

static NSString *firstItemIdentifier = @"XFTakePhotoCollectionViewCell";
static NSString *aidentifier = @"XFAssetsCollectionViewCell";

@interface XFAssetsPhotoViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) XFSelectedAssetsView *selectedAssetsView;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@end

@implementation XFAssetsPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(didCancelBarButtionAction)];
    
    [self.collectionView registerNib:[UINib nibWithNibName:firstItemIdentifier bundle:nil] forCellWithReuseIdentifier:firstItemIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:aidentifier bundle:nil] forCellWithReuseIdentifier:aidentifier];
    
    self.selectedAssetsView = [XFSelectedAssetsView makeView];
    XFWeakSelf;
    self.selectedAssetsView.deleteAssetsBlock = ^(XFAssetsModel *model) {
        for ( XFAssetsModel *dmodel in wself.dataArray ) {
            if ( [dmodel.asset isEqual:model.asset] ) {
                dmodel.selected = NO;
                break;
            }
        }
        [wself.collectionView reloadData];
    };
    [self.bottomView addSubview:self.selectedAssetsView];
    self.selectedAssetsView.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    
    [self setupAssets];
}

- (void)didCancelBarButtionAction {
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
}

- (void)setupAssets {
    [self.dataArray removeAllObjects];
    XFWeakSelf;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if ( asset ) {
                if ( [[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto] ) {
                    XFAssetsModel *model = [XFAssetsModel getModelWithData:asset];
                    [wself.dataArray addObject:model];
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself.collectionView reloadData];
                });
            }
        };
        //    //指定操作方式的，遍历。操作方式有：
        //    //NSEnumerationConcurrent：同步的方式遍历
        //    //NSEnumerationReverse：倒序的方式遍历
//        [wself.assetsGroup enumerateAssetsUsingBlock:resultsBlock];   //最简单的遍历,按默认排序
        [wself.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:resultsBlock];
    });
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( 0 == indexPath.item ) {
        XFTakePhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:firstItemIdentifier forIndexPath:indexPath];
        return cell;
    }else {
        XFAssetsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:aidentifier forIndexPath:indexPath];
        XFAssetsModel *model = self.dataArray[indexPath.item - 1];
        cell.model = model;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( 0 == indexPath.item ) {
        
    }else {
        XFAssetsModel *model = self.dataArray[indexPath.item - 1];
        if ( model.selected ) {
            [self.selectedAssetsView deleteModelWithModel:model];
        }else {
            [self.selectedAssetsView addModelWithModel:model];
        }
        model.selected = !model.selected;
        [self.collectionView reloadData];
    }
}

- (NSMutableArray *)dataArray {
    if ( !_dataArray ) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)selectedArray {
    if ( !_selectedArray ) {
        _selectedArray = [NSMutableArray array];
    }
    return _selectedArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
