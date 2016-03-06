//
//  MRSRefreshHeader.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSRefreshHeader.h"
#import "UIKitMacros.h"
#import <Masonry/Masonry.h>

#define REFRESH_OFFSET 60
#define REFRESHVIEW_HEIGHT 30

@interface MRSRefreshHeader()

@property (nonatomic, assign) BOOL showAnimation;

@property (nonatomic, strong) UILabel *lastUpdatedLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UIImageView *pullImage;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) UIScrollView *refreshView;

@end

@implementation MRSRefreshHeader

- (instancetype)initWithFrame:(CGRect)frame RefreshView:(UIScrollView *)refreshView
{
    self = [super initWithFrame:frame];
    if (self) {
        self.refreshView = refreshView;
        
        [self addSubview:self.lastUpdatedLabel];
        [self addSubview:self.stateLabel];
        [self addSubview:self.pullImage];
        [self addSubview:self.activityIndicatorView];
        
        [_stateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.centerX.equalTo(self);
        }];
        [_lastUpdatedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.stateLabel.mas_bottom).offset(5);
            make.centerX.equalTo(self);
            make.bottom.equalTo(self).offset(-5);
        }];
        [_pullImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(_stateLabel.mas_left).offset(-5);
        }];
        [_activityIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.pullImage);
        }];
    }
    return self;
}

- (void)setRefreshing:(BOOL)refreshing
{
    if (_refreshing != refreshing) {
        _refreshing = refreshing;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setRefreshState:(MRSRefreshState)refreshState
{
    switch (refreshState) {
        case MRSRefreshState_normal: {
            self.refreshing = NO;
            self.pullImage.hidden = NO;
            self.showAnimation = NO;
            self.stateLabel.text = @"下拉刷新";
            [self.activityIndicatorView stopAnimating];
        }
            break;
        case MRSRefreshState_loading: {
            self.refreshing = YES;
            self.pullImage.hidden = YES;
            self.showAnimation = YES;
            self.stateLabel.text = @"正在刷新";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if (self.showAnimation) {
                    [self.activityIndicatorView startAnimating];
                }
            });
        }
            break;
        case MRSRefreshState_pulling: {
            self.refreshing = NO;
            self.pullImage.hidden = NO;
            self.stateLabel.text = @"松开立即刷新";
        }
            break;
        default:
            break;
    }
    _refreshState = refreshState;
}

- (void)refreshViewDidScroll:(UIScrollView *)refreshView
{
    UIEdgeInsets contentInset = refreshView.contentInset;
    if (self.refreshState == MRSRefreshState_loading) {
    } else {
        contentInset.top = self.originEdgeInsets.top;
        if (refreshView.isDragging || refreshView.isDecelerating) {
            
            if (self.state == MRSRefreshState_normal && refreshView.contentOffset.y < 0 && refreshView.contentOffset.y > -REFRESH_OFFSET) {
                [self setRefreshState:MRSRefreshState_normal];
            } else if (self.state == MRSRefreshState_pulling && refreshView.contentOffset.y < 0 && refreshView.contentOffset.y > -REFRESH_OFFSET) {
                [self setRefreshState:MRSRefreshState_normal];
            } else if (self.state == MRSRefreshState_normal && refreshView.contentOffset.y < -REFRESH_OFFSET) {
                [self setRefreshState:MRSRefreshState_pulling];
            }
        }
    }
    refreshView.contentInset = contentInset;
}

- (void)refreshViewDidEndDragging:(UIScrollView *)refreshView willDecelerate:(BOOL)decelerate
{
    if (refreshView.contentOffset.y < -REFRESH_OFFSET && self.refreshState != MRSRefreshState_loading) {
        [self setRefreshState:MRSRefreshState_loading];
        
        UIEdgeInsets contentInsets = refreshView.contentInset;
        contentInsets.top = self.originEdgeInsets.top + REFRESHVIEW_HEIGHT;
        [UIView animateWithDuration:0.2 animations:^{
            refreshView.contentInset = contentInsets;
        }];
    }
    
    if (!_pullImage.hidden) {
        _pullImage.hidden = YES;
    }
}

- (void)beginRefreshing
{
    self.refreshView.contentOffset = CGPointZero;
    [self setRefreshState:MRSRefreshState_loading];
    [UIView animateWithDuration:0.2 animations:^{
        [self.refreshView setContentOffset:CGPointMake(0, -self.originEdgeInsets.top + REFRESHVIEW_HEIGHT)];
    }];
}

- (void)stopRefreshing
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.refreshView setContentOffset:CGPointMake(0, -self.originEdgeInsets.top)];
    } completion:^(BOOL finished) {
        [self setRefreshState:MRSRefreshState_normal];
    }];
    self.pullImage.hidden = YES;
}

- (UILabel *)lastUpdatedLabel
{
    if (!_lastUpdatedLabel) {
        _lastUpdatedLabel = [[UILabel alloc] init];
        _lastUpdatedLabel.font = Font(14);
        _lastUpdatedLabel.textColor = HEXCOLOR(0x666666);
    }
    return _lastUpdatedLabel;
}

- (UILabel *)stateLabel
{
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.font = Font(14);
        _stateLabel.textColor = HEXCOLOR(0x666666);
    }
    return _stateLabel;
}

- (UIImageView *)pullImage
{
    if (!_pullImage) {
        _pullImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pull_arrow"]];
    }
    return _pullImage;
}

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityIndicatorView;
}

@end
