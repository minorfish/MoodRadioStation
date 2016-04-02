//
//  MRSMyDownLoadTableViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/4/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSMyDownLoadTableViewController.h"
#import "MRSRefreshHeader.h"
#import "MRSLoadingMoreCell.h"
#import "MRSMyDownloadViewModel.h"
#import "UIKitMacros.h"
#import "MyDownloadItem.h"
#import "MRSFetchResultController.h"
#import "RadioPlayerViewController.h"
#import "AppDelegate.h"
#import "FMListViewModel.h"
#import "RadioInfo.h"
#import "FMInfo.h"

@interface MRSMyDownLoadTableViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) MRSMyDownloadViewModel *viewModel;
@property (nonatomic, strong) RadioPlayerViewController *playerVC;
@property (nonatomic, strong) UIImageView *playerAnimationImageView;
@property (nonatomic, assign) BOOL isPlaying;

@end

@implementation MRSMyDownLoadTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.isPlaying = self.playerVC.isPlaying;
    if (self.navigationController.navigationBar.hidden) {
         [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshControll = [[MRSRefreshHeader alloc] initWithFrame:CGRectMake(0, -30, SCREEN_WIDTH, 30) RefreshView:self.tableView];
    self.refreshControll.originEdgeInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.tableView.backgroundColor = HEXCOLOR(0xf0efed);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
   
    self.navigationItem.title = @"我的下载";
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    backView.image = [UIImage imageNamed:@"back"];
    backView.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
    [tapGes.rac_gestureSignal subscribeNext:^(id x) {
        [self navBack];
    }];
    [backView addGestureRecognizer:tapGes];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.playerAnimationImageView ];
    
    [self bind];
    [self refresh];
}

- (void)bind
{
    @weakify(self);
    [self.viewModel.dataLoadSignal subscribeNext:^(id x) {
        @strongify(self);
        
        [self resetLoadMoreViewFrame];
        [self.tableView reloadData];
    }];
    
    [[[RACObserve(self.viewModel, isloading) distinctUntilChanged] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNumber  *x) {
        @strongify(self);
        if (![x boolValue]) {
            if (self.refreshControll.isRefreshing) {
                [self.refreshControll stopRefreshing];
            }
            if ([self.loadigMoreControll.isLoading boolValue]) {
                [self.loadigMoreControll stopLoading];
            }
        }
    }];
    [[[RACObserve(self, isPlaying) ignore:nil] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if ([x boolValue]) {
            if (!self.playerAnimationImageView.isAnimating) {
                [self.playerAnimationImageView startAnimating];
            }
        } else {
            if (self.playerAnimationImageView.isAnimating) {
                [self.playerAnimationImageView stopAnimating];
            }
        }
    }];
}

- (void)resetLoadMoreViewFrame
{
    CGFloat height = self.viewModel.fetchResultController.numberOfObject * [MyDownloadItem CellHeight];
    if (height >= SCREEN_HEIGHT) {
        if (!self.loadigMoreControll) {
            self.loadigMoreControll = [[MRSLoadingMoreCell alloc] initWithFrame:CGRectMake(0, height, SCREEN_WIDTH, 30) RefreshView:self.tableView];
        } else {
            self.loadigMoreControll.frame = CGRectMake(0, height, SCREEN_WIDTH, 30);
        }
        self.loadigMoreControll.originEdgeInsets = UIEdgeInsetsMake(60, 0, 0, 0);
    }
}

- (void)refresh
{
    [[self.viewModel refreshCommand] execute:nil];
}

- (void)loadMore
{
    [[self.viewModel loadMoreCommand] execute:nil];
}

- (MRSMyDownloadViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[MRSMyDownloadViewModel alloc] init];
    }
    return _viewModel;
}

- (void)deleteFileWithID:(long long)ID
                   title:(NSString *)title
                 speaker:(NSString *)speaker
{
    BOOL success = [self.viewModel deleteFileWithID:ID];
    UIAlertView *alertView = nil;
    if (success) {
        alertView = [[UIAlertView alloc] initWithTitle:@"删除结果提示" message:[NSString stringWithFormat:@"%@ 主播：%@", title, speaker] delegate:self cancelButtonTitle:@"完成" otherButtonTitles:nil];
    } else {
        alertView = [[UIAlertView alloc] initWithTitle:@"删除结果提示" message:@"删除失败" delegate:self cancelButtonTitle:@"完成" otherButtonTitles:@"重新删除", nil];
    }
    [alertView show];
}

#pragma mark - tableViewDelete
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MyDownloadItem CellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.playerVC) {
        self.playerVC = [[RadioPlayerViewController alloc] initWithKeyString:@"" KeyVale:@"" Rows:@(0)];
    }
    self.playerVC.fmListViewModel = nil;
    self.playerVC.requestFMInfoArray = [self.viewModel.infoArray mutableCopy];
    self.playerVC.currentFMIndex = @(indexPath.row);
    [self pushVC:self.playerVC animated:YES];
}

- (void)navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushVC:(UIViewController *)vc animated:(BOOL)animated
{
    [self.navigationController pushViewController:vc animated:animated];
}

- (RadioPlayerViewController *)playerVC
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    return delegate.radioPlayer;
}

- (UIImageView *)playerAnimationImageView
{
    if (!_playerAnimationImageView) {
        _playerAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _playerAnimationImageView.image = [UIImage imageNamed:@"y1"];
        NSArray *imageArray = @[[UIImage imageNamed:@"y1"],
                                [UIImage imageNamed:@"y2"],
                                [UIImage imageNamed:@"y3"],
                                [UIImage imageNamed:@"y4"],
                                [UIImage imageNamed:@"y5"],
                                [UIImage imageNamed:@"y6"],
                                ];
        [_playerAnimationImageView setAnimationImages:imageArray];
        [_playerAnimationImageView setAnimationRepeatCount:0];
        [_playerAnimationImageView setAnimationDuration:0.4f];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
        [tapGes.rac_gestureSignal subscribeNext:^(id x) {
            [self pushVC:self.playerVC animated:YES];
        }];
        [_playerAnimationImageView addGestureRecognizer:tapGes];
    }
    return _playerAnimationImageView;
}

- (void)setPlayerVC:(RadioPlayerViewController *)playerVC
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.radioPlayer = nil;
    delegate.radioPlayer = playerVC;
}

#pragma mark - tableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel.fetchResultController numberOfObject];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyDownloadCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadListCellView"];
    if (!cell) {
        cell = [[MyDownloadCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DownloadListCellView"];
        ;
    }
    MyDownloadItem *item = [[MyDownloadItem alloc] init];
    item.radioInfo = [self.viewModel.fetchResultController objectAtIndexPath:indexPath];
    cell.item = item;
    cell.didTap = ^(NSString *title, NSString *speaker, long long ID) {
        
    };
    return cell;
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1: {
            self deleteFileWithID:<#(long long)#> title:<#(NSString *)#> speaker:<#(NSString *)#>
        }
            break;
            
        default:
            break;
    }
}

@end
