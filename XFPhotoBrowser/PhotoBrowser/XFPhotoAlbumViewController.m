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
#import "SVProgressHUD.h"
#import "XFPushAnimation.h"

static NSString *identifier = @"XFPhotoAlbumTableViewCell";

@interface XFPhotoAlbumViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataArray;
@end

@implementation XFPhotoAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"相册";
    
    self.navigationController.navigationBar.barTintColor = RGB(48, 48, 48);
    NSDictionary *titleTextAttributesDict = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:17.f],NSFontAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = titleTextAttributesDict;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:self.groupArray];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(didCancelBarButtonAction)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:nil];
}

- (void)didCancelBarButtonAction {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
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
    
    [self.navigationController.view.layer addAnimation:[XFPushAnimation getAnimation:4 direction:2] forKey:@"popAnimation"];
    XFAssetsLibraryModel *model = self.dataArray[indexPath.row];
    [[[self.navigationController viewControllers] objectAtIndex:self.navigationController.viewControllers.count - 2] setValue:model.group forKeyPath:@"assetsGroup"];
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController.view.layer removeAnimationForKey:@"popAnimation"];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.dataArray removeAllObjects];
    self.dataArray = nil;
    
    self.tableView = nil;
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
