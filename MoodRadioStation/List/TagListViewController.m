//
//  MoodCategoryListViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "TagListViewController.h"
#import "MRSRefreshHeader.h"
#import "MRSLoadingMoreCell.h"
#import "UIKitMacros.h"
#import "FMListViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "TagListCellItem.h"
#import "MRSImageAnimationLoadingView.h"
#import "MRSFetchResultController.h"
#import "RadioPlayerViewController.h"
#import "FMInfo.h"
#import "MRSNoContentView.h"
#import "MRSPlayerImageAnimationLoadingView.h"
#import "AppDelegate.h"

@interface TagListViewController()

@property (nonatomic, strong) FMListViewModel *viewModel;

@property (nonatomic, strong) NSNumber *rows;
@property (nonatomic, strong) NSString *keyString;
@property (nonatomic, strong) NSString *keyValue;
@property (nonatomic, strong) MRSNoContentView *noContentView;
@property (nonatomic, strong) UINavigationBar *customizeNavigationBar;

@property (nonatomic, strong) RadioPlayerViewController *playerVC;
@property (nonatomic, strong) UIImageView *playerAnimationImageView;

@property (nonatomic, strong) NSNumber *isPlaying;
@property (nonatomic, assign) BOOL isInitPlayer;

@end

@implementation TagListViewController

- (instancetype)initWithRows:(NSNumber *)rows KeyString:(NSString *)keyString KeyValue:(NSString *)keyValue
{
    self = [super init];
    if (self) {
        _viewModel = [[FMListViewModel alloc] initWithRows:rows KeyString:keyString KeyValue:keyValue];
        _keyValue = keyValue;
        _keyString = keyString;
        _rows = rows;
    }
    return self;
}

- (void)viewDidLoad
{
    self.refreshControll = [[MRSRefreshHeader alloc] initWithFrame:CGRectMake(0, -30, SCREEN_WIDTH, 30) RefreshView:self.tableView];
    self.refreshControll.originEdgeInsets = UIEdgeInsetsMake(60, 0, 0, 0);
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.tableView.backgroundColor = HEXCOLOR(0xf0efed);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.navigationItem.title = self.keyValue;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    backView.image = [UIImage imageNamed:@"back"];
    backView.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
    [tapGes.rac_gestureSignal subscribeNext:^(id x) {
        [self navBack];
    }];
    [backView addGestureRecognizer:tapGes];
    
    [self.tableView addSubview:self.noContentView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.playerAnimationImageView ];
    
    [self bind];
    [self refresh];
}

- (void)navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isPlaying = self.playerVC.isPlaying;
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.refreshControll = nil;
    self.loadigMoreControll = nil;
}

- (void)bind
{
    @weakify(self);
    [self.viewModel.refreshingSignal subscribeNext:^(id x) {
        @strongify(self);
        
    }];
    
    [self.viewModel.dataLoadedSignal subscribeNext:^(id x) {
        @strongify(self);
        
        [self resetLoadMoreViewFrame];
        [self.tableView reloadData];
    }];
    
    [[[RACObserve(self.viewModel, loading) distinctUntilChanged] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNumber  *x) {
        @strongify(self);
        if (![x boolValue]) {
            if (self.refreshControll.isRefreshing) {
                [self.refreshControll stopRefreshing];
            }
            if ([self.loadigMoreControll.isLoading boolValue]) {
                [self.loadigMoreControll stopLoading];
            }
            if ([self.viewModel.fetchResultController numberOfObject] > 0) {
                self.noContentView.hidden = YES;
            }
        }
    }];
    
    [[[RACObserve(self.viewModel, error) distinctUntilChanged] ignore:nil] subscribeNext:^(id x) {
        @strongify(self);
        self.noContentView.hidden = NO;
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
    CGFloat height = self.viewModel.fetchResultController.numberOfObject * [TagListCellItem CellHeight];
    if (height >= SCREEN_HEIGHT) {
        self.loadigMoreControll = [[MRSLoadingMoreCell alloc] initWithFrame:CGRectMake(0, height, SCREEN_WIDTH, 30) RefreshView:self.tableView];
        self.loadigMoreControll.originEdgeInsets = UIEdgeInsetsMake(60, 0, 0, 0);
    }
}

- (void)refresh
{
    [[self.viewModel refreshListCommand] execute:nil];
}

- (void)loadMore
{
    [[self.viewModel loadMoreCommand] execute:nil];
}

- (MRSNoContentView *)noContentView
{
    if (!_noContentView) {
        _noContentView = [[MRSNoContentView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 60)];
        _noContentView.hidden = YES;
        [[_noContentView.refreshBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *x) {
            [self refresh];
        }];
    }
    return _noContentView;
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

#pragma mark - tableViewDelete
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TagListCellItem CellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isInitPlayer) {
        if (!self.playerVC) {
            self.playerVC = [[RadioPlayerViewController alloc]
                     initWithKeyString:self.keyString KeyVale:self.keyValue Rows:self.rows];
        } else {
            self.playerVC.fmListViewModel = [[FMListViewModel alloc] initWithRows:self.rows KeyString:self.keyString KeyValue:self.keyValue];
        }
        _isInitPlayer = YES;
    }
    
    self.playerVC.requestFMInfoArray = [self.viewModel.infoArray mutableCopy];
    self.playerVC.currentFMIndex = @(indexPath.row);
    
    [self pushVC:self.playerVC animated:YES];
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
    TagListCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"TagListCellView"];
    if (!cell) {
        cell = [[TagListCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TagListCellView"];
        ;
    }
    TagListCellItem *item = [[TagListCellItem alloc] init];
    item.fmInfo = [self.viewModel.fetchResultController objectAtIndexPath:indexPath];
    cell.item = item;
    return cell;
}

@end
