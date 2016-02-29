//
//  RadioInfoModel.h
//  MoodRadioStation
//
//  Created by Minor on 16/2/27.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RACSignal;
@class RACSubject;

@interface RadioInfoModel : NSObject

@property (nonatomic, strong) RACSignal *getRadioInfo;
@property (nonatomic, strong) RACSignal *getRadio;
@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *radioURL;

@end
