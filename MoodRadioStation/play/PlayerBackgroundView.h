//
//  PlayerBackgroundView.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSURLImageView;

@interface PlayerBackgroundView : UIView

@property (nonatomic, strong) MRSURLImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, copy) void(^block)();

@end
