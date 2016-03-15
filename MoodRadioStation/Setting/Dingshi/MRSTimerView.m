//
//  MRSTimerView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/15.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSTimerView.h"
#import "UIKitMacros.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MRSTimerView ()

@property (nonatomic, strong) UIImageView *dingshibg;
@property (nonatomic, strong) UIImageView *dingshiSeek;
@property (nonatomic, strong) UIView *timeView;
@property (nonatomic, strong) UIView *seperateLine;
@property (nonatomic, strong) NSArray *timeArray;
@property (nonatomic, strong) NSMutableArray *labelArray;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UILabel *firstLabel;
@property (nonatomic, strong) UILabel *lastLabel;
@property (nonatomic, strong) UILabel *currentLabel;
@property (nonatomic, assign) CGFloat width;

@end

@implementation MRSTimerView

- (instancetype)initWithTimeArray:(NSArray *)timeArray
{
    self = [super init];
    if (self) {
        _timeArray = timeArray;
        _labelArray = [[NSMutableArray alloc] init];
        
        [self addSubview:self.seperateLine];
        [self addSubview:self.dingshibg];
        [self addSubview:self.dingshiSeek];
        [self addSubview:self.timeView];
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
        _width = [self.firstLabel.text sizeWithAttributes:attributes].width;
        
        [self setNeedsLayout];
        
        @weakify(self);
        [RACObserve(self, currentIndex) subscribeNext:^(id x) {
            [UIView animateWithDuration:0.2 animations:^{
                @strongify(self);
                [self setNeedsUpdateConstraints];
            }];
        }];
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    @weakify(self);
    [self.seperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self);
        make.left.equalTo(self).offset(12);
        make.right.equalTo(self).offset(-12);
        make.height.equalTo(@0.5);
        make.width.equalTo(@(SCREEN_WIDTH - 48));
    }];
    [self.timeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.seperateLine.mas_bottom).offset(12);
        make.left.equalTo(self.seperateLine);
    }];
    [self.dingshibg mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.timeView.mas_bottom);
        make.height.equalTo(@25);
        make.left.equalTo(self.firstLabel.mas_centerX).offset(-self.width/2);
        make.right.equalTo(self.lastLabel.mas_centerX).offset(self.width/2);
        make.bottom.equalTo(self).offset(-12);
    }];
    [self.dingshiSeek mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.dingshibg);
        make.centerX.equalTo(self.currentLabel.mas_centerX);
        make.width.height.equalTo(@20);
    }];
}

- (UIImageView *)dingshibg
{
    if (!_dingshibg) {
        _dingshibg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dingshibg"]];
    }
    return _dingshibg;
}

- (UIImageView *)dingshiSeek
{
    if (!_dingshiSeek) {
        _dingshiSeek = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dingshiseek"]];
        _dingshiSeek.layer.masksToBounds = YES;
        _dingshiSeek.layer.cornerRadius = 10;
        _dingshiSeek.layer.backgroundColor = [UIColor whiteColor].CGColor;
    }
    return _dingshiSeek;
}

- (UIView *)timeView
{
    if (!_timeView) {
        _timeView = ({
            UIView *view = [[UIView alloc] init];
            UIView *preView = nil;
            CGFloat width = (SCREEN_WIDTH - 24 - 75)/self.timeArray.count;
            int i = 0;
            for (NSNumber *time in self.timeArray) {
                i++;
                UILabel *timeLabel = [self createLabelWithText:[NSString stringWithFormat:@"%@分", time]];
                [self.labelArray addObject:timeLabel];
                
                UIView *labelView = [[UIView alloc] init];
                [labelView addSubview:timeLabel];
                [timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.center.equalTo(labelView);
                    make.top.bottom.equalTo(labelView);
                }];
                
                [view addSubview:labelView];
                [labelView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    if (!preView) {
                        make.left.equalTo(view);
                    } else {
                        make.left.equalTo(preView.mas_right);
                    }
                    make.width.equalTo(@(width));
                    make.top.bottom.equalTo(view);
                    if (i == self.timeArray.count) {
                        make.right.equalTo(view);
                    }
                }];
                preView = labelView;
                
                UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
                [tapGes.rac_gestureSignal subscribeNext:^(id x) {
                    self.currentIndex = i - 1;
                    if (self.didTap) {
                        self.didTap([time longLongValue] * 60);
                    }
                }];
                [labelView addGestureRecognizer:tapGes];
            }
            view;
        });
    }
    return _timeView;
}

- (UIView*)seperateLine
{
    if (!_seperateLine) {
        _seperateLine = [[UIView alloc] init];
        _seperateLine.backgroundColor = HEXCOLOR(0xe5e5e5);
    }
    return _seperateLine;
}

- (UILabel *)createLabelWithText:(NSString *)text
{
    UILabel *lable = [[UILabel alloc] init];
    lable.text = text;
    lable.font = Font(12);
    lable.textColor = HEXCOLOR(0x666666);
    lable.userInteractionEnabled = YES;
    lable.textAlignment = NSTextAlignmentCenter;
    return lable;
}

- (UILabel *)firstLabel
{
    return [self.labelArray objectAtIndex:0];
}

- (UILabel *)lastLabel
{
    return [self.labelArray lastObject];
}

- (UILabel *)currentLabel
{
    return [self.labelArray objectAtIndex:self.currentIndex];
}

@end
