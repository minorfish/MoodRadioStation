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
#import "MRSPersistentCacheManager.h"

extern NSString *MRSMRSPauseDisplayLinkNotification;
@interface MRSSettingViewController ()

@property (nonatomic, strong) UIScrollView *contentView;
@property (nonatomic, strong) MRSTimerView *timerView;
@property (nonatomic, strong) MRSDingshiView *dingshiView;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIView *barView;

@property (nonatomic, strong) UIView *topSeperateLine;
@property (nonatomic, strong) UIView *bottomSeperateLine;
@property (nonatomic, strong) UIView *leftSeperateLine;
@property (nonatomic, strong) UIView *rightSeperateLine;
@property (nonatomic, strong) NSDate *now;
@property (nonatomic, assign) NSTimeInterval dingshiTime;

@property (nonatomic, strong) UIImageView *playerAnimationImageView;
@property (nonatomic, strong) RadioPlayerViewController *player;
@property (nonatomic, strong) NSNumber *isPlaying;

@property (nonatomic, strong) UIView *cleanImageCacheView;
@property (nonatomic, strong) UILabel *cacheSizeLabel;
@property (nonatomic, strong) MRSPersistentCacheManager *cacheManager;

@end

@implementation MRSSettingViewController

- (void)viewDidLoad
{
//    self.view.backgroundColor = HEXCOLOR(0xf0efed);
    [self setupUI];
}

- (void)dealloc
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isPlaying = self.player.isPlaying;
    self.cacheSizeLabel.text = [self translateFileSizeByte:self.cacheManager.cacheSize];
    if (!self.navigationController.navigationBar.hidden) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
}

- (void)bind
{
    @weakify(self);
    RAC(self, isPlaying) = RACObserve(self.player, isPlaying);
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
    
    [[[RACObserve(self, isPlaying) ignore:nil] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if ([x boolValue]) {
            if (!self.playerAnimationImageView.isAnimating) {
                [self.playerAnimationImageView startAnimating];
            }
        } else {
            if (self.playerAnimationImageView.isAnimating) {
                [self.playerAnimationImageView stopAnimating];
            }
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction) name:MRSMRSPauseDisplayLinkNotification object:nil];
}

- (void)setupUI
{
    [self bind];
    
    [self.view addSubview:self.barView];
    [self.view addSubview:self.dingshiView];
    [self.view addSubview:self.timerView];
    [self.view addSubview:self.topSeperateLine];
    [self.view addSubview:self.bottomSeperateLine];
    [self.view addSubview:self.leftSeperateLine];
    [self.view addSubview:self.rightSeperateLine];
    [self.view addSubview:self.cleanImageCacheView];
    [self.view setNeedsLayout];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    [_barView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view).offset(24);
        make.height.equalTo(@40);
        make.width.equalTo(@SCREEN_WIDTH);
    }];
    [_topSeperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.barView.mas_bottom).offset(12);
        make.left.equalTo(self.view).offset(12);
        make.right.equalTo(self.view).offset(-12);
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
    [_cleanImageCacheView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (!self.timerView.hidden) {
            make.top.equalTo(self.timerView.mas_bottom);
        } else {
            make.top.equalTo(self.dingshiView.mas_bottom);
        }
        make.left.right.equalTo(_dingshiView);
    }];
    
    [_bottomSeperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
//        if (!self.timerView.hidden) {
//            make.top.equalTo(self.timerView.mas_bottom);
//        } else {
//            make.top.equalTo(self.dingshiView.mas_bottom);
//        }
        make.top.equalTo(_cleanImageCacheView.mas_bottom);
        make.left.right.height.equalTo(self.topSeperateLine);
//        make.bottom.equalTo(self.view);
    }];
    [_leftSeperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topSeperateLine.mas_bottom);
        make.bottom.equalTo(self.bottomSeperateLine.mas_top);
        make.width.equalTo(@0.5);
        make.right.equalTo(self.dingshiView.mas_left);
    }];
    [_rightSeperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.width.equalTo(self.leftSeperateLine);
        make.left.equalTo(self.dingshiView.mas_right);
    }];
}

