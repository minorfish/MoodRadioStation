//
//  MRSADScrollerView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/9.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSADScrollView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

#define TAGINDEX(i) i + 1000

@implementation MRSADScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        self.delaysContentTouches = NO; //why?
    }
    return self;
}

- (void)setADDataSource:(id<MRSADScrollerViewDataSource>)ADDataSource
{
    if (_ADDataSource != ADDataSource) {
        _ADDataSource = ADDataSource;
        
        for (UIView *view in self.subviews) {
            [view removeFromSuperview];
        }
        
        if (!_pageSize.width) {
            _pageSize.width = self.bounds.size.width;
        }
        if (!_pageSize.height) {
            _pageSize.height = self.bounds.size.height;
        }
        
        _total = [_ADDataSource pageCountForScrollView:self];
        
        self.contentSize = CGSizeMake(_pageSize.width * (_total > 1 ? 3 : 1), _pageSize.height);
         self.currentIndex = 0;
        [RACObserve(self, contentOffset) subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }];
    }
}

// 当前的视图其实只有中间的图片和相邻的图片，其余的图片并不在scrollerView中，并且每次翻页只会到前一页和后一页，每次中心的页面发生改变则更新左右的页面。
- (void)setCurrentIndex:(NSInteger)currentIndex
{
    if (currentIndex < 0 || currentIndex >= _total) {
        return;
    }
    
    CGFloat currentX = _pageSize.width;
    if (currentIndex == 0) {
        currentX = 0;
    } else if (currentIndex == _total - 1) {
        currentX = 2 *_pageSize.width;
    }
    
    for (int i = -1 ; i <= 1; i++) {
        if (currentIndex + i < 0) {
            continue;
        }
        
        if (currentIndex + i >= _total)
            break;
        
        UIView *view = [self viewWithTag:TAGINDEX(currentIndex + i)];
        if (!view) {
            UIView *view = [_ADDataSource pageAtIndex:currentIndex + i forScrollView:self];
            view.frame = CGRectMake(currentX + i * _pageSize.width, view.frame.origin.y, _pageSize.width, _pageSize.height);
            view.tag = TAGINDEX(currentIndex + i);
            if (view) {
                [self addSubview:view];
            }
        } else {
            view.frame = CGRectMake(currentX + i * _pageSize.width, view.frame.origin.y, _pageSize.width, _pageSize.height);
        }
    }
    
    for (int i = -1; i <= 1 ; i++) {
        if (_currentIndex + i != currentIndex - 1 && _currentIndex + i != currentIndex && _currentIndex + i != currentIndex + 1) {
                UIView *view = [self viewWithTag:TAGINDEX(_currentIndex + i)];
            [view removeFromSuperview];
        }
    }
        
    _currentIndex = currentIndex;
    
    self.contentOffset = CGPointMake(currentX, self.contentOffset.y);
}

- (void)scrollToNextPage
{
    if (_currentIndex + 1 == _total) {
        self.currentIndex = 0;
    } else {
        [self setContentOffset:CGPointMake(self.contentOffset.x + _pageSize.width, self.contentOffset.y) animated:YES];
    }
}

#pragma mark -ADScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self) {
        if (_currentIndex == 0 && scrollView.contentOffset.x >= self.pageSize.width) {
            self.currentIndex = _currentIndex + 1;
        } else if (_currentIndex + 1 < _total && scrollView.contentOffset.x + self.pageSize.width >= scrollView.contentSize.width) {
            self.currentIndex = _currentIndex + 1;
        } else if (_currentIndex + 1 == _total && scrollView.contentOffset.x + self.pageSize.width <= scrollView.contentSize.width) {
            self.currentIndex = _currentIndex - 1;
        } else if (_currentIndex > 0 && scrollView.contentOffset.x <= 0) {
            self.currentIndex = _currentIndex - 1;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_ADDelegate scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_ADDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

// 滚动停止判断最近的停留页面，这个实现了整页面的滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self) {
        if (self.currentIndex >= 0 && self.currentIndex < _total) {
            float newOffsetX = [self numAround:(int)self.contentOffset.x mutiple:(int)_pageSize.width];
            [self setContentOffset:CGPointMake(newOffsetX, self.contentOffset.y) animated:YES];
        }
    }
}

//寻找离originNum最近的mutiNum的倍数
- (int)numAround:(int)originNum mutiple:(int)mutiNum
{
    int reminder = originNum % mutiNum;
    if (reminder == 0) {
        return originNum;
    }
    
    int quotient = originNum / mutiNum;
    if (reminder > mutiNum / 2) {
        return mutiNum * quotient + mutiNum;
    } else {
        return mutiNum * quotient;
    }
}

@end
