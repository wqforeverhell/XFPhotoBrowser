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
#import "XFHUD.h"
#import "XFAssetsLibraryModel.h"
#import "XFAssetsLibraryData.h"
#import "XFAssetsLibraryAccessFailureView.h"
#import "XFPhotoAlbumViewController.h"
#import "XFPushAnimation.h"

static NSString *firstItemIdentifier = @"XFTakePhotoCollectionViewCell";
static NSString *aidentifier = @"XFAssetsCollectionViewCell";

@interface XFAssetsPhotoViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) XFSelectedAssetsView *selectedAssetsView;

@property (strong, nonatomic) NSMutableArray *groupArray;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@end

@implementation XFAssetsPhotoViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:[UINib nibWithNibName:firstItemIdentifier bundle:nil] forCellWithReuseIdentifier:firstItemIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:aidentifier bundle:nil] forCellWithReuseIdentifier:aidentifier];
    
    self.selectedAssetsView = [XFSelectedAssetsView makeView];
    self.selectedAssetsView.maxPhotosNumber = self.maxPhotosNumber;
    XFWeakSelf;
    self.selectedAssetsView.deleteAssetsBlock = ^(XFAssetsModel *model) {
        [wself.selectedArray removeObject:model];
        for ( XFAssetsModel *dmodel in wself.dataArray ) {
            if ( [dmodel.asset isEqual:model.asset] ) {
                dmodel.selected = NO;
                break;
            }
        }
        [wself.collectionView reloadData];
    };
    self.selectedAssetsView.confirmBlock = ^() {
        if ( wself.callback ) {
            wself.callback([wself.selectedArray copy]);
            [wself dismissViewControllerAnimated:YES completion:nil];
        }
    };
    [self.bottomView addSubview:self.selectedAssetsView];
    self.selectedAssetsView.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    
    [self setupData];
}

- (IBAction)didCancelButtionAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didBackButtonAction:(UIButton *)sender {
    [self.selectedArray removeAllObjects];
    [self.selectedAssetsView removeData];
    
    XFPhotoAlbumViewController *photoAlbumViewController = [XFPhotoAlbumViewController new];
    photoAlbumViewController.groupArray = [self.groupArray copy];
    [self.navigationController pushViewController:photoAlbumViewController animated:NO];
    [self.navigationController.view.layer addAnimation:[XFPushAnimation getAnimation:4 direction:0] forKey:nil];
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup {
    _assetsGroup = assetsGroup;
    XFWeakSelf;
    [XFAssetsLibraryData getAssetsWithGroup:assetsGroup successBlock:^(NSArray *array) {
        [wself.dataArray removeAllObjects];
        [wself.dataArray addObjectsFromArray:array];
        [XFHUD dismiss];
        [wself.collectionView reloadData];
    }];
}

- (void)setupData {
    XFWeakSelf;
    [XFAssetsLibraryData getLibraryGroupWithSuccess:^(NSArray *array) {
        [wself.groupArray addObjectsFromArray:array];
        wself.titleLabel.text = [[wself.groupArray.firstObject group] valueForProperty:ALAssetsGroupPropertyName];
        [XFAssetsLibraryData getAssetsWithGroup:[wself.groupArray.firstObject group] successBlock:^(NSArray *array) {
            [wself.dataArray removeAllObjects];
            [wself.dataArray addObjectsFromArray:array];
            [XFHUD dismiss];
            
            for ( XFAssetsModel *smodel in wself.selectedAssets ) {
                for ( XFAssetsModel *cmodel in wself.dataArray ) {
                    if ( [smodel.modelID isEqual:cmodel.modelID] ) {
                        cmodel.selected = YES;
                    }
                }
            }
            [wself.selectedArray removeAllObjects];
            [wself.selectedArray addObjectsFromArray:wself.selectedAssets];
            
            [wself.selectedAssetsView addModelWithData:wself.selectedAssets];
            [wself.collectionView reloadData];
        }];
    } failBlcok:^(NSError *error) {
        XFAssetsLibraryAccessFailureView *view = [XFAssetsLibraryAccessFailureView makeView];
        [wself.view addSubview:view];
        view.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    }];
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
        if ( self.maxPhotosNumber == 0 ) {
            [self changeDataWithIndexPath:indexPath];
        }else {
            XFAssetsModel *model = self.dataArray[indexPath.item - 1];
            if ( model.selected ) {
                [self changeDataWithIndexPath:indexPath];
            }else {
                if ( self.selectedArray.count < self.maxPhotosNumber ) {
                    [self changeDataWithIndexPath:indexPath];
                }else {
                    [XFHUD overMaxNumberWithNumber:self.maxPhotosNumber];
                }
            }
        }
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(-20.f, 0.f, 0.f, 0.f);
}

- (void)changeDataWithIndexPath:(NSIndexPath *)indexPath {
    XFAssetsModel *model = self.dataArray[indexPath.item - 1];
    if ( model.selected ) {
        [self.selectedArray removeObject:model];
        [self.selectedAssetsView deleteModelWithData:@[model]];
    }else {
        [self.selectedArray addObject:model];
        [self.selectedAssetsView addModelWithData:@[model]];
    }
    model.selected = !model.selected;
    [self.collectionView reloadData];
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

- (NSMutableArray *)groupArray {
    if ( !_groupArray ) {
        _groupArray = [NSMutableArray array];
    }
    return _groupArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.dataArray removeAllObjects];
    self.dataArray = nil;
    [self.selectedArray removeAllObjects];
    self.selectedArray = nil;
    [self.groupArray removeAllObjects];
    self.groupArray = nil;
    self.selectedArray = nil;
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
