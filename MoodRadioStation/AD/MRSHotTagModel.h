//
//  MRSHotTagModel.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/9.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSModel.h"
@class RACSignal;

@interface MRSHotTagModel : MRSModel

@property (nonatomic, strong) RACSignal *getHotTag;
@property (nonatomic, assign) NSInteger flag;
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, assign) NSInteger offset;

@end
