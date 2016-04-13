//
//  MRSStreamPlayer.m
//  MoodRadioStation
//
//  Created by Minor on 16/4/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSStreamPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "MRSLoaderURLManager.h"
#import "MRSRadioRequestTask.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

extern const NSString* RPPlayCompletedNotification;

@interface MRSStreamPlayer ()<MRSRadioRequestTaskDelegate>

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVURLAsset *radioURLAsset;
@property (nonatomic, strong) AVAsset *radioAsset;
@property (nonatomic, strong) AVPlayerItem *currentPlayerItem;
@property (nonatomic, strong) MRSLoaderURLManager *resourceLoader;

@property (nonatomic, assign) BOOL isLocalRadio;
@property (nonatomic, assign) BOOL isPauseByUser;
@property (nonatomic, assign) BOOL isRequestFinished;

@property (nonatomic, assign) MRSStreamPlayerState  state;
@property (nonatomic, assign) CGFloat loadedProgress;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat currentTime;

@property (nonatomic, strong) id playbackTimeObserver;

@end

@implementation MRSStreamPlayer

+ (instancetype)sharedPlayer {
    static MRSStreamPlayer *player;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[self alloc] init];
    });
    
    return player;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isPauseByUser = YES;
        _loadedProgress = 0;
        _duration = 0;
        _currentTime  = 0;
        _state = MRSStreamPlayerState_Stopped;
        _stopWhenAppDidEnterBackground = YES;
        _isRequestFinished = NO;
    }
    return self;
}

- (void)dealloc
{
    [self releasePlayer];
}

//清空播放器监听属性
- (void)releasePlayer
{
    if (!self.currentPlayerItem) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"status"];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    self.currentPlayerItem = nil;
    
    [self.player removeTimeObserver:self.playbackTimeObserver];
    self.playbackTimeObserver = nil;
}

- (void)playWithURL:(NSURL *)radioURL
{
    [self.player pause];
    [self releasePlayer];
    
    self.isPauseByUser = NO;
    self.loadedProgress = 0;
    self.duration = 0;
    self.currentTime = 0;
    self.isRequestFinished = NO; // ??
    
    NSString *str = [radioURL absoluteString];
    if (![str hasPrefix:@"http"]) {
        self.radioAsset = [AVURLAsset URLAssetWithURL:radioURL options:nil];
        self.currentPlayerItem = [AVPlayerItem playerItemWithAsset:self.radioAsset];
        self.isLocalRadio = YES;
    } else {
        self.resourceLoader = [[MRSLoaderURLManager alloc] init];
        self.resourceLoader.delegate = self;
        NSURL *playURL = [MRSLoaderURLManager getSchemeRadioURL:radioURL];
        self.radioURLAsset = [AVURLAsset URLAssetWithURL:playURL options:nil];
        [self.radioURLAsset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
        self.currentPlayerItem = [AVPlayerItem playerItemWithAsset:self.radioURLAsset];
        _isLocalRadio = NO;
    }
    self.player = [AVPlayer playerWithPlayerItem:self.currentPlayerItem];
    
    [self.currentPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentPlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentPlayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayerItem];
    
    // 本地文件不需要缓冲
    if ([radioURL.scheme isEqualToString:@"file"]) {
        self.state = MRSStreamPlayerState_Playing;
    } else {
        self.state = MRSStreamPlayerState_Buffering;
    }
}

- (void)monitoringPlayback:(AVPlayerItem *)playItem
{
    self.duration = playItem.duration.value / playItem.duration.timescale;
    
    [self.player play];
    
    // 每隔0.5秒监控播放时间变化
    CMTime second = CMTimeMake(1, 1);
    @weakify(self);
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:second queue:NULL usingBlock:^(CMTime time) {
        @strongify(self);
        self.currentTime = playItem.currentTime.value/playItem.currentTime.timescale;
        self.duration = MAX(self.duration, self.currentTime);
    }];
}
- (void)calculateDownloadProgress:(AVPlayerItem *)playerItem
{
    // 获取缓冲区域
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    // 计算缓冲总进度
    NSTimeInterval timeInterval = startSeconds + durationSeconds;
    CMTime duration = playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    self.loadedProgress = timeInterval / totalDuration;
}

- (void)bufferingSomeSeconds
{
    static BOOL isBuffering = NO;
    // playbackBufferEmpty会反复进入，因此正在buffing中就可以忽略执行
    if (isBuffering) {
        return;
    }
    isBuffering = YES;
    
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
        // 执行了play还是没有缓存好，再缓存一次
        [self.player play];
        isBuffering = NO;
        if (!self.currentPlayerItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSeconds];
        }
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]){
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            [self monitoringPlayback:playerItem];
            
        } else if ([playerItem status] == AVPlayerStatusFailed || [playerItem status] == AVPlayerStatusUnknown) {
            [self stop];
        }
        // 监听播放下载进度
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        [self calculateDownloadProgress:playerItem];
        // 监听播放器中缓冲数据的状态
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        if (playerItem.isPlaybackBufferEmpty) {
            self.state = MRSStreamPlayerState_Buffering;
            [self bufferingSomeSeconds];
        }
    }
}

- (void)pause
{
    if (!self.currentPlayerItem) {
        return;
    }
    self.isPauseByUser = YES;
    self.state = MRSStreamPlayerState_Pause;
    [self.player pause];
}

- (void)resume
{
    if (!self.currentPlayerItem) {
        return;
    }
    
    self.isPauseByUser = NO;
    [self.player play];
}

- (void)stop
{
    self.isPauseByUser = YES;
    self.loadedProgress = 0;
    self.duration = 0;
    self.currentTime = 0;
    self.state = MRSStreamPlayerState_Stopped;
    [self.player pause];
    [self releasePlayer];
}

- (CGFloat)progress
{
    if (self.duration > 0) {
        return self.currentTime / self.duration;
    }
    return 0;
}

- (BOOL)isplaying
{
    return self.state == MRSStreamPlayerState_Playing ? YES: NO;
}

- (void)seekToTime:(CGFloat)seconds
{
    if (self.state == MRSStreamPlayerState_Stopped) {
        return;
    }
    
    seconds = MIN(MAX(0, seconds), self.duration);
    
    [self.player pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        self.isPauseByUser = NO;
        [self.player play];
        if (!self.currentPlayerItem.isPlaybackLikelyToKeepUp) {
            self.state = MRSStreamPlayerState_Buffering;
        }
    }];
}

#pragma mark - UIApplicationObserver
- (void)didEnterBackground
{
    if (self.stopWhenAppDidEnterBackground) {
        [self pause];
        self.state = MRSStreamPlayerState_Pause;
        self.isPauseByUser = NO;
    }
}

- (void)didEnterPlayground
{
    if (!self.isPauseByUser) {
        [self resume];
        self.state = MRSStreamPlayerState_Playing;
    }
}

- (void)playerItemDidPlayToEnd:(NSNotification *)notification
{
    [self stop];
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying)]) {
        [self.delegate audioPlayerDidFinishPlaying];
    }
}

- (void)didFinishLoadingWithTask:(MRSRadioRequestTask *)task
{
    self.isRequestFinished = task.isFinishLoad;
}

- (void)didFailLoadingWithTask:(MRSRadioRequestTask *)task WithError:(NSInteger )errorCode
{
   
}

@end
