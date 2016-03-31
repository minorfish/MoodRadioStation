//
//  MRSMemoryCacheManager.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/30.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSMemoryCacheManager.h"
#import "MRSCacheEntity.h"

#define kMemoryCacheLimit 1024

@implementation MRSMemoryCacheManager {
    int _limit;
    unsigned long long _cacheSize;
}

@synthesize directory = _directory;

- (instancetype)init
{
    self = [super init];        
    if (self) {
        _memoryCache = [[NSMutableDictionary alloc] initWithCapacity:kMemoryCacheLimit];
        _cacheKeys = [[NSMutableArray alloc] initWithCapacity:kMemoryCacheLimit];
        _recentlyAccessedKeys = [[NSMutableArray alloc] initWithCapacity:kMemoryCacheLimit];
        _limit = kMemoryCacheLimit;
    }
    return self;
}

- (void)getEntityForKey:(NSString *)key finished:(MRSCacheManagerCallBack)finished
{
    [self getEntityForKey:key finished:^(MRSCacheEntity *entity, NSError *error) {
        if (error) {
            finished(nil, error);
        } else {
            finished(entity, nil);
        }
    }];
}

- (unsigned long long)cacheSizeAtPath:(NSString *)path
{
    unsigned long long cacheSize = 0;
    if (path.length) {
         path = [NSString stringWithFormat:@"%@:%@", _directory ,path];
        for (NSString *key in _cacheKeys) {
            if ([key compare:path] == NSOrderedDescending) {
                break;
            }
            if ([key hasPrefix:path]) {
                cacheSize += ((MRSCacheEntity *)_memoryCache    [key]).size;
            }
        }
    } else {
        cacheSize = [self cacheSize];
    }
    return cacheSize;
}

- (void)cleanCacheAtPath:(NSString *)path
{
    unsigned long long deleteCacheSize = 0;
    NSMutableArray *array = [NSMutableArray array];
    NSArray *deleteKeysArray = nil;
    
    if (path.length) {
        path = [NSString stringWithFormat:@"%@:%@", _directory, path];
        for (NSString *key in _cacheKeys) {
            if ([key compare:path] == NSOrderedDescending) {
                break;
            }
            if ([key hasPrefix:path]) {
                deleteCacheSize += ((MRSCacheEntity *)_memoryCache[key]).size;
                [array addObject:key];
            }
        }
        deleteKeysArray = array;
    } else {
        deleteCacheSize = _cacheSize;
        deleteKeysArray = _cacheKeys;
    }
    
    _cacheSize -= deleteCacheSize;
    
    [_memoryCache removeObjectsForKeys:deleteKeysArray];
    [_recentlyAccessedKeys removeObjectsInArray:deleteKeysArray];
    [_cacheKeys removeObjectsInArray:deleteKeysArray];
}

- (MRSCacheEntity *)getCacheForKey:(NSString *)key error:(NSError **)error
{
    return [self getCacheForKey:key atPath:nil error:error];
}

- (MRSCacheEntity *)getCacheForKey:(NSString *)key atPath:(NSString *)path error:(NSError *__autoreleasing *)error
{
    path = path ? path : @"";
    key = [NSString stringWithFormat:@"%@:%@@%@", _directory, path, key];
    MRSCacheEntity *entity = _memoryCache[key];
    if ([_recentlyAccessedKeys containsObject:key]) {
        [_recentlyAccessedKeys removeObject:key];
    }
    
    [_recentlyAccessedKeys insertObject:key atIndex:0];
    return entity;
}

- (MRSCacheEntity *)setCache:(id)cache forKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    return [self setCache:cache forKey:key atPath:nil error:error];
}

- (MRSCacheEntity *)setCache:(id)cache forKey:(NSString *)key atPath:(NSString *)path error:(NSError *__autoreleasing *)error
{
    NSError *innrError = nil;
    MRSCacheEntity *entity = [[MRSCacheEntity alloc] initWithCache:cache key:key path:path];
    MRSCacheEntity *staleEntity = [self setEntity:entity error:&innrError];
    if (innrError) {
        *error = innrError;
    }
    return staleEntity;
}

- (MRSCacheEntity *)setEntity:(MRSCacheEntity *)entity error:(NSError **)error
{
    entity.dirty = YES;
    NSString *key = [NSString stringWithFormat:@"%@:%@@%@", _directory, entity.path, entity.key];
    NSString *longestUnAccessKey = nil;
    MRSCacheEntity *longestUnAccessObject = nil;
    
    unsigned long long oldEntitySize = 0;
    if (!entity.cache) {
        [_memoryCache removeObjectForKey:key];
        return nil;
    }
    
    if ([entity.cache conformsToProtocol:@protocol(NSCoding) ]) {
        entity.size = [NSKeyedArchiver archivedDataWithRootObject:entity.cache].length;
    }
    if ([_recentlyAccessedKeys containsObject:key]) {
        [_recentlyAccessedKeys removeObject:key];
    }
    
    @synchronized(self) {
        if (_memoryCache[key]) {
            oldEntitySize = [NSKeyedArchiver archivedDataWithRootObject:((MRSCacheEntity *)_memoryCache[key]).cache].length;
        } else {
            if (_recentlyAccessedKeys.count > _limit) {
                longestUnAccessKey = [_recentlyAccessedKeys lastObject];
                longestUnAccessObject = [_memoryCache objectForKey:longestUnAccessKey];
                [_recentlyAccessedKeys removeObject:longestUnAccessKey];
                [_memoryCache removeObjectForKey:longestUnAccessKey];
                [_cacheKeys removeObject:longestUnAccessKey];
                oldEntitySize = longestUnAccessObject.size;
            }
            [_cacheKeys addObject:key];
            [_cacheKeys sortUsingComparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
                return [obj1 compare:obj2];
            }];
        }
        
        [_recentlyAccessedKeys insertObject:key atIndex:0];
        _memoryCache[key] = entity;
        _cacheSize += entity.size - oldEntitySize;
    }
    return longestUnAccessObject;
}

- (unsigned long long)cacheSize
{
    return _cacheSize;
}

- (void)cleanCache
{
    [_memoryCache removeAllObjects];
    [_recentlyAccessedKeys removeAllObjects];
    [_cacheKeys removeAllObjects];
    _cacheSize = 0;
}

@end
