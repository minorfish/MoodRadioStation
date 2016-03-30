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
- (MRSCacheEntity *)getEntityForKey:(NSString *)key error:(NSError **)error;
- (void)getEntityForKey:(NSString *)key finished:(MRSCacheManagerCallBack)finished;

- (MRSCacheEntity *)getCacheForKey:(NSString *)key atPath:(NSString *)path error:(NSError **)error;
- (void)getCacheForKey:(NSString *)key atPath:(NSString *)path finished:(MRSCacheManagerCallBack)finished;

- (void)setEntity:(MRSCacheEntity *)entity error:(NSError **)error;
- (void)setCache:(id)cache forKey:(NSString *)key error:(NSError **)error;
- (void)setCache:(id)cache forKey:(NSString *)key atPath:(NSString *)path error:(NSError **)error;

@end
