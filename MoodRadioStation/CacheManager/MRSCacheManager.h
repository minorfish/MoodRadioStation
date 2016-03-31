//
//  MRSCacheManager.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/31.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRSCacheManagerProtocol.h"
@class MRSMemoryCacheManager;
@class MRSPersistentCacheManager;

typedef NS_ENUM(NSInteger, MRSCacheManagerStrategy) {
    MRSCacheManagerStrategy_writeBack, // 从内存中写回硬盘
    MRSCacheManagerStrategy_writeThrough, // 写入内存的时候同时写进硬盘
};

@interface MRSCacheManager : NSObject<MRSCacheManagerProtocol> {
    dispatch_queue_t _queue;
    BOOL _inBackground;
}

@property (nonatomic, strong) MRSMemoryCacheManager *memoryCacheManager;
@property (nonatomic, strong) MRSPersistentCacheManager *persistentCacheManager;

@property (nonatomic, assign) MRSCacheManagerStrategy strategy;

+ (MRSCacheManager *)defaultURLCacheManager;
+ (MRSCacheManager *)defaultObjectCacheManager;

@end
