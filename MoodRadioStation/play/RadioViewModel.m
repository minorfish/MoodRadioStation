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
#import "MRSLoaderURLManager.h"
#import "MRSStreamPlayer.h"

extern const NSString* RPRefreshProgressViewNotification;
extern const NSString* RPPlayCompletedNotification;

@interface RadioViewModel()<MRSStreamPlayerDelegate>

@property (nonatomic, strong) RadioInfoModel *model;
@property (nonatomic, strong) MRSRadioDao *dao;

@property (nonatomic, strong) RACCommand *getRadioInfoCommand;
//@property (nonatomic, strong) RACCommand *getRadioCommand;
@property (nonatomic, strong) RACCommand *playRadioCommand;

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat loadedProgress;

@property (nonatomic, assign) NSTimeInterval durationTime;
@property (nonatomic, strong) NSData *radioData;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) RACSubject *radioInfoLoaded;

@property (nonatomic, strong) MRSStreamPlayer *player;

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

- (RACCommand *)playRadioCommand
{
    @weakify(self);
    
    _playRadioCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString *radioURL) {
        @strongify(self);
        if (_radioInfo.filePath) {
            NSURLComponents *realURLComponents = [[NSURLComponents alloc] initWithString:_radioInfo.filePath];
            realURLComponents.scheme = @"file";
            [self.player playWithURL:[realURLComponents URL]];
        } else {
            self.model.radioURL = radioURL;
            [[self.model getRadio] subscribeNext:^(id x) {}];
            self.model.redirectBlock = ^(NSURL *redirectURL) {
            @strongify(self);
                [self.player playWithURL:redirectURL];
            };
        }
        return [RACSignal empty];
    }];
    return _playRadioCommand;
}

//- (RACCommand *)getRadioCommand
//{
//    @weakify(self);
//    _getRadioCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString *radioURL) {
//        @strongify(self);
//        NSString *url = [radioURL copy];
//        if (self.preRadioRequest) {
//            [self.preRadioRequest dispose];
//        }
//        [self.radioLoaded sendNext:@(NO)];
//        NSData *radioData = [self.dao getRadioDataForRadioURL:url];
//        if (radioData) {
//            return [RACSignal empty];
//        }
//        self.error = nil;
//        self.model.radioURL = radioURL;
//        self.preRadioRequest = [[[self.model getRadio] catch:^RACSignal *(NSError *error) {
//            self.error = error;
//            return [RACSignal empty];
//        }] subscribeNext:^(NSURL *filePath) {
//            @strongify(self);
//            NSError *error = nil;
//            NSData *songFile = [[NSData alloc] initWithContentsOfURL:filePath options:NSDataReadingMappedIfSafe error:&error];
//            if (error) {
//                _radioData = nil;
//                return;
//            }
//             _radioData = songFile;
//            [self.dao saveRadioData:songFile ForRadioURL:url];
//        }];
//        return [RACSignal empty];
//    }];
//    return _getRadioCommand;
//}

- (MRSStreamPlayer *)player
{
    if (!_player) {
        _player = [MRSStreamPlayer sharedPlayer];
        _player.delegate = self;
    }
    return _player;
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
    if (!self.player.isRequestFinished) {
        return NO;
    }
    
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [document stringByAppendingPathComponent:@"tmp.mp3"];
    
    NSString *movePath = [document stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%@.mp3", @(_radioInfo.radioID)]];
    BOOL isSuccess = [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:movePath error:nil];
    if (!isSuccess) {
        return NO;
    }
    // get from cache
    _radioInfo.filePath = movePath;
    id cache = [self.dao getCacheForRadioID:_radioInfo.radioID];
    if (!cache || ![((RadioInfo *)cache).filePath isEqualToString:movePath]) {
        [self.dao saveCache:_radioInfo ForID:_radioInfo.radioID];
    }
    
    NSData *fileData = [NSData dataWithContentsOfFile:movePath];
    [self.downloadHelper saveRadioSize:[self translateFileSizeByte:fileData.length] forRadioID:_radioInfo.radioID];
    return YES;
}

- (void)displayLinkAction:(CADisplayLink *)dis
{
    if (self.player.duration <= 0) {
        return;
    }
    self.progress = self.player.currentTime / self.player.duration;
    self.loadedProgress = self.player.loadedProgress;
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
    [self.player resume];
    self.displayLink.paused = NO;
}

- (void)pause
{
    [self.player pause];
    self.displayLink.paused = YES;
}

- (void)stop
{
    [self.player stop];
    self.player = nil;
}

- (NSTimeInterval)currentTime
{
    if (self.player) {
        return self.player.currentTime;
    }
    return 0;
}

- (NSTimeInterval)durationTime
{
    if (self.player) {
        return self.player.duration;
    }
    return 0;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    if (self.player) {
        [self.player seekToTime:currentTime];
    }
}

- (MRSStreamPlayerState)playerState
{
    return self.player.state;
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

#pragma MRSStreamPlayerDelegate
- (void)audioPlayerDidFinishPlaying
{
    [self stop];
    // 播放结束通知UI发生变化
    [[NSNotificationCenter defaultCenter] postNotificationName:RPPlayCompletedNotification object:nil];
}

@end
