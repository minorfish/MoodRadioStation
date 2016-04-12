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
#import "MRSRadioDao.h"
#import "MRSDownloadHelper.h"
#import "MRSCacheEntity.h"

extern const NSString* RPRefreshProgressViewNotification;
extern const NSString* RPPlayCompletedNotification;

@interface RadioViewModel()<AVAudioPlayerDelegate>

@property (nonatomic, strong) RadioInfoModel *model;
@property (nonatomic, strong) MRSRadioDao *dao;

@property (nonatomic, strong) RACCommand *getRadioInfoCommand;
@property (nonatomic, strong) RACCommand *getRadioCommand;

@property (nonatomic, assign) float progress;
@property (nonatomic, assign) NSTimeInterval durationTime;
@property (nonatomic, strong) NSData *radioData;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) RACSubject *radioInfoLoaded;
@property (nonatomic, strong) RACSubject *radioLoaded;

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) RACDisposable *preRadioInfoRequest;
@property (nonatomic, strong) RACDisposable *preRadioRequest;
@property (nonatomic, strong) MRSDownloadHelper *downloadHelper;

@end

@implementation RadioViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _model = [[RadioInfoModel alloc] init];
        _dao = [[MRSRadioDao alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self stop];
    [self.displayLink invalidate];
    self.displayLink = nil;
    [self.radioInfoLoaded sendCompleted];
    [self.radioLoaded sendCompleted];
}

- (RACCommand *)getRadioInfoCommand
{
    @weakify(self);
    _getRadioInfoCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSNumber *ID) {
        @strongify(self);
        if (self.preRadioInfoRequest) {
            [self.preRadioInfoRequest dispose];
        }
        [self.radioInfoLoaded sendNext:@(NO)];
        
        // get from cache
        id cache = [self.dao getCacheForRadioID:[ID longLongValue]];
        if (cache) {
            self.radioInfo = cache;
            [self.radioInfoLoaded sendNext:@(YES)];
            return [RACSignal empty];
        }
        self.model.ID = ID;
        self.error = nil;
        
        self.preRadioInfoRequest = [[[self.model getRadioInfo] catch:^RACSignal *(NSError *error) {
            self.error = error;
            return [RACSignal empty];
        }] subscribeNext:^(RadioInfo *value) {
            @strongify(self);
            if (!value)
                return;
            self.radioInfo = value;
            [self.dao saveCache:value ForID:[ID longLongValue]];
            [self.radioInfoLoaded sendNext:@(YES)];
        }];
        return [RACSignal empty];
    }];
    
    return _getRadioInfoCommand;
}

- (RACCommand *)getRadioCommand
{
    @weakify(self);
    _getRadioCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString *radioURL) {
        @strongify(self);
        NSString *url = [radioURL copy];
        if (self.preRadioRequest) {
            [self.preRadioRequest dispose];
        }
        [self.radioLoaded sendNext:@(NO)];
        NSData *radioData = [self.dao getRadioDataForRadioURL:url];
        if (radioData) {
            [self playGetReady:radioData];
            return [RACSignal empty];
        }
        self.error = nil;
        self.model.radioURL = radioURL;
        self.preRadioRequest = [[[self.model getRadio] catch:^RACSignal *(NSError *error) {
            self.error = error;
            return [RACSignal empty];
        }] subscribeNext:^(NSURL *filePath) {
            @strongify(self);
            NSError *error = nil;
            NSData *songFile = [[NSData alloc] initWithContentsOfURL:filePath options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                _radioData = nil;
                return;
            }
             _radioData = songFile;
            [self.dao saveRadioData:songFile ForRadioURL:url];
            NSLog(@"radioCommand\n");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self playGetReady:songFile];
            });
        }];
        return [RACSignal empty];
    }];
    return _getRadioCommand;
}

- (void)playGetReady:(NSData *)data {
    NSError *error = nil;
    self.player = [[AVAudioPlayer alloc] initWithData:data error:&error];
    if (!error) {
        self.player.delegate = self;
        self.player.currentTime = 0;
        self.durationTime = self.player.duration;
        [self.player prepareToPlay];
        [self.radioLoaded sendNext:@(YES)];
    }
    self.error = error;
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

- (RACSubject *)radioLoaded
{
    if (!_radioLoaded) {
        _radioLoaded = [RACSubject subject];
    }
    return _radioLoaded;
}

- (RACSubject *)radioInfoLoaded
{
    if (!_radioInfoLoaded) {
        _radioInfoLoaded = [RACSubject subject];
    }
    return _radioInfoLoaded;
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

- (BOOL)download
{
    MRSCacheEntity *entity = [self.dao getCacheForRadioID:_radioInfo.radioID];
    if (!entity) {
        [self.dao saveCache:_radioInfo ForID:_radioInfo.radioID];
    }
    
    NSData *data = [self.dao getRadioDataForRadioURL:_radioInfo.URL];
    if (!data) {
        return NO;
    }
    [self.dao savePersistentRadioData:data ForRadioURL:_radioInfo.URL];
    [self.downloadHelper saveRadioSize:[self translateFileSizeByte:data.length] forRadioID:_radioInfo.radioID];
    return YES;
}

- (void)displayLinkAction:(CADisplayLink *)dis
{
    if (self.player.duration <= 0) {
        return;
    }
    self.progress = self.player.currentTime / self.player.duration;
    // 通知根据时间进度更新UI
    [[NSNotificationCenter defaultCenter] postNotificationName:RPRefreshProgressViewNotification object:nil];
}

- (MRSDownloadHelper *)downloadHelper
{
    if (!_downloadHelper) {
        _downloadHelper = [MRSDownloadHelper shareDownloadHelper];
    }
    return _downloadHelper;
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
    [self.player stop];
    self.player.currentTime = 0;
    self.player = nil;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:RPPlayCompletedNotification object:nil];
}


@end
