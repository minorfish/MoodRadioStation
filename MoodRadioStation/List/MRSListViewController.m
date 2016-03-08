//
//  MRSLIstViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSListViewController.h"
#import "MRSRefreshHeader.h"
#import "MRSLoadingMoreCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIKitMacros.h"

@implementation MRSListViewController

- (void)setRefreshControll:(MRSRefreshHeader *)refreshControll
{
    [_refreshControll removeTarget:self action:@selector(refreshStatusChanged:) forControlEvents:UIControlEventValueChanged];
    [_refreshControll removeFromSuperview];
    _refreshControll = refreshControll;
    [_refreshControll addTarget:self action:@selector(refreshStatusChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_refreshControll];
}

- (void)setLoadigMoreControll:(MRSLoadingMoreCell *)loadigMoreControll
{
    [_loadigMoreControll removeFromSuperview];
    _loadigMoreControll = loadigMoreControll;
    [self.view addSubview:_loadigMoreControll];
    [[RACObserve(_loadigMoreControll, isLoading) distinctUntilChanged] subscribeNext:^(NSNumber *isLoading) {
        if ([isLoading boolValue]) {
            [self performSelector:@selector(loadMore) withObject:nil afterDelay:0.25];
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshControll refreshViewDidScroll:scrollView];
    [self.loadigMoreControll refreshViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshControll refreshViewDidEndDragging:scrollView willDecelerate:decelerate];
    [self.loadigMoreControll refreshViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)refreshStatusChanged:(MRSRefreshHeader *)refreshController
{
    if (refreshController.isRefreshing) {
        [self performSelector:@selector(refresh) withObject:nil afterDelay:0.05];
    }
}

- (void)refresh
{
    
}

- (void)loadMore
{
    
}

@end
