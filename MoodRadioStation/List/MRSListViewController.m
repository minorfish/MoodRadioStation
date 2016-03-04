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

@implementation MRSListViewController

- (void)setRefreshControll:(MRSRefreshHeader *)refreshControll
{
    _refreshControll = refreshControll;
    [self.view addSubview:_refreshControll];
}

- (void)setLoadigMoreControll:(MRSLoadingMoreCell *)loadigMoreControll
{
    _loadigMoreControll = loadigMoreControll;
    [self.view addSubview:_loadigMoreControll];
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

@end
