//
//  MRSMemoryCacheManager.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/30.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRSCacheManagerProtocol.h"

@interface MRSMemoryCacheManager : NSObject<MRSCacheManagerProtocol>

@property (nonatomic, strong) NSMutableDictionary *memoryCache;
@property (nonatomic, strong) NSMutableArray *cacheKeys;
@property (nonatomic, strong) NSMutableArray *recentlyAccessedKeys;

@end
