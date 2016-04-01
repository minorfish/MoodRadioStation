//
//  MRSCacheManager.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/31.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSCacheManager.h"
#import "MRSMemoryCacheManager.h"
#import "MRSPersistentCacheManager.h"
#import "MRSURLCacheManager.h"
#import <UIKit/UIKit.h>
#import "MRSCacheEntity.h"
#import "MRSObjectCacheManager.h"

static MRSCacheManagerStrategy URLCacheStrategy;
static MRSCacheManagerStrategy ObjectCacheStrategy;

@implementation MRSCacheManager

@synthesize directory = _directory;

- (instancetype)initWithStrategy:(MRSCacheManagerStrategy)strategy queueName:(char *)queueName
{
    self = [super init];
    if (self) {
        _memoryCacheManager = [[MRSMemoryCacheManager alloc] init];
        _queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT);
        _strategy = strategy;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminate) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dumpMemoryCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDirectory:(NSString *)directory
{
    _directory = directory.length > 0? directory: @"public";
    dispatch_barrier_sync(_queue, ^{
        _memoryCacheManager.directory = _directory;
        _persistentCacheManager.directory = _directory;
    });
}

+ (MRSCacheManager *)defaultURLCacheManager
{
    static MRSCacheManager *defaultURLCacheManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultURLCacheManager = [[MRSCacheManager alloc] initWithStrategy:URLCacheStrategy queueName:"com.MRS.dispatchQueue.URLCacheManager"];
        defaultURLCacheManager.persistentCacheManager = [[MRSURLCacheManager alloc] init];
        defaultURLCacheManager.directory = nil;
    });
    return defaultURLCacheManager;
}

+ (MRSCacheManager *)defaultObjectCacheManager
{
    static MRSCacheManager *defaultObjectCacheManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultObjectCacheManager = [[MRSCacheManager alloc] initWithStrategy:ObjectCacheStrategy queueName:"com.MRS.dispatchQueue.ObjectCacheManager"];
        defaultObjectCacheManager.persistentCacheManager = [[MRSObjectCacheManager alloc] init];
        defaultObjectCacheManager.directory = nil;
    });
    return defaultObjectCacheManager;
}

+ (void)setURLCacheStragety:(MRSCacheManagerStrategy)strategy
{
    URLCacheStrategy = strategy;
}

+ (void)setObjectStrategy:(MRSCacheManagerStrategy)strategy
{
    ObjectCacheStrategy = strategy;
}

- (MRSCacheEntity *)setCache:(id)cache forKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    return [self setCache:cache forKey:key atPath:nil error:error];
}

- (MRSCacheEntity *)setCache:(id)cache forKey:(NSString *)key atPath:(NSString *)path error:(NSError *__autoreleasing *)error
{
    path = path ? path : @"";
    MRSCacheEntity *entity = [[MRSCacheEntity alloc] initWithCache:cache key:key path:path];
    return [self setEntity:entity error:error];
}

- (MRSCacheEntity *)setEntity:(MRSCacheEntity *)entity error:(NSError *__autoreleasing *)error
{
    __block NSError *innerError = nil;
    if (_strategy == MRSCacheManagerStrategy_writeBack) {
        __block MRSCacheEntity *staleEntity = nil;
        dispatch_barrier_sync(_queue, ^{
            staleEntity = [_memoryCacheManager setEntity:entity error:&innerError];
        });
        if (innerError) {
            *error = innerError;
            return nil;
        }
        if (staleEntity) {
            dispatch_barrier_sync(_queue, ^{
                [_persistentCacheManager setEntity:staleEntity error:&innerError];
            });
        }
        return entity;
    } else {
        __block MRSCacheEntity *resultEntity = nil;
        dispatch_barrier_sync(_queue, ^{
            [_memoryCacheManager setEntity:entity error:&innerError];
            if (innerError) {
                *error = innerError;
                return;
            }
            resultEntity = [_persistentCacheManager setEntity:entity error:&innerError];
        });
        return resultEntity;
    }
}

- (MRSCacheEntity *)getCacheForKey:(NSString *)key atPath:(NSString *)path error:(NSError *__autoreleasing *)error
{
    __block MRSCacheEntity *entity = nil;
    __block NSError *innerError = nil;
    dispatch_barrier_sync(_queue, ^{
        entity = [_memoryCacheManager getCacheForKey:key atPath:path error:&innerError];
        if (innerError) {
            *error = innerError;
            return;
        }
        
        if (entity) {
            return;
        }
        entity = [_persistentCacheManager getCacheForKey:key atPath:path error:&innerError];
        if (entity) {
            return;
        }
    });
    
    if (!entity) {
        return nil;
    }
    
    __block MRSCacheEntity *staleEntity = nil;
    __block NSError *thisError = nil;
    dispatch_barrier_sync(_queue, ^{
        staleEntity = [_memoryCacheManager setEntity:entity error:&thisError];
        if (thisError) {
            *error = thisError;
            return;
        }
        if (staleEntity && _strategy == MRSCacheManagerStrategy_writeBack) {
            dispatch_barrier_sync(_queue, ^{
                [_persistentCacheManager setEntity:staleEntity error:&thisError];
            });
        }
    });
    
    return entity;
}

- (MRSCacheEntity *)getCacheForKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    return [self getCacheForKey:key atPath:nil error:error];
}

- (unsigned long long)cacheSize
{
    __block unsigned long long size = 0;
    dispatch_barrier_sync(_queue, ^{
        size = [_persistentCacheManager cacheSize];
    });
    return size;
}

- (unsigned long long)cacheSizeAtPath:(NSString *)path
{
    __block unsigned long long size = 0;
    dispatch_barrier_sync(_queue, ^{
        size = [_persistentCacheManager cacheSizeAtPath:path];
    });
    return size;
}

- (void)cleanCache
{
    dispatch_barrier_sync(_queue, ^{
        [_memoryCacheManager cleanCache];
        [_persistentCacheManager cleanCache];
    });
}

- (void)cleanCacheAtPath:(NSString *)path
{
    dispatch_barrier_sync(_queue, ^{
        [_memoryCacheManager cleanCacheAtPath:path];
        [_persistentCacheManager cleanCacheAtPath:path];
    });
}

- (void)saveMemoryCache
{
    if (_strategy == MRSCacheManagerStrategy_writeThrough) {
        return;
    }
    dispatch_suspend(_queue);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_memoryCacheManager.memoryCache enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, MRSCacheEntity*  _Nonnull obj, BOOL * _Nonnull stop) {
            if (!obj.dirty) {
                return;
            }
            NSError *error = nil;
            [_persistentCacheManager setCache:obj.cache forKey:obj.key error:&error];
            if (error) {
                *stop = YES;
            }
            if (!_inBackground) {
                *stop = YES;
            }
        }];
    });
    dispatch_resume(_queue);
}

- (void)didEnterBackground
{
    if (_inBackground) {
        return;
    }
    _inBackground = YES;
    [self saveMemoryCache];
}

- (void)willTerminate
{
    [self saveMemoryCache];
}

- (void)willEnterForeground
{
    if (!_inBackground) {
        return;
    }
    _inBackground = NO;
}

- (void)dumpMemoryCache
{
    [self saveMemoryCache];
    dispatch_barrier_sync(_queue, ^{
        [_memoryCacheManager cleanCache];
    });
}

@end
