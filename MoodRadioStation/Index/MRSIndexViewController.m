//
//  MRSIndexViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSIndexViewController.h"
#import "MRSIndexViewModel.h"
#import "MRSIndexCategoryViewProductor.h"
#import "UIKitMacros.h"
#import "MRSIndexInfo.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "MRSJieMuListViewController.h"
#import "MRSHotFmViewProductor.h"
#import "RadioInfo.h"
#import "RadioPlayerViewController.h"
#import "MRSCellViewProductor.h"
#import "AppDelegate.h"
#import "FMListViewModel.h"


@interface MRSIndexViewController ()

@property (nonatomic, strong) UIView *categoryView;
@property (nonatomic, strong) UIView *hotFMView;
@property (nonatomic, strong) UIView *lastefmView;
@property (nonatomic, strong) UIView *lessionView;

@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) MRSIndexCategoryViewProductor *categoryViewProductor;
@property (nonatomic, strong) MRSHotFmViewProductor *hotfmViewProductor;
@property (nonatomic, strong) MRSCellViewProductor *lessionViewProductor;
@property (nonatomic, strong) MRSCellViewProductor *lastefmViewProductor;
@property (nonatomic, strong) UIImageView *playerAnimationImageView;
@property (nonatomic, strong) RadioPlayerViewController *player;
@property (nonatomic, strong) NSNumber *isPlaying;

@end

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
    [self bind];
    [_viewModel.getIndexCommand execute:nil];
    
    @weakify(self);
    [_viewModel.dataLoaded subscribeNext:^(id x) {
        @strongify(self);
        [self setupUI];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isPlaying = self.player.isPlaying;
    if (!self.navigationController.navigationBar.hidden) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}

- (void)setupUI
{
    self.contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];

    self.contentView.backgroundColor = HEXCOLOR(0xf0efed);
    
    [self.view addSubview:self.contentView];
    [self loadCategoryView];
    [self loadHotFmView];
    [self loadLastefmView];
    [self loadLessionView];
    
    [_categoryView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.left.right.equalTo(self.contentView);
    }];
    [_hotFMView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.categoryView.mas_bottom).offset(10);
        make.left.right.equalTo(self.contentView);
    }];
    [_lastefmView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hotFMView.mas_bottom).offset(10);
        make.left.right.equalTo(self.contentView);
    }];
    [_lessionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lastefmView.mas_bottom).offset(10);
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-self.navigationController.navigationBar.frame.size.height);
    }];
}

- (MRSIndexCategoryViewProductor *)categoryViewProductor
{
    if (!_categoryViewProductor) {
        _categoryViewProductor = [[MRSIndexCategoryViewProductor alloc] init];
        _categoryViewProductor.cloumn = 4;
        @weakify(self);
        _categoryViewProductor.didTap = ^(NSInteger categotyID, NSString *name) {
            @strongify(self);
            MRSJieMuListViewController *vc = [[MRSJieMuListViewController alloc] initWithRows:@(15) KeyString:@"category_id" KeyValue:[NSString stringWithFormat:@"%@", @(categotyID)] Title:name];
            [self.navigationController pushViewController:vc animated:YES];
        };
    }
    return _categoryViewProductor;
}

- (MRSHotFmViewProductor *)hotfmViewProductor
{
    if (!_hotfmViewProductor) {
        _hotfmViewProductor = [[MRSHotFmViewProductor alloc] init];
        _hotfmViewProductor.cloumn = 3;
       
        @weakify(self);
        _hotfmViewProductor.didTap = ^(NSInteger index, NSArray *array){
            @strongify(self);
            AppDelegate *delegate = [UIApplication sharedApplication].delegate;
            if (!delegate.radioPlayer) {
                delegate.radioPlayer = [[RadioPlayerViewController alloc] initWithKeyString:nil KeyVale:nil Rows:nil];
            } else {
                delegate.radioPlayer.fmListViewModel = [[FMListViewModel alloc] initWithRows:nil KeyString:nil KeyValue:nil];
            }
            delegate.radioPlayer.currentFMIndex = @(index);
            delegate.radioPlayer.requestFMInfoArray = [array mutableCopy];
            [self.navigationController pushViewController:delegate.radioPlayer animated:YES];
        };
    }
    return _hotfmViewProductor;
}

- (MRSCellViewProductor *)lessionViewProductor
{
    if (!_lessionViewProductor) {
        @weakify(self);
        _lessionViewProductor = [[MRSCellViewProductor alloc] init];
        _lessionViewProductor.didTap = ^(NSInteger index, NSArray *array){
            @strongify(self);
            AppDelegate *delegate = [UIApplication sharedApplication].delegate;
            if (!delegate.radioPlayer) {
                delegate.radioPlayer = [[RadioPlayerViewController alloc] initWithKeyString:@"is_teacher" KeyVale:@"1" Rows:@(15)];
            } else {
                delegate.radioPlayer.fmListViewModel = [[FMListViewModel alloc] initWithRows:@(15) KeyString:@"is_teacher" KeyValue:@"1"];
            }

            delegate.radioPlayer.requestFMInfoArray = [array mutableCopy];
            delegate.radioPlayer.currentFMIndex = @(index);

            [self.navigationController pushViewController:delegate.radioPlayer animated:YES];
        };
    }
    return _lessionViewProductor;
}

