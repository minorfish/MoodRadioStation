//
//  RadioInfoModel.h
//  MoodRadioStation
//
//  Created by Minor on 16/2/27.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSModel.h"
@class RACSignal;
@class RACSubject;

@interface RadioInfoModel : MRSModel

@property (nonatomic, strong) RACSignal *getRadioInfo;
@property (nonatomic, strong) RACSignal *getRadio;
@property (nonatomic, strong) RACSignal *getRedirectRadioURL;

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *radioURL;
@property (nonatomic, copy) void(^redirectBlock)(NSURL *redirectURL);

@end
