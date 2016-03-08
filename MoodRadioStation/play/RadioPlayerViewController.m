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
#import "MRSNoContentView.h"
#import "MRSSpeakerDescView.h"
#import "MRSSpeakerInfo.h"
#import "MRSCircleImageView.h"
#import "FMInfo.h"
#import "FMListViewModel.h"

const NSString* RPRefreshProgressViewNotification = @"com.minor.notification.refrshProgress";

@interface RadioPlayerViewController ()

@property (nonatomic, strong) RadioViewModel *viewModel;

@property (nonatomic, strong) NSNumber *remainTime;
@property (nonatomic, strong) NSNumber *progressX;
@property (nonatomic, strong) NSNumber *isLoading;

@property (nonatomic, strong) PlayerBackgroundView *playerBackgroundView;

@property (nonatomic, strong) UIImageView *playOrPauseButton;
@property (nonatomic, strong) UIImageView *nextButton;
@property (nonatomic, strong) UIImageView *preButton;
@property (nonatomic, strong) UIView *playerView;

@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UILabel *timeView;
@property (nonatomic, strong) UIImageView *progressBtn;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) MRSSpeakerDescView *speakerDescView;

@property (nonatomic, strong) MRSImageAnimationLoadingView *animationLoadingView;

@property (nonatomic, strong) FMListViewModel *fmListViewModel;

@end

@implementation RadioPlayerViewController

- (instancetype)initWithKeyString:(NSString *)keyString KeyVale:(NSString *)keyValue Rows:(NSNumber *)rows
{
    self = [super init];
    if (self) {
        _viewModel = [[RadioViewModel alloc] init];
        _fmListViewModel = [[FMListViewModel alloc] initWithRows:rows KeyString:keyString KeyValue:keyValue];
        _isPlaying = @(NO);
        _isLoading = @(YES);
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    self.navigationController.navigationBar.hidden = NO;
}

- (void)dealloc
{
    [self.viewModel stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self bind];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:RPRefreshProgressViewNotification object:nil] deliverOnMainThread] subscribeNext:^(NSNotification *x) {
        if ([x isKindOfClass:[NSNotification class]]) {
            [self refreshProgressView];
        }
    }];
    
    [self refresh];
}

- (void)refresh
{
    FMInfo *reqestFMInfo = (FMInfo *)[self.requestFMInfoArray objectAtIndex:[self.currentFMIndex unsignedIntegerValue]];
    
    if (!reqestFMInfo)
        return;
 
    [self.viewModel stop];
    self.isLoading = @(YES);
    [self.viewModel.getRadioInfoCommand execute:@(reqestFMInfo.ID)];
    [self.viewModel.getRadioCommand execute:reqestFMInfo.mediaURL];
}

- (void)bind
{
    @weakify(self);
    [RACObserve(self, isPlaying) subscribeNext:^(NSNumber *isPlaying)  {
        @strongify(self);
        if ([isPlaying boolValue]) {
            [self.viewModel play];
            [self.playOrPauseButton setImage:[UIImage imageNamed:@"pause"]];
        } else {
            [self.viewModel pause];
            [self.playOrPauseButton setImage:[UIImage imageNamed:@"play"]];
        }
    }];
    
    [[RACObserve(self, remainTime) ignore:nil]
     subscribeNext:^(NSNumber *remainTime) {
        @strongify(self);
        self.timeView.text = [NSString stringWithFormat:@"-%@",[self.viewModel formatTime:[remainTime integerValue]]];
    }];

    [[RACObserve(self, isLoading) distinctUntilChanged] subscribeNext:^(NSNumber *x) {
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
                                self.viewModel.radioInfoLoaded ,
                                self.viewModel.radioLoaded
                                ]] subscribeNext:^(RACTuple *array) {
        @strongify(self);
        if (!self.viewModel.error && [array objectAtIndex:0] && [array objectAtIndex:1]) {
            [self refreshViewWithData];
            self.isLoading = @(NO);
            self.isPlaying = @(YES);
        }
    }];
    
    [[[RACObserve(self.viewModel, error) ignore:nil] distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        self.isLoading = @(NO);
    }];
    
    [[[RACObserve(self, currentFMIndex) ignore:nil] distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self refresh];
    }];
    
    [self.fmListViewModel.dataLoadedSignal subscribeNext:^(NSNumber *x) {
        @strongify(self);
        if (![x boolValue])
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.requestFMInfoArray addObjectsFromArray:self.fmListViewModel.infoArray];
            self.currentFMIndex = @([self.currentFMIndex longLongValue] + 1);
        });
    }];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [[tapGestureRecognizer rac_gestureSignal] subscribeNext:^(id x) {
        [self didTapButton];
    }];
    [self.playOrPauseButton addGestureRecognizer:tapGestureRecognizer];
}

- (void)setupUI
{
    [self.view addSubview:self.playerBackgroundView];
    [self.view addSubview:self.playerView];
    [self.view addSubview:self.speakerDescView];
}

