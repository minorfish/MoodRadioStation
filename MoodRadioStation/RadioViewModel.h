//
//  RadioViewModel.h
//  MoodRadioStation
//
//  Created by Minor on 16/2/27.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
@class RACCommand;
@class RadioInfo;

@interface RadioViewModel : NSObject

@property (nonatomic, strong) RACCommand *getRadioInfoCommand;
@property (nonatomic, strong) RACCommand *getRadioCommand;

@property (nonatomic, assign) float progress;
@property (nonatomic, assign) NSTimeInterval durationTime;
@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, strong) RadioInfo *radioInfo;

- (void)play;
- (void)pause;
- (void)stop;
- (NSString *)formatTime:(int)num;

@end
