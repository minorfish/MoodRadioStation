//
//  MRSIndexCategoryView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/14.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSIndexCategoryViewProductor.h"
#import "MRSIndexCategory.h"
#import "UIKitMacros.h"
#import "MRSCircleImageView.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MRSIndexCategoryViewProductor ()

@property (nonatomic, assign) CGFloat height;

@end

@implementation MRSIndexCategoryViewProductor

- (UIView *)loadCategoryView
{
    UIView *categotyView = [[UIView alloc] init];
    
    UIView *fragmentView = nil;
    UIView *preView = nil;
    CGFloat width = (SCREEN_WIDTH - 24) / self.cloumn;
    CGFloat height = width - 15;
    CGFloat top = 0;
    for (int i = 0; i < self.infoArray.count; i++) {
        if (i % _cloumn == 0) {
            if (fragmentView) {
                [categotyView addSubview:fragmentView];
                preView = nil;
                fragmentView = nil;
            }
            fragmentView = [[UIView alloc] initWithFrame:CGRectMake(0, top, width * self.cloumn, height)];
            top += height;
        }
        UIView *categoryView = [self createCategoryViewWithIndex:i];
        [fragmentView addSubview:categoryView];
        [categoryView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (preView) {
                make.left.equalTo(preView.mas_right);
            } else {
                make.left.equalTo(@0);
            }
            make.width.equalTo(@(width));
            make.centerY.equalTo(fragmentView);
        }];
        preView = categoryView;
    }
    if (fragmentView) {
        [categotyView addSubview:fragmentView];
    }
    self.height = top;
    return categotyView;
}


- (UIView *)createCategoryViewWithIndex:(NSInteger)index
{
    MRSIndexCategory *infoCategoty = [self.infoArray objectAtIndex:index];
    UIView *view = [[UIView alloc] init];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = Font(11);
    nameLabel.text = infoCategoty.name;
    
    MRSCircleImageView *imageView = [[MRSCircleImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    imageView.URLString = infoCategoty.coverURL;
    
    [view addSubview:nameLabel];
    [view addSubview:imageView];
    
    [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view);
        make.centerX.equalTo(view);
        make.width.height.equalTo(@40);
    }];
    
    [nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(5);
        make.centerX.equalTo(view);
        make.bottom.equalTo(view);
    }];
    UITapGestureRecognizer *tabGes = [[UITapGestureRecognizer alloc] init];
    [tabGes.rac_gestureSignal subscribeNext:^(id x) {
        if (self.didTap) {
            self.didTap(index + 1, infoCategoty.name);
        }
    }];
    [view addGestureRecognizer:tabGes];
    return view;
}

@end
