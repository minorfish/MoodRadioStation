//
//  MRSLoadingMoreCell.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MRSLoadingMoreState) {

    MRSLoadingMoreState_normal,           // 上拉加载更多
    MRSLoadingMoreState_loading,          // 加载中。。。
    MRSLoadingMoreState_dragging           // 上拉中
};

@interface MRSLoadingMoreCell : UIControl

@property (nonatomic, assign) MRSLoadingMoreState loadingMoreState;
@property (nonatomic, assign) UIEdgeInsets originEdgeInsets;
@property (nonatomic, strong) NSNumber *isLoading;

- (instancetype)initWithFrame:(CGRect)frame RefreshView:(UIScrollView *)refreshView;

- (void)beginLoading;
- (void)stopLoading;

- (void)refreshViewDidScroll:(UIScrollView *)refreshView;
- (void)refreshViewDidEndDragging:(UIScrollView *)refreshView willDecelerate:(BOOL)decelerate;

@end
