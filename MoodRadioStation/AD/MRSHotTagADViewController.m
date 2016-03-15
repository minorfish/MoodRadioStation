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

@interface MRSHotTagADViewController ()<MRSADScrollerViewDataSource>

@property (nonatomic, strong) NSArray *ADArray;

@property (nonatomic, strong) MRSADScrollView *ADScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *ADView;
@property (nonatomic, strong) MRSHotTagViewModel *viewModel;

@end

@implementation MRSHotTagADViewController

@dynamic ADScrollView;
@dynamic pageControl;
@dynamic ADView;

- (void)loadADView:(NSInteger)flagID finished:(void (^)(UIView *))finished
{
    if (flagID <= 0 || flagID > 4)
        return;
    
    self.viewModel = nil;
    self.viewModel = [[MRSHotTagViewModel alloc] init];
    self.viewModel.flag = flagID;
    self.viewModel.rows = 5;
    self.viewModel.offset = 0;
    
    [self.viewModel.getHotTagCommand execute:nil];
    
    [self.viewModel.dataLoaded subscribeNext:^(NSArray *array) {
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
    MRSURLImageView *imageView = [[MRSURLImageView alloc] initWithFrame:self.ADView.frame];
    imageView.defaultImage = [UIImage imageNamed:@"AD_defalt"];
    imageView.loadingImage = [UIImage imageNamed:@"AD_defalt"];
    if (info) {
        imageView.URLString = info.coverURL;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
        [tapGes.rac_gestureSignal subscribeNext:^(id x) {
            if (self.didTapWithTag) {
                self.didTapWithTag(info.title);
            }
        }];
        [imageView addGestureRecognizer:tapGes];
    }
    return imageView;
}

@end
