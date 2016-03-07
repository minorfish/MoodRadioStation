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

@interface TagListViewController()

@property (nonatomic, strong) FMListViewModel *viewModel;

@property (nonatomic, strong) NSString *tag;

@property (nonatomic, strong) UIView *noContentView;
@property (nonatomic, strong) UINavigationBar *customizeNavigationBar;

@end

@implementation TagListViewController

- (instancetype)initWithRows:(NSNumber *)rows Tag:(NSString *)tag
{
    self = [super init];
    if (self) {
        _viewModel = [[FMListViewModel alloc] initWithRows:rows Tag:tag];
        _tag = tag;
    }
    return self;
}

- (void)viewDidLoad
{
    self.refreshControll = [[MRSRefreshHeader alloc] initWithFrame:CGRectMake(0, -30, SCREEN_WIDTH, 30) RefreshView:self.tableView];
    self.refreshControll.originEdgeInsets = UIEdgeInsetsMake(60, 0, 0, 0);
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    

    self.navigationItem.title = self.tag;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    UIImageView *backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back"]];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
    [tapGes.rac_gestureSignal subscribeNext:^(id x) {
        // navBack func
    }];
    [backView addGestureRecognizer:tapGes];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
    
    [self bind];
    [self refresh];
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
        if ([self.loadigMoreControll.isLoading boolValue]) {
            [self.loadigMoreControll stopLoading];
            self.loadigMoreControll.enabled = x? YES: NO;
        }
        
        [self resetLoadMoreViewFrame];
        [self.tableView reloadData];
    }];
    
    [[[RACObserve(self.viewModel, loading) distinctUntilChanged] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNumber  *x) {
        if ([x boolValue]) {
            if (self.refreshControll.isRefreshing) {
                [self.refreshControll stopRefreshing];
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

#pragma mark - tableViewDelete
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TagListCellItem CellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FMInfo *fmInfo = [self.viewModel.fetchResultController objectAtIndexPath:indexPath];
    RadioPlayerViewController *playerController = [[RadioPlayerViewController alloc] initWithRadioID:@(fmInfo.ID) RadioURL:fmInfo.mediaURL];
    [self.navigationController pushViewController:playerController animated:YES];
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
