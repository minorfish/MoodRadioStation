//
//  MRSPlayerImageAnimationLoadingView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/8.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSPlayerImageAnimationLoadingView.h"
#import <Masonry/Masonry.h>

@implementation MRSPlayerImageAnimationLoadingView {
    UIImageView *_imageView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self  = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:_imageView];
        [self needsUpdateConstraints];
    }
    return self;
}

- (void)setImagesArray:(NSArray *)imagesArray
{
    _imageView.animationImages = imagesArray;
}

- (void)startAnimation
{
    if (!_imageView.isAnimating) {
        [_imageView startAnimating];
    }
}

- (void)stopAnimation
{
    [_imageView stopAnimating];
}

- (BOOL)isAnimating
{
    return _imageView.isAnimating;
}

- (void)setAnimationDuration:(NSTimeInterval)animationDuration
{
    _imageView.animationDuration = animationDuration;
}

- (void)setAnimationRepeatCount:(NSInteger)animationRepeatCount
{
    _imageView.animationRepeatCount = animationRepeatCount;
}

- (void)updateConstraints
{
    [super updateConstraints];
    [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

@end
