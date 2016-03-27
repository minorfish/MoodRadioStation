//
//  MRSLoadingMoreCell.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSLoadingMoreCell.h"
#import <Masonry/Masonry.h>
#import "UIKitMacros.h"

#define LOADMORE_OFFSET 30
#define LOADMOREVIEW_HEIGHT 30

@interface MRSLoadingMoreCell()

@property (nonatomic, assign) BOOL showAnimation;

@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UIImageView *pullImage;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) UIScrollView *refreshView;

@end

@implementation MRSLoadingMoreCell

- (instancetype)initWithFrame:(CGRect)frame RefreshView:(UIScrollView *)refreshView
{
    self = [super initWithFrame:frame];
    if (self) {
        self.refreshView = refreshView;
        
        [self addSubview:self.stateLabel];
        [self addSubview:self.pullImage];
        [self addSubview:self.activityIndicatorView];
        
        [_stateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.centerX.equalTo(self);
            make.bottom.equalTo(self).offset(-10);
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

- (void)setLoadingMoreState:(MRSLoadingMoreState)loadingMoreState
{
    switch (loadingMoreState) {
        case MRSLoadingMoreState_normal: {
            self.isLoading = @(NO);
            self.pullImage.hidden = NO;
            self.showAnimation = NO;
            self.stateLabel.text = @"上拉刷新";
            [self.activityIndicatorView stopAnimating];
        }
            break;
        case MRSLoadingMoreState_loading: {
            self.isLoading = @(YES);
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
        case MRSLoadingMoreState_dragging: {
            self.isLoading = @(NO);
            self.pullImage.hidden = NO;
            self.stateLabel.text = @"松开刷新";
        }
            break;
        default:
            break;
    }
//    if (_loadingMoreState != loadingMoreState && !self.pullImage.hidden) {
//        self.pullImage.layer.transform = CATransform3DMakeRotation(0, 1.0, 0, 0);
//    }
    _loadingMoreState = loadingMoreState;
}

- (void)refreshViewDidScroll:(UIScrollView *)refreshView
{
    CGFloat offset = refreshView.contentOffset.y - (refreshView.contentSize.height - refreshView.frame.size.height);
    UIEdgeInsets contentInset = refreshView.contentInset;
    if (self.loadingMoreState == MRSLoadingMoreState_loading) {
        
    } else {
        contentInset.bottom = self.originEdgeInsets.bottom;
        if (self.loadingMoreState == MRSLoadingMoreState_normal && offset > 0 && offset < [self loadThreshold]){
            [self setLoadingMoreState:MRSLoadingMoreState_normal];
        } else if (self.loadingMoreState == MRSLoadingMoreState_dragging && offset > 0 && offset < [self loadThreshold]){
            [self setLoadingMoreState:MRSLoadingMoreState_normal];
        } else if (self.loadingMoreState == MRSLoadingMoreState_normal && refreshView.contentOffset.y > [self loadThreshold]) {
            [self setLoadingMoreState:MRSLoadingMoreState_dragging];
        }
    }
    refreshView.contentInset = contentInset;
}

- (void)refreshViewDidEndDragging:(UIScrollView *)refreshView willDecelerate:(BOOL)decelerate
{
    CGFloat offset = refreshView.contentOffset.y - (refreshView.contentSize.height - refreshView.frame.size.height);
    if (self.loadingMoreState != MRSLoadingMoreState_loading && offset > [self loadThreshold] && self.enabled) {
        [self setLoadingMoreState:MRSLoadingMoreState_loading];
        
        UIEdgeInsets contentInset = refreshView.contentInset;
        contentInset.bottom = self.originEdgeInsets.bottom + LOADMOREVIEW_HEIGHT;
        [UIView animateWithDuration:0.2 animations:^{
            refreshView.contentInset = contentInset;
        }];
    }
    if (!self.pullImage.hidden) {
        self.pullImage.hidden = YES;
    }
}

- (void)beginLoading
{
    self.refreshView.contentOffset = CGPointZero;
    [UIView animateWithDuration:0.2 animations:^{
        [self setLoadingMoreState:MRSLoadingMoreState_loading];
        [self.refreshView setContentOffset:CGPointMake(0, -self.originEdgeInsets.top - LOADMOREVIEW_HEIGHT)];
    }];
}

- (void)stopLoading
{
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat offset = self.refreshView.contentOffset.y;
        [self.refreshView setContentOffset:CGPointMake(0, offset - LOADMOREVIEW_HEIGHT)];
    } completion:^(BOOL finished) {
        [self setLoadingMoreState:MRSLoadingMoreState_normal];
    }];
    self.pullImage.hidden = YES;
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

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (!enabled) {
        [self removeFromSuperview];
    }
}

- (CGFloat)loadThreshold
{
    return self.originEdgeInsets.top + LOADMORE_OFFSET;
}

@end
