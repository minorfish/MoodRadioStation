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
#import "MRSImageAnimationLoadingView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIKitMacros.h"
#import "PlayerBackgroundView.h"
#import "MRSURLImageView.h"
#import <Masonry/Masonry.h>
#import "FMListModel.h"

const NSString* RPRefreshProgressViewNotification = @"com.minor.notification.refrshProgress";

@interface RadioPlayerViewController ()

@property (nonatomic, strong) RadioViewModel *viewModel;
@property (nonatomic, strong) NSNumber *radioID;
@property (nonatomic, strong) NSNumber *remainTime;
@property (nonatomic, strong) NSNumber *isPlaying;
@property (nonatomic, strong) NSNumber *progressX;
@property (nonatomic, strong) NSNumber *isLoading;
@property (nonatomic, strong) NSString *radioURL;

@property (nonatomic, strong) PlayerBackgroundView *playerBackgroundView;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UIImageView *playButton;
@property (nonatomic, strong) UIView *playerView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UILabel *timeView;
@property (nonatomic, strong) UIImageView *progressBtn;

@property (nonatomic, strong) MRSImageAnimationLoadingView *animationLoadingView;

@end

@implementation RadioPlayerViewController

- (instancetype)initWithRadioID:(NSNumber *)radioID RadioURL:(NSString *)URL
{
    self = [super init];
    if (self) {
        _radioID = radioID;
        _radioURL = URL;
        _viewModel = [[RadioViewModel alloc] init];
        _isPlaying = @(NO);
        _isLoading = @(YES);
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
    
    self.isLoading = @(YES);
    [self.viewModel.getRadioInfoCommand execute:self.radioID];
    [self.viewModel.getRadioCommand execute:self.radioURL];
    
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

    [RACObserve(self, isLoading) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if ([x boolValue]) {
            [self.animationLoadingView startAnimation];
        } else {
            [self.animationLoadingView stopAnimation];
        }
    }];
    
    [[RACObserve(self, progressX) ignore:nil] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        [_progressBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.progressView.mas_top);
            if ([x doubleValue] < self.progressBtn.frame.size.width/2) {
                make.left.equalTo(self.progressView);
            } else if ([x doubleValue] > SCREEN_WIDTH - self.progressBtn.frame.size.width/2){
                make.right.equalTo(self.progressView);
            } else {
                make.centerX.equalTo(x);
            }
        }];
    }];
    
    [[RACSignal combineLatest:@[
                                [RACObserve(self.viewModel, radioInfoLoading) distinctUntilChanged],
                                [RACObserve(self.viewModel, radioLoading) distinctUntilChanged]
                                ]] subscribeNext:^(id x) {
        @strongify(self);
        if (!self.viewModel.radioInfoLoading && !self.viewModel.radioLoading) {
            [self setupUI];
            self.isLoading = @(NO);
        }
    }];
    
    [[[RACObserve(self.viewModel, error) ignore:nil] distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        self.isLoading = @(NO);
    }];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [[tapGestureRecognizer rac_gestureSignal] subscribeNext:^(id x) {
        [self didTapButton];
    }];
    [self.playButton addGestureRecognizer:tapGestureRecognizer];
}

- (void)setupUI
{
    [self.view addSubview:self.playerBackgroundView];
    [self.view addSubview:self.playerView];
    [self loadDescriptionView];
}

- (UIView *)playerView
{
    if (!_playerView) {
        _playerView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.playerBackgroundView.frame.size.height, SCREEN_WIDTH, 100)];
            self.remainTime = @(self.viewModel.durationTime);
            
            [view addSubview:self.playButton];
            [view addSubview:self.timeView];
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
    }
    return _playerView;
}

- (void)loadDescriptionView
{
    UILabel *speakLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = Font(15);
        label.textColor = HEXCOLOR(0x666666);
        label.text = self.viewModel.radioInfo.speak;
        label;
    });
    
    UILabel *descLabel = ({
        UILabel *lable = [[UILabel alloc] init];
        lable.font = Font(13);
        lable.textColor = HEXCOLOR(0x999999);
        lable.text = self.viewModel.radioInfo.radiodDesc;
        lable.numberOfLines = 0;
        lable.textAlignment = NSTextAlignmentLeft;
        lable;
    });
    
    [self.view addSubview:speakLabel];
    [self.view addSubview:descLabel];
    
    [speakLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playerView.mas_bottom).offset(15);
        make.left.equalTo(self.view).offset(12);
    }];
    
    [descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(speakLabel.mas_bottom).offset(15);
        make.left.equalTo(speakLabel);
        make.right.lessThanOrEqualTo(self.view).offset(-12);
    }];
}

- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer = [self createCAShapeLayerWithColor:[UIColor orangeColor] LineWidth:0.5];
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

- (UIView *)progressView
{
    if (!_progressView) {
        _progressView = ({
            UIView *view = [[UIView alloc] initWithFrame:self.shapeLayer.bounds];
            view.backgroundColor = [UIColor blueColor];
            view.userInteractionEnabled = YES;
            
            [view.layer addSublayer:[self createCAShapeLayerWithColor:[UIColor grayColor] LineWidth:0.5]];
            [view.layer addSublayer:self.shapeLayer];
            
            _progressBtn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_btn"]];
            _progressBtn.userInteractionEnabled = YES;
            [view addSubview:_progressBtn];
            [_progressBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(view.mas_left);
                make.centerY.equalTo(view.mas_top);
            }];
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
            [[tapGestureRecognizer rac_gestureSignal] subscribeNext:^(UITapGestureRecognizer *x) {
                [self handleTapGesture:x];
            }];
            [_progressBtn addGestureRecognizer:tapGestureRecognizer];
            
            UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
            [[panGestureRecognizer rac_gestureSignal] subscribeNext:^(UIPanGestureRecognizer *x) {
                [self handlePanGesture:x];
            }];
            [_progressBtn addGestureRecognizer:panGestureRecognizer];
            
            view;
        });
    }
    return _progressView;
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

- (PlayerBackgroundView *)playerBackgroundView
{
    if (!_playerBackgroundView) {
        _playerBackgroundView = [[PlayerBackgroundView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 400) Title:self.viewModel.radioInfo.title];
        _playerBackgroundView.imageView.URLString = self.viewModel.radioInfo.coverURL;
    }
    return _playerBackgroundView;
}

- (MRSImageAnimationLoadingView *)animationLoadingView
{
    if (!_animationLoadingView) {
        _animationLoadingView = [MRSImageAnimationLoadingView loadingViewByView:self.view];
        [self.view addSubview:_animationLoadingView];
    }
    return _animationLoadingView;
}

#pragma mark GestureRecognizer
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [gesture locationInView:self.progressView];
        NSTimeInterval currentTime = point.x / SCREEN_WIDTH * self.viewModel.durationTime;
        self.viewModel.currentTime = currentTime;
        self.isPlaying = @(YES);
        self.progressX = @(point.x);
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
        self.progressX = @(point.x);
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

#pragma mark NotificationFunc
- (void)refreshProgressView
{
    self.shapeLayer.strokeEnd = self.viewModel.progress;
    self.remainTime = @((1 - self.viewModel.progress) * self.viewModel.durationTime);
    self.progressX = @(self.viewModel.progress * SCREEN_WIDTH);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
