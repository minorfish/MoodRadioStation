//
//  MRSRadioDao.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/31.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSRadioDao.h"
#import "MRSCacheManager.h"
#import "MRSCacheEntity.h"
#import "RadioInfo.h"

static NSString* MRSRadioKey = @"MRSRadio";

@interface MRSRadioDao()

@property (nonatomic, strong) MRSCacheManager *URLCacheManager;
@property (nonatomic, strong) MRSCacheManager *objectCahceManager;

@end

@implementation MRSRadioDao

- (id)getCacheForRadioID:(long long)ID
{
    NSError *error = nil;
    MRSCacheEntity *entity = [self.objectCahceManager getCacheForKey:[NSString stringWithFormat:@"%@_%@", MRSRadioKey, @(ID)] error:&error];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *now  = [dateFormatter stringFromDate:[NSDate date]];
    NSString *entityDate = [dateFormatter stringFromDate:entity.date];
    if (error || [now compare:entityDate] == NSOrderedDescending) {
        return nil;
    }
    
    return entity.cache;
}

- (void)saveCache:(RadioInfo *)cache ForID:(long long)ID
{
    NSError *error = nil;
    NSString *key = [NSString stringWithFormat:@"%@_%@", MRSRadioKey, @(ID)];
    MRSCacheEntity *entity = [self.objectCahceManager getCacheForKey:key error:&error];
    if ([cache isEqual:entity.cache]) {
        return;
    }
    [self.objectCahceManager setCache:cache forKey:key error:&error];
}

- (NSString *)getFilePathForRadioURL:(NSString *)radioURL
{
    NSError *error = nil;
    MRSCacheEntity *entity = [self.URLCacheManager getCacheForKey:[NSString stringWithFormat:@"%@_%@", MRSRadioKey, radioURL] error:&error];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *now  = [dateFormatter stringFromDate:[NSDate date]];
    NSString *entityDate = [dateFormatter stringFromDate:entity.date];
    if (error || [now compare:entityDate] == NSOrderedDescending) {
        return nil;
    }
    
    return entity.cache;
}

- (void)saveFilePath:(NSString *)filePath ForRadioURL:(NSString *)radioURL
{
    NSError *error = nil;
    NSString *key = [NSString stringWithFormat:@"%@_%@", MRSRadioKey, radioURL];
    MRSCacheEntity *entity = [self.URLCacheManager getCacheForKey:key error:&error];
    if ([filePath isEqualToString:entity.cache]) {
        return;
    }
    [self.URLCacheManager setCache:filePath forKey:key error:&error];
}

- (MRSCacheManager *)URLCacheManager
{
    if (!_URLCacheManager) {
        _URLCacheManager = [MRSCacheManager defaultURLCacheManager];
    }
    return _URLCacheManager;
}

- (MRSCacheManager *)objectCahceManager
{
    if (!_objectCahceManager) {
        _objectCahceManager = [MRSCacheManager defaultObjectCacheManager];
        [_objectCahceManager setStrategy:MRSCacheManagerStrategy_writeThrough];
    }
    return _objectCahceManager;
}

@end
