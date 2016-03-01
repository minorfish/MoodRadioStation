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
@property (nonatomic, strong) UILabel *timeView;

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
            [self.viewModel play];
            [self.playButton setImage:[UIImage imageNamed:@"pause"]];
        } else {
            [self.viewModel pause];
            [self.playButton setImage:[UIImage imageNamed:@"play"]];
        }
    }];
    
    [[RACObserve(self, remainTime) ignore:nil]
     subscribeNext:^(NSNumber *remainTime) {
        @strongify(self);
        self.timeView.text = [NSString stringWithFormat:@"-%@",[self.viewModel formatTime:[remainTime integerValue]]];
    }];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [[tapGestureRecognizer rac_gestureSignal] subscribeNext:^(id x) {
        [self didTapButton];
    }];
    [self.playButton addGestureRecognizer:tapGestureRecognizer];
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
    [self bind];
}

- (void)loadPlayerView
{
    self.playerView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        
        [view addSubview:self.playButton];
        
        self.remainTime = @(self.viewModel.durationTime);
        [view addSubview:self.timeView];
        
        self.progressView = ({
            UIView *view = [[UIView alloc] initWithFrame:self.shapeLayer.bounds];
            view.userInteractionEnabled = YES;
            [view.layer addSublayer:[self createCAShapeLayerWithColor:[UIColor grayColor] LineWidth:0.5]];
            [view.layer addSublayer:self.shapeLayer];
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
            [[tapGestureRecognizer rac_gestureSignal] subscribeNext:^(UITapGestureRecognizer *x) {
                [self handleTapGesture:x];
            }];
            [view addGestureRecognizer:tapGestureRecognizer];
            
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
            [[panGestureRecognizer rac_gestureSignal] subscribeNext:^(UIPanGestureRecognizer *x) {
                [self handlePanGesture:x];
            }];
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
        _shapeLayer = [self createCAShapeLayerWithColor:[UIColor orangeColor] LineWidth:1];
        _shapeLayer.strokeEnd = 0;
    }
    return _shapeLayer;
}

- (UIImageView *)playButton
{
    if (!_playButton) {
        _playButton = [[UIImageView alloc] init];
        _playButton.userInteractionEnabled = YES;
    }
    return _playButton;
}

- (UILabel *)timeView
{
    if (!_timeView) {
        _timeView = [[UILabel alloc] init];
        _timeView.font = Font(12);
        _timeView.textColor = HEXCOLOR(0x999999);
    }
    return _timeView;
}

- (CAShapeLayer *)createCAShapeLayerWithColor:(UIColor *)color LineWidth:(CGFloat)lineWidth
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH, 0)];
    path.lineWidth = lineWidth;
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, lineWidth);
    return shapeLayer;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [gesture locationInView:self.progressView];
        NSTimeInterval currentTime = point.x / SCREEN_WIDTH * self.viewModel.durationTime;
        self.viewModel.currentTime = currentTime;
        self.isPlaying = @(YES);
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [gesture locationInView:self.progressView];
        
        self.isPlaying = @(NO);
        self.shapeLayer.strokeEnd = point.x / SCREEN_WIDTH;
        // 更新时间显示的UI
        self.remainTime = @(self.viewModel.durationTime * (1 - self.shapeLayer.strokeEnd));
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        self.viewModel.currentTime = self.shapeLayer.strokeEnd * self.viewModel.durationTime;
        
        // 更新中间的播放暂停按钮
        self.isPlaying = @(YES);
    }
}

- (void)didTapButton
{
    self.isPlaying = @(![self.isPlaying boolValue]);
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
