//
//  MRSHotTagViewModel.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/9.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACCommand;
@class RACSubject;

@interface MRSHotTagViewModel : NSObject

@property (nonatomic, strong) RACCommand *getHotTagCommand;
@property (nonatomic, assign) NSInteger flag;
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, assign) NSInteger offset;

@property (nonatomic, readonly) RACSubject *dataLoaded;

@end
