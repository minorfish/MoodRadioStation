//
//  MRSIndexModel.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSModel.h"

@class RACSignal;

@interface MRSIndexModel : MRSModel

@property (nonatomic, strong) RACSignal *getIndexInfo;

@end
