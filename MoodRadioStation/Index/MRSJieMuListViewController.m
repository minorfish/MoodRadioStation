//
//  MRSJieMuListViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/14.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSJieMuListViewController.h"
#import "MRSJieMuListViewModel.h"

@interface MRSJieMuListViewController ()

@property (nonatomic, strong) FMListViewModel *viewModel;
@property (nonatomic, strong) NSString *navigatioBarTitle;

@end

@implementation MRSJieMuListViewController {
    MRSJieMuListViewModel *_jiemuViewModel;
}

- (instancetype)initWithRows:(NSNumber *)rows KeyString:(NSString *)keyString KeyValue:(NSString *)keyValue Title:(NSString *)title
{
    self = [super initWithRows:rows KeyString:keyString KeyValue:keyValue];
    if (self) {
        self.viewModel = [[MRSJieMuListViewModel alloc] initWithRows:rows KeyString:keyString KeyValue:keyValue];
        _navigatioBarTitle = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.navigatioBarTitle;
}

- (void)setViewModel:(MRSJieMuListViewModel *)viewModel
{
    _jiemuViewModel = viewModel;
}

- (FMListViewModel *)viewModel
{
    return _jiemuViewModel;
}

@end
