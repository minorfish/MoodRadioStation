//
//  MRSFindViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/10.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSFindViewController.h"
#import "MRSHotTagADViewController.h"
#import "TagListViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MRSFindViewController ()

@property (nonatomic, strong) MRSHotTagADViewController *ADViewController;
@property (nonatomic, weak) UIView *ADView;

@end

@implementation MRSFindViewController

- (MRSHotTagADViewController *)ADViewController
{
    if (!_ADViewController) {
        _ADViewController = [[MRSHotTagADViewController alloc] init];
        @weakify(self);
        _ADViewController.didTapWithTag = ^(NSString *tag) {
            TagListViewController *vc = [[TagListViewController alloc] initWithRows:@(15) KeyString:@"tag" KeyValue:tag];
            @strongify(self);
            [self.navigationController pushViewController:vc animated:YES];
        };
    }
    return _ADViewController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)viewDidLoad
{
    [self loadADView];
}

- (void)loadADView
{
    if (_ADView) {
        [_ADView removeFromSuperview];
    }
    [self.ADViewController loadADView:4 finished:^(UIView *view) {
        self.ADView = view;
        [self.view addSubview:self.ADView];
    }];
}

@end
