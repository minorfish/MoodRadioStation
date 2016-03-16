//
//  MRSSettingViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/15.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSSettingViewController.h"
#import "MRSDingshiView.h"
#import "MRSTimerView.h"
#import "UIKitMacros.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "MRSDingshiManager.h"
#import "AppDelegate.h"
#import "RadioPlayerViewController.h"

extern NSString *MRSMRSPauseDisplayLinkNotification;
@interface MRSSettingViewController ()

@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) MRSTimerView *timerView;
@property (nonatomic, strong) MRSDingshiView *dingshiView;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIView *topSeperateLine;
@property (nonatomic, strong) UIView *bottomSeperateLine;
@property (nonatomic, strong) UIView *leftSeperateLine;
@property (nonatomic, strong) UIView *rightSeperateLine;
@property (nonatomic, strong) NSDate *now;
@property (nonatomic, assign) NSTimeInterval dingshiTime;

@end

@implementation MRSSettingViewController

- (void)viewDidLoad
{
    self.view.backgroundColor = HEXCOLOR(0xf0efed);
    [self setupUI];
}

- (void)dealloc
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)bind
{
    @weakify(self);
    [RACObserve(self.dingshiView, isOn) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if ([x boolValue]) {
            [self startTimerWithTime:15*60];
        } else {
            [self stopTimer];
        }
        self.timerView.hidden = ![x boolValue];
        [UIView animateWithDuration:0.2 animations:^{
            @strongify(self);
            [self.view setNeedsUpdateConstraints];
        }];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction) name:MRSMRSPauseDisplayLinkNotification object:nil];
}

- (void)setupUI
{
    [self bind];
    self.contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:self.contentView];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.dingshiView];
    [self.contentView addSubview:self.timerView];
    [self.contentView addSubview:self.topSeperateLine];
    [self.contentView addSubview:self.bottomSeperateLine];
    [self.contentView addSubview:self.leftSeperateLine];
    [self.contentView addSubview:self.rightSeperateLine];
    [self.contentView setNeedsLayout];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
        make.size.equalTo(self.view);
    }];
    [_topSeperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12);
        make.left.equalTo(self.contentView).offset(12);
        make.right.equalTo(self.contentView).offset(-12);
        make.height.equalTo(@0.5);
    }];
    [_dingshiView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topSeperateLine.mas_bottom);
        make.left.equalTo(self.topSeperateLine).offset(0.5);
        make.right.equalTo(self.topSeperateLine).offset(-0.5);
    }];
    if (!_timerView.hidden) {
        [_timerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.dingshiView.mas_bottom);
            make.left.equalTo(self.dingshiView);
        }];
    }
    [_bottomSeperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (!self.timerView.hidden) {
            make.top.equalTo(self.timerView.mas_bottom);
        } else {
            make.top.equalTo(self.dingshiView.mas_bottom);
        }
        make.left.right.height.equalTo(self.topSeperateLine);
        make.bottom.equalTo(self.contentView);
    }];
    [_leftSeperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topSeperateLine.mas_bottom);
        make.bottom.equalTo(self.bottomSeperateLine.mas_top);
        make.width.equalTo(@0.5);
        make.right.equalTo(self.dingshiView.mas_left);
        make.left.equalTo(self.contentView);
    }];
    [_rightSeperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.width.equalTo(self.leftSeperateLine);
        make.left.equalTo(self.dingshiView.mas_right);
        make.right.equalTo(self.contentView);
    }];
}

- (MRSDingshiView *)dingshiView
{
    if (!_dingshiView) {
        _dingshiView = [[MRSDingshiView alloc] init];
    }
    return _dingshiView;
}

- (MRSTimerView *)timerView
{
    if (!_timerView) {
        _timerView = [[MRSTimerView alloc] initWithTimeArray:[NSArray arrayWithObjects:@1, @30, @60, @90, nil]];
        @weakify(self);
        _timerView.didTap = ^(NSTimeInterval time){
            @strongify(self);
            [self startTimerWithTime:time];
        };
    }
    return _timerView;
}

- (CADisplayLink *)displayLink
{
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink.paused = NO;
    }
    return _displayLink;
}

- (UIView *)topSeperateLine
{
    if (!_topSeperateLine) {
        _topSeperateLine = [[UIView alloc] init];
        _topSeperateLine.backgroundColor = HEXCOLOR(0xe5e5e5);
    }
    return _topSeperateLine;
}

- (UIView *)bottomSeperateLine
{
    if (!_bottomSeperateLine) {
        _bottomSeperateLine = [[UIView alloc] init];
        _bottomSeperateLine.backgroundColor = HEXCOLOR(0xe5e5e5);
    }
    return _bottomSeperateLine;
}

- (UIView *)leftSeperateLine
{
    if (!_leftSeperateLine) {
        _leftSeperateLine = [[UIView alloc] init];
        _leftSeperateLine.backgroundColor = HEXCOLOR(0xe5e5e5);
    }
    return _leftSeperateLine;
}

- (UIView *)rightSeperateLine
{
    if (!_rightSeperateLine) {
        _rightSeperateLine = [[UIView alloc] init];
        _rightSeperateLine.backgroundColor = HEXCOLOR(0xe5e5e5);
    }
    return _rightSeperateLine;
}

- (void)displayLinkAction:(CADisplayLink *)dis
{
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.now];
    self.dingshiView.timeLabel.text = [self formatTime:(self.dingshiTime - time)];
}

- (void)notificationAction
{
    self.displayLink.paused = YES;
    self.dingshiView.timeLabel.text = nil;
    self.now = nil;
    if ([self.dingshiView.isOn boolValue]) {
        self.dingshiView.isOn = @(NO);
    }
}

- (NSString *)formatTime:(int)num
{
    int sec = num % 60;
    int min = num / 60;
    if(num < 60){
        return [NSString stringWithFormat:@"-00:%02d",num];
    }
    return [NSString stringWithFormat:@"-%02d:%02d",min,sec];
}

- (void)startTimerWithTime:(NSTimeInterval)time
{
    [MRSDingshiManager cancelNotificationsForType:@"closePlay"];
    self.dingshiTime = time;
    self.now = [NSDate dateWithTimeIntervalSinceNow:0];
    [MRSDingshiManager scheduleClosePlayOnDate:[[NSDate alloc]initWithTimeInterval:time sinceDate:self.now]];
    self.displayLink.paused = NO;
}

- (void)stopTimer
{
    [self notificationAction];
    [MRSDingshiManager cancelNotificationsForType:@"closePlay"];
}

@end