- (void)refreshViewWithData
{
    self.progressBtn.hidden = NO;
    self.remainTime = @(self.viewModel.durationTime);
    self.playerBackgroundView.titleLabel.text = self.viewModel.radioInfo.title;
    self.playerBackgroundView.imageView.URLString = self.viewModel.radioInfo.coverURL;
    
    MRSSpeakerInfo *speaker = self.viewModel.radioInfo.speakerInfo;
    self.speakerDescView.circleImageView.URLString = speaker.cover;
    self.speakerDescView.speakerNameLabel.text = speaker.name;
    self.speakerDescView.fmNumLabel.text = [NSString stringWithFormat:@"%@个节目", @(speaker.fmNum)];
}

- (UIView *)playerView
{
    if (!_playerView) {
        _playerView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.playerBackgroundView.frame.size.height, SCREEN_WIDTH, 100)];
            
            [view addSubview:self.playOrPauseButton];
            [view addSubview:self.timeView];
            [view addSubview:self.progressView];
            [view addSubview:self.nextButton];
            [view addSubview:self.preButton];
            
            [_playOrPauseButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(view).offset(15);
                make.centerX.equalTo(view);
            }];
            [_preButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.playOrPauseButton);
                make.right.equalTo(self.playOrPauseButton.mas_left).offset(-40);
            }];
            [_nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.playOrPauseButton);
                make.left.equalTo(self.playOrPauseButton.mas_right).offset(40);
            }];
            [_timeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.playOrPauseButton);
                make.right.equalTo(view).offset(-5);
            }];
            [_progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.playOrPauseButton.mas_bottom).offset(10);
                make.left.equalTo(view);
                make.bottom.equalTo(view).offset(-15);
            }];
        
            view;
        });
    }
    return _playerView;
}

- (CAShapeLayer *)shapeLayer
{
    if (!_shapeLayer) {
        _shapeLayer = [self createCAShapeLayerWithColor:[UIColor orangeColor] LineWidth:0.5];
        _shapeLayer.strokeEnd = 0;
    }
    return _shapeLayer;
}

- (UIImageView *)playOrPauseButton
{
    if (!_playOrPauseButton) {
        _playOrPauseButton = [[UIImageView alloc] init];
        _playOrPauseButton.userInteractionEnabled = YES;
    }
    return _playOrPauseButton;
}

- (UIImageView *)nextButton
{
    if (!_nextButton) {
        _nextButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next"]];
        _nextButton.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
        [tapGes.rac_gestureSignal subscribeNext:^(id x) {
            if ([self.currentFMIndex longLongValue] + 1 < [self.requestFMInfoArray count]) {
                self.currentFMIndex = @([self.currentFMIndex longLongValue] + 1);
            } else {
                [self.fmListViewModel.refreshListCommand
                   execute:@(self.requestFMInfoArray.count)];
            }
        }];
        [_nextButton addGestureRecognizer:tapGes];
    }
    return _nextButton;
}

- (UIImageView *)preButton
{
    if (!_preButton) {
        _preButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pre"]];
        _preButton.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
        [tapGes.rac_gestureSignal subscribeNext:^(id x) {
            if ([self.currentFMIndex longLongValue] - 1 >= 0) {
                self.currentFMIndex = @([self.currentFMIndex longLongValue] - 1);
            }
        }];
        [_preButton addGestureRecognizer:tapGes];
    }
    return _preButton;
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
            _progressBtn.hidden = YES;
            [_progressBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(view.mas_left);
                make.centerY.equalTo(view.mas_top);
            }];
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
            [[tapGestureRecognizer rac_gestureSignal] subscribeNext:^(UITapGestureRecognizer *x) {
                [self handleTapGesture:x];
            }];
            [view addGestureRecognizer:tapGestureRecognizer];
            
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
        _playerBackgroundView = [[PlayerBackgroundView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 400)];
        _playerBackgroundView.imageView.image = _playerBackgroundView.imageView.defaultImage;
        @weakify(self);
        _playerBackgroundView.block = ^{
            @strongify(self);
            [self navBack];
        };
    }
    return _playerBackgroundView;
}

- (MRSSpeakerDescView *)speakerDescView
{
    if (!_speakerDescView) {
        _speakerDescView = [[MRSSpeakerDescView alloc] initWithFrame:CGRectMake(0, self.playerView.frame.origin.y + self.playerView.frame.size.height + 15, SCREEN_WIDTH, 84)];
        _speakerDescView.circleImageView.image = _speakerDescView.circleImageView.defaultImage;
        _speakerDescView.backgroundColor = [UIColor whiteColor];
    }
    return _speakerDescView;
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

- (void)navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark NotificationFunc
- (void)refreshProgressView
{
    self.shapeLayer.strokeEnd = self.viewModel.progress;
    self.remainTime = @((1 - self.viewModel.progress) * self.viewModel.durationTime);
    self.progressX = @(self.viewModel.progress * SCREEN_WIDTH);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
