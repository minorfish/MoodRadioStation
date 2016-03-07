//
//  MRSImageAnimationLoadingView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSImageAnimationLoadingView.h"
#import "UIKitMacros.h"
#import <Masonry/Masonry.h>

@implementation MRSImageAnimationLoadingView {
    UIActivityIndicatorView *_activityIndicatorView;
}

+ (MRSImageAnimationLoadingView *)loadingViewByView:(UIView *)showView
{
    CGPoint center = CGPointMake(showView.frame.size.width/2, showView.frame.size.height/2);
    CGSize size = CGSizeMake(150, 100);
    CGRect frame = CGRectMake(center.x - size.width/2, center.y - size.height/2, size.width, size.height);
    MRSImageAnimationLoadingView *imageAnimationLoadingView = [[MRSImageAnimationLoadingView alloc] initWithFrame:frame Color:[UIColor whiteColor]];
    return imageAnimationLoadingView;
}

- (instancetype)initWithFrame:(CGRect)frame Color:(UIColor *)color
{
    self = [super init];
    if (self) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        UIView *loadingView = [[UIView alloc] initWithFrame:frame];
        loadingView.backgroundColor = HEXACOLOR(0x000000, 0.5);
        loadingView.layer.cornerRadius = 8;
        [loadingView addSubview:_activityIndicatorView];
        
        UILabel *loadLable = [[UILabel alloc] init];
        loadLable.textColor = [UIColor whiteColor];
        loadLable.font = Font(14);
        loadLable.text = @"正在刷新";
        [loadingView addSubview:loadLable];
        
        [_activityIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(loadingView);
            make.top.equalTo(@15);
        }];
        [loadLable mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(loadingView);
            make.top.equalTo(_activityIndicatorView.mas_bottom).offset(10);
            make.bottom.equalTo(loadingView).offset(-15);
        }];
        [self addSubview:loadingView];
    }
    return self;
}

- (void)startAnimation
{
    self.hidden = NO;
    [_activityIndicatorView startAnimating];
}

- (void)stopAnimation
{
    self.hidden = YES;
    [_activityIndicatorView stopAnimating];
}

- (void)dealloc
{
    [self stopAnimation];
}

@end
