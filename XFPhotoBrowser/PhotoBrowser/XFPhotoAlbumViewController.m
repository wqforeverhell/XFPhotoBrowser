//
//  XFPhotoAlbumViewController.m
//  XFPhotoBrowser
//
//  Created by zeroLu on 16/7/5.
//  Copyright © 2016年 zeroLu. All rights reserved.
//

#import "XFPhotoAlbumViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "XFAssetsLibraryAccessFailureView.h"
#import "XFAssetsLibraryModel.h"
#import "XFPhotoAlbumTableViewCell.h"
#import "UIView+SDAutoLayout.h"
#import "XFAssetsPhotoViewController.h"

static NSString *identifier = @"XFPhotoAlbumTableViewCell";

@interface XFPhotoAlbumViewController ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataArray;
@end

@implementation XFPhotoAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"相册";
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    NSDictionary *titleTextAttributesDict = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:17.f],NSFontAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = titleTextAttributesDict;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
    
    [self setupGroup];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(didCancelBarButtonAction)];
    
}

- (void)didCancelBarButtonAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
}

- (void)setupGroup {
    
    [self.dataArray removeAllObjects];
    
    ALAssetsFilter *assetsFilter = [ALAssetsFilter allPhotos];
    XFWeakSelf;
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        if ( group ) {
            [group setAssetsFilter:assetsFilter];
            XFAssetsLibraryModel *model = [XFAssetsLibraryModel getModelWithData:group];
            [wself.dataArray addObject:model];
            if ( wself.dataArray.count == 1 && [[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == 16 ) {
                XFAssetsPhotoViewController *assetsPhotoViewController = [XFAssetsPhotoViewController new];
                assetsPhotoViewController.assetsGroup = model.group;
                [wself.navigationController pushViewController:assetsPhotoViewController animated:NO];
            }
        }else {
            [wself.tableView reloadData];
        }
        
        if ( stop ) {
            [wself.tableView reloadData];
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        XFAssetsLibraryAccessFailureView *view = [XFAssetsLibraryAccessFailureView makeView];
        [self.view addSubview:view];
        view.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
    };
    
    // Enumerate Camera roll first
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:resultsBlock failureBlock:failureBlock];
    
    // Then all other groups
    NSUInteger type = ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupPhotoStream;
    
    [self.assetsLibrary enumerateGroupsWithTypes:type usingBlock:resultsBlock failureBlock:failureBlock];
    
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XFPhotoAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    XFAssetsLibraryModel *model = self.dataArray[indexPath.row];
    
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XFAssetsLibraryModel *model = self.dataArray[indexPath.row];
    
    XFAssetsPhotoViewController *assetsPhotoViewController = [XFAssetsPhotoViewController new];
    assetsPhotoViewController.assetsGroup = model.group;
    [self.navigationController pushViewController:assetsPhotoViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ALAssetsLibrary
+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

#pragma mark - 懒加载
- (NSMutableArray *)dataArray {
    if ( !_dataArray ) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (ALAssetsLibrary *)assetsLibrary {
    if ( !_assetsLibrary ) {
        _assetsLibrary = [self.class defaultAssetsLibrary];
    }
    return _assetsLibrary;
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
