//
//  MRSADScrollViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/9.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSADViewController.h"
#import "MRSADScrollView.h"
#import "UIKitMacros.h"

@interface MRSADViewController ()<MRSADScrollerViewDelegate>

@property (nonatomic, strong) MRSADScrollView *ADScrollView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *ADView;

@end

@implementation MRSADViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _adViewHeight = SCREEN_WIDTH / 375.0 * 240;
    }
    return self;
}

- (void)dealloc
{
    self.ADScrollView.ADDelegate = nil;
    self.ADScrollView.ADDataSource = nil;
    self.timer = nil;
}

- (UIView *)ADView
{
    if (!_ADView) {
        _ADView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _adViewHeight)];
        _ADView.clipsToBounds = YES;
    }
    return _ADView;
}

- (MRSADScrollView *)ADScrollView
{
    if (!_ADScrollView) {
        _ADScrollView = [[MRSADScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _adViewHeight)];
        _ADScrollView.scrollsToTop = NO;// 点击设备栏回顶部
        _ADScrollView.ADDelegate = self;
    }
    return _ADScrollView;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(scrollNext) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.ADView.frame.size.width - 200)/2, self.ADView.frame.size.height - 7 - 10, 200, 7)];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.pageIndicatorTintColor = RGBCOLOR(226, 226, 226);
    }
    return _pageControl;
}

- (void)scrollNext
{
    [self.ADScrollView scrollToNextPage];
}

#pragma mark -ADScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)startTimer
{
    [self stopTimer];
    [self.timer performSelector:@selector(fire) withObject:self afterDelay:5];
}

@end
