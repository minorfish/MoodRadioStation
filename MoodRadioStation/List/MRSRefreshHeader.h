//
//  MRSRefreshHeader.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MRSRefreshState) {
    MRSRefreshState_normal,          //正常状态
    MRSRefreshState_loading,         //刷新中
    MRSRefreshState_pulling          //下拉中
};

@interface MRSRefreshHeader : UIControl

@property (nonatomic, assign) MRSRefreshState refreshState;

@property (nonatomic, assign) UIEdgeInsets originEdgeInsets;
@property (nonatomic, assign, getter=isRefreshing) BOOL refreshing;

- (instancetype)initWithFrame:(CGRect)frame RefreshView:(UIScrollView *)refreshView;

- (void)beginRefreshing;
- (void)stopRefreshing;

- (void)refreshViewDidScroll:(UIScrollView *)refreshView;
- (void)refreshViewDidEndDragging:(UIScrollView *)refreshView willDecelerate:(BOOL)decelerate;

@end
