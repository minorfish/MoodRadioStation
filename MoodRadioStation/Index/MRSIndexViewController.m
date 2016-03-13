//
//  MRSIndexViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSIndexViewController.h"
#import "MRSIndexViewModel.h"

@implementation MRSIndexViewController {
    MRSIndexViewModel *_viewModel;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _viewModel = [[MRSIndexViewModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    
}

- (void)setupUI
{
    
}

@end