- (MRSCellViewProductor *)lastefmViewProductor
{
    if (!_lastefmViewProductor) {
        @weakify(self);
        _lastefmViewProductor = [[MRSCellViewProductor alloc] init];
        _lastefmViewProductor.didTap = ^(NSInteger index, NSArray *array){
            @strongify(self);
            AppDelegate *delegate = [UIApplication sharedApplication].delegate;
            if (!delegate.radioPlayer) {
                delegate.radioPlayer = [[RadioPlayerViewController alloc] initWithKeyString:@"is_teacher" KeyVale:@"0" Rows:@(15)];
            } else {
                delegate.radioPlayer.fmListViewModel = [[FMListViewModel alloc] initWithRows:@(15) KeyString:@"is_teacher" KeyValue:@"0"];
            }
            
            delegate.radioPlayer.currentFMIndex = @(index);
            delegate.radioPlayer.requestFMInfoArray = [array mutableCopy];
            [self.navigationController pushViewController:delegate.radioPlayer animated:YES];
        };
    }
    return _lastefmViewProductor;
}

- (void)loadLessionView
{
    _lessionView = ({
        
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        
        UIView *tagView = [[UIView alloc] init];
        tagView.backgroundColor = HEXCOLOR(0x3CB371);
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"最新心理课";
        titleLabel.font = Font(15);
        
        // 数据来了写
        self.lessionViewProductor.infoArray = _viewModel.indexInfo.lessonArray;
        UIView *cellView = [self.lessionViewProductor loadCellView];
        
        UIView *moreCellView = [self loadMoreCellViewWithTitle:@"最新心理课" KeyValue:@"1"];
        UIView *seperateLine = [[UIView alloc] init];
        seperateLine.backgroundColor = HEXCOLOR(0xe5e5e5);
        
        [view addSubview:tagView];
        [view addSubview:titleLabel];
        [view addSubview:cellView];
        [view addSubview:seperateLine];
        [view addSubview:moreCellView];
        
        [tagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(view);
            make.height.equalTo(@30);
            make.width.equalTo(@5);
        }];
        [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tagView.mas_right).offset(10);
            make.centerY.equalTo(tagView);
        }];
        [cellView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(tagView.mas_bottom);
            make.left.right.equalTo(view);
        }];
        [seperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cellView.mas_bottom);
            make.left.equalTo(view).offset(12);
            make.width.equalTo(@(SCREEN_WIDTH));
            make.height.equalTo(@0.5);
        }];
        [moreCellView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(seperateLine.mas_bottom).offset(12);
            make.bottom.equalTo(view).offset(-12);
            make.centerX.equalTo(cellView);
        }];
        
        view;
    });
    
    [self.contentView addSubview:self.lessionView];
}

- (void)loadLastefmView
{
    _lastefmView = ({
    
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        
        UIView *tagView = [[UIView alloc] init];
        tagView.backgroundColor = HEXCOLOR(0xFA8072);
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"最新FM";
        titleLabel.font = Font(15);
        
        // 数据来了写
        self.lastefmViewProductor.infoArray = _viewModel.indexInfo.latestfmArray;
        UIView *cellView = [self.lastefmViewProductor loadCellView];
        
        UIView *moreCellView = [self loadMoreCellViewWithTitle:@"最新FM" KeyValue:@"0"];
        UIView *seperateLine = [[UIView alloc] init];
        seperateLine.backgroundColor = HEXCOLOR(0xe5e5e5);
        
        [view addSubview:tagView];
        [view addSubview:titleLabel];
        [view addSubview:cellView];
        [view addSubview:seperateLine];
        [view addSubview:moreCellView];
        
        [tagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(view);
            make.height.equalTo(@30);
            make.width.equalTo(@5);
        }];
        [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tagView.mas_right).offset(10);
            make.centerY.equalTo(tagView);
        }];
        [cellView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(tagView.mas_bottom);
            make.left.right.equalTo(view);
        }];
        [seperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cellView.mas_bottom);
            make.left.equalTo(view).offset(12);
            make.width.equalTo(@(SCREEN_WIDTH));
            make.height.equalTo(@0.5);
        }];
        [moreCellView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(seperateLine.mas_bottom).offset(12);
            make.bottom.equalTo(view).offset(-12);
            make.centerX.equalTo(cellView);
        }];
        
        view;
    });
    
    [self.contentView addSubview:self.lastefmView];
}

