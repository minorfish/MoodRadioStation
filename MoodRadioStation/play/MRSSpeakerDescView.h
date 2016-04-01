//
//  MRSSpeakerDescView.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/8.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSCircleImageView;

@interface MRSSpeakerDescView : UIView

@property (nonatomic, strong) MRSCircleImageView *circleImageView;
@property (nonatomic, strong) UILabel *fmNumLabel;
@property (nonatomic, strong) UILabel *speakerNameLabel;
@property (nonatomic, strong) UIImageView *downLoadImage;

@end
