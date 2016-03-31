//
//  MRSPersistentCacheManager.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/30.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSPersistentCacheManager.h"
#import "MRSCacheEntity.h"

@implementation MRSPersistentCacheManager

@synthesize directory = _directory;

- (instancetype)initWithRoot:(NSString *)root
{
    self = [super init];
    if (self) {
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if (!cachePaths.count) {
            return nil;
        }
        NSString *cachePath = cachePaths[0];
        _rootCachePath = [[cachePath stringByAppendingPathComponent:@"com.MRS.cache"]
                          stringByAppendingPathComponent:root];
    }
    return self;
}

- (BOOL)canSupportObject:(id)object
{
    return NO;
}

- (BOOL)saveObject:(id)object atPath:(NSString *)path error:(NSError *__autoreleasing *)error
{
    return NO;
}

- (id)restoreObjectAtPath:(NSString *)path error:(NSError *__autoreleasing *)error
{
    return nil;
}

- (void)setDirectory:(NSString *)directory
{
    _directory = [directory copy];
    _cachePath = [_rootCachePath stringByAppendingPathComponent:directory];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager createDirectoryAtPath:_cachePath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (MRSCacheEntity *)setCache:(id)cache forKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    return [self setCache:cache forKey:key atPath:nil error:error];
}

- (MRSCacheEntity *)setCache:(id)cache forKey:(NSString *)key atPath:(NSString *)path error:(NSError *__autoreleasing *)error
{
    MRSCacheEntity *entity = [[MRSCacheEntity alloc] initWithCache:cache key:key path:path];
    return [self setEntity:entity error:error];
}

- (MRSCacheEntity *)setEntity:(MRSCacheEntity *)entity error:(NSError *__autoreleasing *)error
{
    if (![self canSupportObject:entity.cache]) {
        return nil;
    }
    if (error) {
        *error = nil;
    }
    NSString *parentPath = [_cachePath stringByAppendingPathComponent:entity.path];
    NSString *cacheFilePath = [parentPath stringByAppendingPathComponent:entity.key];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *thisError = nil;
    if (!entity.cache) {
        [fileManager removeItemAtPath:cacheFilePath error:&thisError];
    }
    if (thisError) {
        *error = thisError;
        return nil;
    }
    BOOL create = [fileManager createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:&thisError];
    if (create) {
        if ([self saveObject:entity.cache atPath:cacheFilePath error:&thisError]) {
            return entity;
        }
    }
    return nil;
}

- (void)getCacheForKey:(NSString *)key atPath:(NSString *)path finished:(MRSCacheManagerCallBack)finished
{
    NSError *error = nil;
    MRSCacheEntity *entity = [self getCacheForKey:key atPath:path error:&error];
    if (entity) {
        finished(entity, nil);
    } else {
        finished(nil, error);
    }
}

- (MRSCacheEntity *)getCacheForKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    return [self getCacheForKey:key atPath:nil error:error];
}

- (MRSCacheEntity *)getCacheForKey:(NSString *)key atPath:(NSString *)path error:(NSError *__autoreleasing *)error
{
    path = path ? path : @"";
    NSString *parentPath = [_cachePath stringByAppendingPathComponent:path];
    NSString *cacheFilePath = [parentPath stringByAppendingPathComponent:key];
    return [self getEntityAtPath:cacheFilePath error:error];
}

- (MRSCacheEntity *)getEntityAtPath:(NSString *)path error:(NSError **)error
{
    if (error) {
        *error = nil;
    }
    NSError *thisError = nil;
    id cache = [self restoreObjectAtPath:path error:&thisError];
    if (thisError || !cache) {
        *error = thisError;
        return nil;
    }
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:&thisError];
    if (thisError) {
        *error = thisError;
        return nil;
    }
    MRSCacheEntity *entity = [[MRSCacheEntity alloc] init];
    entity.cache = cache;
    entity.date = [attributes fileModificationDate];
    return entity;
}

- (unsigned long long)cacheSize
{
    return [self cacheSizeAtPath:nil];
}

- (unsigned long long)cacheSizeAtPath:(NSString *)path
{
    unsigned long long cacheSize = 0;
    NSError *error = nil;
    NSString *realPath = [_cachePath stringByAppendingPathComponent:path ? path : @""];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:realPath error:&error];
    if (error) {
        return 0;
    }
    NSString *fileType = [attributes fileType];
    if ([fileType isEqualToString:NSFileTypeRegular]) {
        cacheSize += [attributes fileSize];
    } else if ([fileType isEqualToString:NSFileTypeDirectory]) {
        return 0;
    } else if ([fileType isEqualToString:NSFileTypeDirectory]) {
        NSArray *files = [fileManager subpathsOfDirectoryAtPath:realPath error:&error];
        if (error) {
            return 0;
        }
        for (NSString *subPath in files) {
            NSDictionary *subAttributes = [fileManager attributesOfItemAtPath:subPath error:&error];
            
            if (error) {
                continue;
            }
            
            if ([[subAttributes fileType] isEqualToString:NSFileTypeDirectory]) {
                continue;
            }
            
            cacheSize += [subAttributes fileSize];
        }
    }
    return cacheSize;
}

- (void)cleanCacheAtPath:(NSString *)path
{
    NSString *realPath = [_cachePath stringByAppendingPathComponent:path? path: @""];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory;
    BOOL fileExist = [fileManager fileExistsAtPath:realPath isDirectory:&isDirectory];
    if (!fileExist) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [fileManager removeItemAtPath:realPath error:nil];
    });
    
    if ([path isEqualToString:_cachePath] || [path isEqualToString:_rootCachePath]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)cleanCache
{
    [self cleanCacheAtPath:nil];
}

@end