//
//  MRSStreamPlayer.h
//  MoodRadioStation
//
//  Created by Minor on 16/4/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MRSStreamPlayerState) {
    MRSStreamPlayerState_Buffering = 1,
    MRSStreamPlayerState_Playing   = 2,
    MRSStreamPlayerState_Stopped   = 3,
    MRSStreamPlayerState_Pause     = 4
};

@class MRSStreamPlayer;
@protocol MRSStreamPlayerDelegate <NSObject>

- (void)audioPlayerDidFinishPlaying;

@end

@interface MRSStreamPlayer : NSObject

@property (nonatomic, readonly) MRSStreamPlayerState state;
// 缓冲进度
@property (nonatomic, readonly) CGFloat loadedProgress;
// 视频总时间
@property (nonatomic, readonly) CGFloat duration;
// 当前播放时间
@property (nonatomic, readonly) CGFloat currentTime;
// 播放进度 0~1
@property (nonatomic, readonly) CGFloat progress;
// default is YES
@property (nonatomic, readonly) BOOL isRequestFinished;

@property (nonatomic, readonly) BOOL          stopWhenAppDidEnterBackground;
@property (nonatomic, weak) id<MRSStreamPlayerDelegate>delegate;

+ (instancetype)sharedPlayer;
- (void)playWithURL:(NSURL *)radioURL;
- (void)seekToTime:(CGFloat)seconds;

- (void)resume;
- (void)pause;
- (void)stop;

@end
