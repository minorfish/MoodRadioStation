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
#import <Masonry/Masonry.h>
#import "MRSCategoryView.h"
#import "UIKitMacros.h"
#import "TagListViewController.h"

@interface MRSFindViewController ()

@property (nonatomic, strong) MRSHotTagADViewController *ADViewController;
@property (nonatomic, weak)   UIView *ADView;
@property (nonatomic, strong) MRSCategoryView *moodCategoryView;
@property (nonatomic, strong) MRSCategoryView *sightCategoryView;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, assign) CGFloat contentViewHeight;

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
    self.view.backgroundColor = HEXCOLOR(0xf0efed);
    self.view.userInteractionEnabled = YES;
    
    self.contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.contentView.userInteractionEnabled = YES;
    
    [self.view addSubview:self.contentView];
    
    [self loadADView];
    [self loadSearchView];
    [self loadMoodCategoryView];
    [self loadSightCategoryView];
    [self.contentView setContentSize:CGSizeMake(SCREEN_WIDTH, self.contentViewHeight)];
}

- (CGFloat)contentViewHeight
{
    CGFloat height = self.ADViewController.adViewHeight;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
    height += [@"心情" sizeWithAttributes:attributes].height;
    height += [@"场景" sizeWithAttributes:attributes].height;
    height += 40 + 55 + SCREEN_WIDTH * 2;
    return height;
}

- (void)loadADView
{
    if (_ADView) {
        [_ADView removeFromSuperview];
    }
    [self.ADViewController loadADView:4 finished:^(UIView *view) {
        self.ADView = view;
        [self.contentView addSubview:self.ADView];
    }];
}

- (void)loadSearchView
{
    self.searchView = [[UIView alloc] init];
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_input"]];
    bgView.userInteractionEnabled = YES;
    
    UIImageView *searchBtn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"find_search_icon"]];
    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.text = @"搜索主播名或节目名";
    hintLabel.font = Font(12);
    hintLabel.textColor = HEXCOLOR(0x999999);
    
    [self.contentView addSubview:self.searchView];
    [self.searchView addSubview:bgView];
    [self.searchView addSubview:hintLabel];
    [self.searchView addSubview:searchBtn];
    
    [_searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(self.ADViewController.adViewHeight + 15));
        make.left.equalTo(@0);
        make.width.equalTo(self.contentView);
        make.height.equalTo(@40);
    }];
    [bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.searchView);
        make.edges.equalTo(self.searchView);
    }];
    [hintLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.centerY.equalTo(self.searchView);
    }];
    [searchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.searchView).offset(-12);
        make.centerY.equalTo(self.searchView);
        make.width.height.equalTo(@20);
    }];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
    [tapGes.rac_gestureSignal subscribeNext:^(id x) {
        NSLog(@"search\n");
    }];
    [bgView addGestureRecognizer:tapGes];
}

- (void)loadMoodCategoryView
{
    UIView *view = [[UIView alloc] init];
    view.userInteractionEnabled = YES;
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"心情";
    titleLabel.font = Font(15);
    
    [view addSubview:titleLabel];
    [view addSubview:self.moodCategoryView];
    self.moodCategoryView.userInteractionEnabled = YES;
    [self.contentView addSubview:view];
    
    [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.top.equalTo(view);
    }];
    [self.moodCategoryView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(5);
        make.left.equalTo(@0);
        make.width.height.equalTo(@(SCREEN_WIDTH));
        make.bottom.equalTo(view);
    }];
    [view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchView.mas_bottom).offset(15);
        make.left.equalTo(@0);
        make.height.equalTo(view.mas_height);
        make.width.equalTo(view.mas_width);
    }];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
    [tapGes.rac_gestureSignal subscribeNext:^(id x) {
        NSLog(@"");
    }];
    [self.moodCategoryView addGestureRecognizer:tapGes];
}

- (void)loadSightCategoryView
{
    UIView *view = [[UIView alloc] init];
    view.userInteractionEnabled = YES;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"场景";
    titleLabel.font = Font(15);
    
    [view addSubview:titleLabel];
    [view addSubview:self.sightCategoryView];
    [self.contentView addSubview:view];
    
    [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@12);
        make.top.equalTo(view);
    }];
    [self.sightCategoryView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(5);
        make.left.equalTo(@0);
        make.width.height.equalTo(@(SCREEN_WIDTH));
        make.bottom.equalTo(view);
    }];
    [view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.moodCategoryView.mas_bottom).offset(15);
        make.left.equalTo(@0);
        make.height.equalTo(view.mas_height);
        make.width.equalTo(view.mas_width);
    }];
}

- (MRSCategoryView *)moodCategoryView
{
    if (!_moodCategoryView) {
        NSArray *images = @[[UIImage imageNamed:@"fanzao"],
                            [UIImage imageNamed:@"beishang"],
                            [UIImage imageNamed:@"gudu"],
                            [UIImage imageNamed:@"yiqiliao"],
                            [UIImage imageNamed:@"jianya"],
                            [UIImage imageNamed:@"wunai"],
                            [UIImage imageNamed:@"kuaile"],
                            [UIImage imageNamed:@"gandong"],
                            [UIImage imageNamed:@"mimang"]];
        NSArray *names = @[@"烦躁",
                           @"悲伤",
                           @"孤独",
                           @"已弃疗",
                           @"减压",
                           @"无奈",
                           @"快乐",
                           @"感动",
                           @"迷茫"];
        _moodCategoryView = [[MRSCategoryView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH) Images:images Names:names Cloumns:3];
        @weakify(self);
        _moodCategoryView.didTag = ^(NSString *tagString) {
            @strongify(self);
            [self didTagWithTagString:tagString];
        };
    }
    return _moodCategoryView;
}

- (MRSCategoryView *)sightCategoryView
{
    if (!_sightCategoryView) {
        NSArray *images = @[[UIImage imageNamed:@"shuiqian"],
                            [UIImage imageNamed:@"lvxing"],
                            [UIImage imageNamed:@"sanbu"],
                            [UIImage imageNamed:@"zuoche"],
                            [UIImage imageNamed:@"duchu"],
                            [UIImage imageNamed:@"shilian"],
                            [UIImage imageNamed:@"shimian"],
                            [UIImage imageNamed:@"suibian"],
                            [UIImage imageNamed:@"wuliao"]];
        NSArray *names = @[@"睡前",
                           @"旅行",
                           @"散步",
                           @"坐车",
                           @"独处",
                           @"失恋",
                           @"失眠",
                           @"随便",
                           @"无聊"];
        _sightCategoryView = [[MRSCategoryView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH) Images:images Names:names Cloumns:3];
        _sightCategoryView.userInteractionEnabled = YES;
        @weakify(self);
        _sightCategoryView.didTag = ^(NSString *tagString) {
            @strongify(self);
            [self didTagWithTagString:tagString];
        };
    }
    return _sightCategoryView;
}

- (void)didTagWithTagString:(NSString *)tagString
{
    TagListViewController *vc = [[TagListViewController alloc] initWithRows:@(15) KeyString:@"tag" KeyValue:tagString];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%@", self);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isInside = [self.view pointInside:point withEvent:event];
    return isInside ? self : nil;
}

@end
