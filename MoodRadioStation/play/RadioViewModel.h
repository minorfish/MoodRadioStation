//
//  RadioViewModel.h
//  MoodRadioStation
//
//  Created by Minor on 16/2/27.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "MRSStreamPlayer.h"

@class RACCommand;
@class RadioInfo;

@interface RadioViewModel : NSObject

@property (nonatomic, readonly) RACCommand *getRadioInfoCommand;
//@property (nonatomic, readonly) RACCommand *getRadioCommand;
@property (nonatomic, readonly) RACCommand *playRadioCommand;

@property (nonatomic, readonly) CGFloat progress;
@property (nonatomic, readonly) CGFloat loadedProgress;

@property (nonatomic, readonly) NSTimeInterval durationTime;
@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, strong) RadioInfo *radioInfo;

@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) RACSubject *radioInfoLoaded;

//@property (nonatomic, readonly) RACSubject *radioLoaded;
@property (nonatomic, readonly) MRSStreamPlayerState playerState ;

- (void)play;
- (void)pause;
- (void)stop;
- (BOOL)download;
- (NSString *)formatTime:(int)num;

@end
