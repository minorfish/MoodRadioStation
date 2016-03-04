//
//  MoodCategoryListViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MoodCategoryListViewController.h"
#import "MRSRefreshHeader.h"
#import "MRSLoadingMoreCell.h"
#import "UIKitMacros.h"

@implementation MoodCategoryListViewController

- (void)viewDidLoad
{
    self.refreshControll = [[MRSRefreshHeader alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50) RefreshView:self.tableView];
    self.loadigMoreControll = [[MRSLoadingMoreCell alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 30, SCREEN_WIDTH, 30) RefreshView:self.tableView];
}

@end
