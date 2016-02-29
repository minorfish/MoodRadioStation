//
//  RadioPlayerViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/2/27.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "RadioPlayerViewController.h"
#import "RadioViewModel.h"
#import "RadioInfo.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIKitMacros.h"
#import <Masonry/Masonry.h>

const NSString* RPRefreshProgressViewNotification = @"com.minor.notification.refrshProgress";

@interface RadioPlayerViewController ()

@property (nonatomic, strong) RadioViewModel *viewModel;
@property (nonatomic, strong) NSNumber *radioID;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) UIImageView *playButton;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UITextView *timeView;

@property (nonatomic, strong) NSNumber *remainTime;
@property (nonatomic, strong) NSNumber *isPlaying;

@end

@implementation RadioPlayerViewController

- (instancetype)initWithRadioID:(NSNumber *)radioID
{
    self = [super init];
    if (self) {
        _radioID = radioID;
        _viewModel = [[RadioViewModel alloc] init];
        _isPlaying = @(NO);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self bind];
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:RPRefreshProgressViewNotification object:nil] deliverOnMainThread] subscribeNext:^(NSNotification *x) {
        if ([x isKindOfClass:[NSNotification class]]) {
            [self refreshProgressView];
        }
    }];
    
    [[self.viewModel.getRadioInfoCommand execute:self.radioID] subscribeNext:^(RadioInfo *radioInfo) {
        // 下载音频
        [[self.viewModel.getRadioCommand execute:radioInfo.URL] subscribeNext:^(id x) {
            [self setupUI];
        }];
        // 下载图片
    }];
}

- (void)bind
{
    @weakify(self);
    [RACObserve(self, isPlaying) subscribeNext:^(NSNumber *isPlaying)  {
        @strongify(self);
        if ([isPlaying boolValue]) {
            [self.playButton setImage:[UIImage imageNamed:@"pause"]];
        } else {
            [self.playButton setImage:[UIImage imageNamed:@"play"]];
        }
    }];
    
    [RACObserve(self, remainTime) subscribeNext:^(NSNumber *remainTime) {
        @strongify(self);
        self.timeView.text = [NSString stringWithFormat:@"-%@",[self.viewModel formatTime:[remainTime integerValue]]];
    }];
}

- (void)refreshProgressView
{
    self.shapeLayer.strokeEnd = self.viewModel.progress;
    self.remainTime = @((1 - self.viewModel.progress) * self.viewModel.durationTime);
}

- (void)setupUI
{
    [self loadPictureView];
    [self loadPlayerView];
    [self loadDescriptionView];
}

- (void)loadPlayerView
{
    self.playerView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
        [view addSubview:self.playButton];
        [view addSubview:self.timeView];
        
        self.progressView = ({
            UIView *view = [[UIView alloc] init];
            [view.layer addSublayer:self.shapeLayer];
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
            [view addGestureRecognizer:tapGestureRecognizer];
            [view addGestureRecognizer:panGestureRecognizer];
            
            view;
        });
        [view addSubview:self.progressView];
        
        [_playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(view).offset(15);
            make.centerX.equalTo(view);
        }];
        [_timeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.playButton);
            make.right.equalTo(view).offset(-5);
        }];
        [_progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.playButton.mas_bottom).offset(10);
            make.left.equalTo(view);
            make.bottom.equalTo(view).offset(-15);
        }];
        
        view;
    });
    
    [self.view addSubview:self.playerView];
}

- (void)loadPictureView
{
    
}

- (void)loadDescriptionView
{
    
}

- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        CGFloat lineWidth = 2;
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, SCREEN_WIDTH, lineWidth)];
        _shapeLayer.path = path.CGPath;
        _shapeLayer.strokeEnd = 0;
        _shapeLayer.strokeColor = [UIColor orangeColor].CGColor;
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.lineWidth = lineWidth;
        _shapeLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, lineWidth);
    }
    return _shapeLayer;
}

- (UIImageView *)playButton
{
    if (!_playButton) {
        _playButton = [[UIImageView alloc] init];
    }
    return _playButton;
}

- (UITextView *)timeView
{
    if (!_timeView) {
        _timeView = [[UITextView alloc] init];
    }
    return _timeView;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [gesture locationInView:self.progressView];
        NSTimeInterval currentTime = point.x / SCREEN_WIDTH * self.viewModel.durationTime;
        self.viewModel.currentTime = currentTime;
        [self.viewModel play];
        self.isPlaying = @(YES);
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [gesture locationInView:self.progressView];
        
        [self.viewModel pause];
        self.isPlaying = @(NO);
        self.shapeLayer.strokeEnd = point.x / SCREEN_WIDTH;
        // 更新时间显示的UI
        self.remainTime = @(self.viewModel.durationTime * (1 - self.shapeLayer.strokeEnd));
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        self.viewModel.currentTime = self.shapeLayer.strokeEnd * self.viewModel.durationTime;
        
        [self.viewModel play];
        // 更新中间的播放暂停按钮
        self.isPlaying = @(YES);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
