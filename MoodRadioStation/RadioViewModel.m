//
//  RadioViewModel.m
//  MoodRadioStation
//
//  Created by Minor on 16/2/27.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "RadioViewModel.h"
#import "RadioInfo.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RadioInfoModel.h"
#import <AVFoundation/AVFoundation.h>

extern const NSString* RPRefreshProgressViewNotification;

@interface RadioViewModel()<AVAudioPlayerDelegate>

@property (nonatomic, strong) RadioInfo *radioInfo;
@property (nonatomic, strong) RadioInfoModel *model;

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation RadioViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _model = [[RadioInfoModel alloc] init];
    }
    return self;
}

- (RACCommand *)getRadioInfoCommand
{
    @weakify(self);
    _getRadioInfoCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSNumber *ID) {
        @strongify(self);
        self.model.ID = ID;
        return [[[self.model getRadioInfo] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }] doNext:^(RadioInfo *value) {
            @strongify(self);
            if (!value)
                return;
            self.radioInfo = value;
        }];
    }];
    
    return _getRadioInfoCommand;
}

- (RACCommand *)getRadioCommand
{
    @weakify(self);
    _getRadioCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString *radioURL) {
        @strongify(self);
        self.model.radioURL = self.radioInfo.URL;
        return [[[self.model getRadio] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }] doNext:^(NSURL *filePath) {
            @strongify(self);
            NSError *error = nil;
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:&error];
            if (!error) {
                self.player.delegate = self;
                self.player.currentTime = 0;
                self.durationTime = self.player.duration;
                [self.player prepareToPlay];
            }
        }];
    }];
    return _getRadioCommand;
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

- (void)displayLinkAction:(CADisplayLink *)dis
{
    self.progress = self.player.currentTime / self.player.duration;
    // 通知根据时间进度更新UI
    [[NSNotificationCenter defaultCenter] postNotificationName:RPRefreshProgressViewNotification object:nil];
}

#pragma palyerAction
- (void)play
{
    if (!self.player.playing) {
        [self.player play];
        self.displayLink.paused = NO;
    }
}

- (void)pause
{
    if (self.player.playing) {
        [self.player pause];
        self.displayLink.paused = YES;
    }
}

- (void)stop
{
    if (self.player.playing) {
        [self pause];
    }
    
    self.player.currentTime = 0;
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (NSTimeInterval)currentTime
{
    if (self.player) {
        return self.player.currentTime;
    }
    return 0;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    if (self.player) {
        self.player.currentTime = currentTime;
    }
}

- (NSString *)formatTime:(int)num
{
    int sec = num % 60;
    int min = num / 60;
    if(num < 60){
        return [NSString stringWithFormat:@"00:%02d",num];
    }
    return [NSString stringWithFormat:@"%02d:%02d",min,sec];
}

#pragma AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stop];
    self.progress = 0;
    // 播放结束通知UI发生变化
    [[NSNotificationCenter defaultCenter] postNotificationName:RPRefreshProgressViewNotification object:nil];
}

@end
