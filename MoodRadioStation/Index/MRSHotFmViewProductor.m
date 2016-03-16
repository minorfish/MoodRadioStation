//
//  MRSHotFmView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/14.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSHotFmViewProductor.h"
#import "RadioInfo.h"
#import "MRSURLImageView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Masonry/Masonry.h>
#import "UIKitMacros.h"

@interface MRSHotFmViewProductor ()

@property (nonatomic, assign) CGFloat height;

@end

@implementation MRSHotFmViewProductor

- (UIView *)loadHotFmView
{
    UIView *hotFmView = [[UIView alloc] init];
    
    UIView *preView = nil;
    CGFloat width = (SCREEN_WIDTH - 24) / self.cloumn;
    CGFloat height = width + 20;
    CGFloat top = 0;
    for (int i = 0; i < self.infoArray.count; i++) {
        
        UIView *fmView = [self createHotFmViewWithIndex:i];
        [hotFmView addSubview:fmView];
        
        if (i && i % _cloumn == 0) {
            top += height;
            preView = nil;
        }
        [fmView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (preView) {
                make.left.equalTo(preView.mas_right);
            } else {
                make.left.top.equalTo(@0);
            }
            make.top.equalTo(@(top));
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
            if (i % _cloumn == self.cloumn - 1) {
                make.right.equalTo(fmView);
            }
            if (i == self.infoArray.count - 1) {
                make.bottom.equalTo(hotFmView);
            }
        }];
        preView = fmView;
    }
    if (preView) {
        top += height;
    }
    self.height = top;
    return hotFmView;
}

- (UIView *)createHotFmViewWithIndex:(NSInteger)index
{
    RadioInfo *info = [self.infoArray objectAtIndex:index];
    UIView *view = [[UIView alloc] init];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = Font(13);
    nameLabel.text = info.title;
    nameLabel.numberOfLines = 2;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    
    MRSURLImageView *imageView = [[MRSURLImageView alloc] init];
    imageView.URLString = info.coverURL;
    
    [view addSubview:nameLabel];
    [view addSubview:imageView];
    
    [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view);
        make.centerX.equalTo(view);
        make.width.height.equalTo(@(100 * scaleFactorBaseiPhone6));
    }];
    
    [nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(5);
        make.left.right.equalTo(imageView);
    }];
    UITapGestureRecognizer *tabGes = [[UITapGestureRecognizer alloc] init];
    [tabGes.rac_gestureSignal subscribeNext:^(id x) {
        if (self.didTap) {
            self.didTap(index, self.infoArray);
        }
    }];
    [view addGestureRecognizer:tabGes];
    return view;
}

@end