- (void)loadCategoryView
{
    _categoryView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        
        UIView *tagView = [[UIView alloc] init];
        tagView.backgroundColor = HEXCOLOR(0xFA8072);
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"分类";
        titleLabel.font = Font(15);
        
        // 数据来了写
        self.categoryViewProductor.infoArray = _viewModel.indexInfo.categoryArray;
        UIView *categoryView = [self.categoryViewProductor loadCategoryView];
        
        [view addSubview:tagView];
        [view addSubview:titleLabel];
        [view addSubview:self.playerAnimationImageView];
        [view addSubview:categoryView];
        
        [tagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(view);
            make.height.equalTo(@30);
            make.width.equalTo(@5);
        }];
        [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tagView.mas_right).offset(10);
            make.centerY.equalTo(tagView);
        }];
        [_playerAnimationImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(titleLabel);
            make.right.equalTo(view).offset(-12);
            make.width.height.equalTo(@20);
        }];
        [categoryView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(tagView.mas_bottom);
            make.left.equalTo(view).offset(12);
            make.right.equalTo(view).offset(-12);
            make.bottom.equalTo(view).offset(-15);
            make.width.equalTo(@(SCREEN_WIDTH - 24));
            make.height.equalTo(@(self.categoryViewProductor.height));
        }];
        
        view;
    });

    [self.contentView addSubview:self.categoryView];
}

- (void)loadHotFmView
{
    _hotFMView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        
        UIView *tagView = [[UIView alloc] init];
        tagView.backgroundColor = HEXCOLOR(0x3CB371);
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"热门";
        titleLabel.font = Font(15);
        
        // 数据来了写
        self.hotfmViewProductor.infoArray = _viewModel.indexInfo.hotfmArray;
    
        UIView *hotFmView = [self.hotfmViewProductor loadHotFmView];
        
        [view addSubview:tagView];
        [view addSubview:titleLabel];
        [view addSubview:hotFmView];
        
        [tagView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(view);
            make.height.equalTo(@30);
            make.width.equalTo(@5);
        }];
        [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tagView.mas_right).offset(10);
            make.centerY.equalTo(tagView);
        }];
        [hotFmView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(tagView.mas_bottom);
            make.left.equalTo(view).offset(12);
            make.right.equalTo(view).offset(-12);
            make.bottom.equalTo(view).offset(-15);
        }];
        
        view;
    });
    
    [self.contentView addSubview:self.hotFMView];
}

- (UIView *)loadMoreCellViewWithTitle:(NSString *)title KeyValue:(NSString *)keyValue;
{
    UIView * moreCellView = ({
        UIView *contentView = [[UIView alloc] init];
        
        UILabel *titleLable = [[UILabel alloc] init];
        titleLable.text = title;
        titleLable.textColor = HEXCOLOR(0x666666);
        titleLable.font = Font(11);
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index_item_more"]];
        [contentView addSubview:titleLable];
        [contentView addSubview:imageView];
        
        [titleLable mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(contentView);
            make.centerY.equalTo(imageView);
        }];
        [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLable.mas_right).offset(5);
            make.top.bottom.right.equalTo(contentView);
            make.height.width.equalTo(@15);
        }];
        contentView;
    });
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
    [tapGes.rac_gestureSignal subscribeNext:^(id x) {
        TagListViewController *vc = [[TagListViewController alloc] initWithRows:@(15) KeyString:@"is_teacher" KeyValue:keyValue];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [moreCellView addGestureRecognizer:tapGes];
    
    return moreCellView;
}

- (void)bind
{
    @weakify(self);
    RAC(self, isPlaying) = RACObserve(self.player, isPlaying);
    [[[RACObserve(self, isPlaying) ignore:nil] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if ([x boolValue]) {
            if (!self.playerAnimationImageView.isAnimating) {
                [self.playerAnimationImageView startAnimating];
            }
        } else {
            if (self.playerAnimationImageView.isAnimating) {
                [self.playerAnimationImageView stopAnimating];
            }
        }
    }];
}

- (RadioPlayerViewController *)player
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    return delegate.radioPlayer;
}

- (UIImageView *)playerAnimationImageView
{
    if (!_playerAnimationImageView) {
        _playerAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _playerAnimationImageView.userInteractionEnabled = YES;
        _playerAnimationImageView.image = [UIImage imageNamed:@"y1"];
        NSArray *imageArray = @[[UIImage imageNamed:@"y1"],
                                [UIImage imageNamed:@"y2"],
                                [UIImage imageNamed:@"y3"],
                                [UIImage imageNamed:@"y4"],
                                [UIImage imageNamed:@"y5"],
                                [UIImage imageNamed:@"y6"],
                                ];
        [_playerAnimationImageView setAnimationImages:imageArray];
        [_playerAnimationImageView setAnimationRepeatCount:0];
        [_playerAnimationImageView setAnimationDuration:0.4f];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
        [tapGes.rac_gestureSignal subscribeNext:^(id x) {
            
            [self.navigationController pushViewController:[self player] animated:YES];
        }];
        [_playerAnimationImageView addGestureRecognizer:tapGes];
    }
    return _playerAnimationImageView;
}

@end
