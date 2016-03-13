//
//  MRSIndexViewModel.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACCommand;
@class MRSIndexInfo;
@class RACSubject;

@interface MRSIndexViewModel : NSObject

@property (nonatomic, strong) RACCommand *getIndexCommand;
@property (nonatomic, strong) MRSIndexInfo *indexInfo;

@property (nonatomic, strong) RACSubject *dataLoaded;

@end
