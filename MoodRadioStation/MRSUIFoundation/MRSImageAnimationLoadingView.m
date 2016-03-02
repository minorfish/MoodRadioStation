//
//  MRSImageAnimationLoadingView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSImageAnimationLoadingView.h"

@implementation MRSImageAnimationLoadingView {
    UIActivityIndicatorView *_activityIndicatorView;
}

+ (MRSImageAnimationLoadingView *)loadingViewByView:(UIView *)showView
{
    CGPoint center = CGPointMake(showView.frame.size.width/2, showView.frame.size.height/2);
    CGSize size = CGSizeMake(200, 200);
    CGRect frame = CGRectMake(center.x - size.width/2, center.y - size.height/2, size.width, size.height);
    MRSImageAnimationLoadingView *imageAnimationLoadingView = [[MRSImageAnimationLoadingView alloc] initWithFrame:frame Color:[UIColor blueColor]] ;
    return imageAnimationLoadingView;
}

- (instancetype)initWithFrame:(CGRect)frame Color:(UIColor *)color
{
    self = [super init];
    if (self) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
        _activityIndicatorView.color = color;
        [self addSubview:_activityIndicatorView];
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
