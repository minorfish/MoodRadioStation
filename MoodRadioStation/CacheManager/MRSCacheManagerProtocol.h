//
//  MRSCacheManagerProtocol.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/30.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MRSCacheEntity;

typedef void(^MRSCacheManagerCallBack)(MRSCacheEntity *, NSError *);
@protocol MRSCacheManagerProtocol<NSObject>

@property (nonatomic, strong) NSString *directory;

#pragma mark size
- (unsigned long long)cacheSize;
- (unsigned long long)cacheSizeAtPath:(NSString *)path;

#pragma mark clean
- (void)cleanCache;
- (void)cleanCacheAtPath:(NSString *)path;

#pragma mark cache
- (MRSCacheEntity *)getCacheForKey:(NSString *)key error:(NSError **)error;
- (void)getCacheForKey:(NSString *)key finished:(MRSCacheManagerCallBack)finished;

- (MRSCacheEntity *)getCacheForKey:(NSString *)key atPath:(NSString *)path error:(NSError **)error;
- (void)getCacheForKey:(NSString *)key atPath:(NSString *)path finished:(MRSCacheManagerCallBack)finished;

- (MRSCacheEntity *)setEntity:(MRSCacheEntity *)entity error:(NSError **)error;
- (MRSCacheEntity *)setCache:(id)cache forKey:(NSString *)key error:(NSError **)error;
- (MRSCacheEntity *)setCache:(id)cache forKey:(NSString *)key atPath:(NSString *)path error:(NSError **)error;

- (MRSCacheEntity *)setEntity:(MRSCacheEntity *)entity
               forceWriteBack:(BOOL)forceWrite
                        error:(NSError **)error;
- (MRSCacheEntity *)setCache:(id)cache
                      forKey:(NSString *)key
              forceWriteBack:(BOOL)forceWrite
                       error:(NSError **)error;
- (MRSCacheEntity *)setCache:(id)cache
                      forKey:(NSString *)key
                      atPath:(NSString *)path
              forceWriteBack:(BOOL)forceWrite
                       error:(NSError **)error;
@end
