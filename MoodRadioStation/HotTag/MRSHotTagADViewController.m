//
//  MRSHotTagADViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/9.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSHotTagADViewController.h"
#import "MRSHotTagViewModel.h"
#import "MRSADScrollView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "MRSURLImageView.h"
#import "MRSHotTagInfo.h"

@interface MRSHotTagADViewController ()

@property (nonatomic, strong) NSArray *ADArray;

@property (nonatomic, strong) MRSADScrollView *ADScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *ADView;

@end

@implementation MRSHotTagADViewController

@dynamic ADScrollView;
@dynamic pageControl;
@dynamic ADView;

- (void)loadADView:(NSInteger)flagID finished:(void (^)(UIView *))finished
{
    if (flagID <= 0 || flagID > 4)
        return;
    
    MRSHotTagViewModel *viewModel = [[MRSHotTagViewModel alloc] init];
    viewModel.flag = flagID;
    viewModel.rows = 5;
    viewModel.offset = 0;
    
    [viewModel.getHotTagCommand execute:nil];
    
    [viewModel.dataLoaded subscribeNext:^(NSArray *array) {
        if (!array.count) {
            [self stopTimer];
            finished(nil);
            return;
        }
        self.ADArray = array;
        self.ADScrollView.ADDataSource = nil;
        self.ADScrollView.ADDataSource = self;
        self.ADScrollView.scrollsToTop = NO;
        if (!self.ADScrollView.superview) {
            [self.ADView addSubview:self.ADScrollView];
            @weakify(self);
            [RACObserve(self.ADScrollView, currentIndex) subscribeNext:^(NSNumber *x) {
                @strongify(self);
                if ([x integerValue] < array.count) {
                    self.pageControl.currentPage = [x integerValue];
                }
            }];
        }
        if (!self.pageControl.superview) {
            [self.ADView addSubview:self.pageControl];
        }
        
        self.pageControl.numberOfPages = array.count;
        [self startTimer];
        finished(self.ADView);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.ADArray.count > 0) {
        [self startTimer];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopTimer];
}

#pragma mark -ADScrollViewDataSorce
- (NSInteger)pageCountForScrollView:(MRSADScrollView *)scrollView
{
    return self.ADArray.count;
}

- (UIView *)pageAtIndex:(NSInteger)index forScrollView:(MRSADScrollView *)scrollView
{
    __block MRSHotTagInfo *info = [self.ADArray objectAtIndex:index];
    MRSURLImageView *ADView = [[MRSURLImageView alloc] init];
    ADView.defaultImage = [UIImage imageNamed:@"AD_defalt"];
    ADView.loadingImage = [UIImage imageNamed:@"AD_defalt"];
    if (info) {
        ADView.URLString = info.coverURL;
        ADView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
        [tapGes.rac_gestureSignal subscribeNext:^(id x) {
            [self didTap];
        }];
        [ADView addGestureRecognizer:tapGes];
    }
    return ADView;
}

- (void)didTap
{
    
}

@end
