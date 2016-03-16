//
//  MRSDingshiView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/15.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSDingshiView.h"
#import "UIKitMacros.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MRSDingshiView ()

@property (nonatomic, strong) UIImageView *dingshiImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *switchBtn;

@end

@implementation MRSDingshiView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.dingshiImageView];
        [self addSubview:self.timeLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.switchBtn];
        self.isOn = @(NO);
        [self setNeedsDisplay];
    }
    return self;
}

- (void)setIsOn:(NSNumber *)isOn
{
    _isOn = isOn;
    [self.switchBtn setImage:[UIImage imageNamed:[isOn boolValue]? @"on": @"off"]];
}

- (UIImageView *)dingshiImageView
{
    if (!_dingshiImageView) {
        _dingshiImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dingshi"]];
    }
    return _dingshiImageView;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = Font(12);
        _timeLabel.textColor = HEXCOLOR(0x666666);
    }
    return _timeLabel;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = Font(15);
        _titleLabel.text = @"定时关闭";
    }
    return _titleLabel;
}

- (UIImageView *)switchBtn
{
    if (!_switchBtn) {
        _switchBtn = [[UIImageView alloc] init];
        _switchBtn.userInteractionEnabled = YES;
        _switchBtn.layer.masksToBounds = YES;
        _switchBtn.layer.cornerRadius = 15;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
        [tapGes.rac_gestureSignal subscribeNext:^(id x) {
            self.isOn = @(![self.isOn boolValue]);
        }];
        [_switchBtn addGestureRecognizer:tapGes];
        _switchBtn.layer.backgroundColor = [UIColor whiteColor].CGColor;
    }
    return _switchBtn;
}

- (void)updateConstraints
{
    [super updateConstraints];
    @weakify(self);
    [self.dingshiImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.top.equalTo(self).offset(15);
        make.bottom.equalTo(self).offset(-15);
        make.width.height.equalTo(@30);
    }];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.dingshiImageView.mas_right).offset(15);
        make.centerY.equalTo(self.dingshiImageView);
    }];
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.titleLabel.mas_right).offset(20);
        make.centerY.equalTo(self.dingshiImageView);
    }];
    [self.switchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.dingshiImageView);
        make.right.equalTo(self).offset(-15);
        make.width.equalTo(@45);
        make.height.equalTo(@30);
    }];
}


@end