- (NSString *)translateFileSizeByte:(unsigned long long)fileSize
{
    NSString *size = nil;
    if (fileSize >= pow(1000, 3)) {
        size = [NSString stringWithFormat:@"%.2lfG", (double)fileSize / pow(1000, 3)];
    } else if (fileSize >= pow(1000, 2)) {
        size = [NSString stringWithFormat:@"%.2lfM", (double)fileSize / pow(1000, 2)];
    } else if (fileSize >= pow(1000, 1)) {
        size = [NSString stringWithFormat:@"%.2lfK", (double)fileSize / pow(1000, 1)];
    } else {
        size = [NSString stringWithFormat:@"%@B", @(fileSize)];
    }
    return size;
}

- (UIView *)barView
{
    if (!_barView) {
        _barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        UILabel *title = [[UILabel alloc] init];
        title.text = @"设置";
        title.font = Font(14);
        title.textColor = HEXCOLOR(0x666666);
        UIView *seperateLine = [[UIView alloc] init];
        seperateLine.backgroundColor = HEXCOLOR(0xe5e5e5);
        
        [_barView addSubview:title];
        [_barView addSubview:self.playerAnimationImageView];
        [_barView addSubview:seperateLine];
        
        [title mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_barView);
        }];
        [_playerAnimationImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(title);
            make.right.equalTo(_barView).offset(-12);
            make.height.width.equalTo(@20);
        }];
        [seperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_barView);
            make.width.equalTo(_barView);
            make.height.equalTo(@0.5);
        }];
    }
    return _barView;
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

- (RadioPlayerViewController *)player
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    return delegate.radioPlayer;
}

- (UIImageView *)playerAnimationImageView
{
    if (!_playerAnimationImageView) {
        _playerAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _playerAnimationImageView.userInteractionEnabled = YES;
        _playerAnimationImageView.image = [UIImage imageNamed:@"y1"];
        NSArray *imageArray = @[[UIImage imageNamed:@"y1"],
                                [UIImage imageNamed:@"y2"],
                                [UIImage imageNamed:@"y3"],
                                [UIImage imageNamed:@"y4"],
                                [UIImage imageNamed:@"y5"],
                                [UIImage imageNamed:@"y6"],
                                ];
        [_playerAnimationImageView setAnimationImages:imageArray];
        [_playerAnimationImageView setAnimationRepeatCount:0];
        [_playerAnimationImageView setAnimationDuration:0.4f];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
        [tapGes.rac_gestureSignal subscribeNext:^(id x) {
            
            [self.navigationController pushViewController:[self player] animated:YES];
        }];
        [_playerAnimationImageView addGestureRecognizer:tapGes];
    }
    return _playerAnimationImageView;
}

- (UIView *)cleanImageCacheView
{
    if (!_cleanImageCacheView) {
        _cleanImageCacheView = [[UIView alloc] init];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_clean_icon"]];
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = Font(15);
        titleLabel.text = @"清理图片缓存";
        
        _cacheSizeLabel = [[UILabel alloc] init];
        _cacheSizeLabel.font = Font(15);
        _cacheSizeLabel.tintColor = HEXCOLOR(0x999999);
        
        UIView *seperateLine = [[UIView alloc] init];
        seperateLine.backgroundColor = HEXCOLOR(0xe5e5e5);
        
        [_cleanImageCacheView addSubview:seperateLine];
        [_cleanImageCacheView addSubview:imageView];
        [_cleanImageCacheView addSubview:titleLabel];
        [_cleanImageCacheView addSubview:_cacheSizeLabel];
        
        [seperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(_cleanImageCacheView);
            make.height.equalTo(@0.5);
        }];
        
        [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(seperateLine).offset(15);
            make.top.equalTo(seperateLine.mas_bottom).offset(15);
            make.bottom.equalTo(_cleanImageCacheView).offset(-15);
            make.height.width.equalTo(@30);
        }];
        
        [titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(imageView);
            make.left.equalTo(imageView.mas_right).offset(15);
        }];
        
        [_cacheSizeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(imageView);
            make.right.equalTo(_cleanImageCacheView).offset(-15);
        }];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
        [tapGes.rac_gestureSignal subscribeNext:^(id x) {
            [self.cacheManager cleanCache];
            self.cacheSizeLabel.text = @"0K";
        }];
        [_cleanImageCacheView addGestureRecognizer:tapGes];
    }
    return _cleanImageCacheView;
}

- (MRSPersistentCacheManager *)cacheManager
{
    if (!_cacheManager) {
        _cacheManager = [[MRSPersistentCacheManager alloc] init];
        _cacheManager.directory = @"default/com.hackemist.SDWebImageCache.default";
    }
    return _cacheManager;
}

@end
