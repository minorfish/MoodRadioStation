//
//  MRSCacheEntity.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/30.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSCacheEntity.h"

@implementation MRSCacheEntity

- (instancetype)initWithCache:(id)cache key:(NSString *)key path:(NSString *)path
{
    self = [super init];
    if (self) {
        _cache = cache;
        _key = key;
        _path = path;
        _date = [NSDate date];
    }
    return self;
}

@end
