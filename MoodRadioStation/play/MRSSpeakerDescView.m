//
//  MRSSpeakerDescView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/8.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSSpeakerDescView.h"
#import "MRSCircleImageView.h"
#import "UIKitMacros.h"
#import <Masonry/Masonry.h>

@implementation MRSSpeakerDescView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.circleImageView];
        [self addSubview:self.fmNumLabel];
        [self addSubview:self.speakerNameLabel];
        [self addSubview:self.downLoadImage];
        
        [_circleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self).offset(12);
            make.bottom.equalTo(self).offset(-12);
            make.width.height.equalTo(@60);
        }];
        [_speakerNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.circleImageView);
            make.left.equalTo(self.circleImageView.mas_right).offset(30);
        }];
        [_fmNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.speakerNameLabel.mas_bottom).offset(10);
            make.left.equalTo(self.speakerNameLabel);
        }];
        [_downLoadImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-15);
            make.width.height.equalTo(@30);
        }];
    }
    return self;
}

- (MRSCircleImageView *)circleImageView
{
    if (!_circleImageView) {
        _circleImageView = [[MRSCircleImageView alloc] init];
        _circleImageView.defaultImage = [UIImage imageNamed:@"default_circle_avatar"];
        _circleImageView.loadingImage = [UIImage imageNamed:@"default_circle_avatar"];
    }
    return _circleImageView;
}

- (UILabel *)fmNumLabel
{
    if (!_fmNumLabel) {
        _fmNumLabel = [[UILabel alloc] init];
        _fmNumLabel.textColor = HEXCOLOR(0x666666);
        _fmNumLabel.font = Font(14);
    }
    return _fmNumLabel;
}

- (UILabel *)speakerNameLabel
{
    if (!_speakerNameLabel) {
        _speakerNameLabel = [[UILabel alloc] init];
        _speakerNameLabel.textColor = HEXCOLOR(0x666666);
        _speakerNameLabel.font = Font(14);
    }
    return _speakerNameLabel;
}

- (UIImageView *)downLoadImage
{
    if (!_downLoadImage) {
        _downLoadImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_download"]];
    }
    return _downLoadImage;
}

@end
