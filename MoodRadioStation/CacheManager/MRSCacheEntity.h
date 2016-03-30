//
//  MRSCacheEntity.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/30.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSCacheEntity : NSObject

@property (nonatomic, strong) id cache;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) BOOL dirty;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) unsigned long long size;

- (instancetype)initWithCache:(id)cache
                          key:(NSString *)key
                         path:(NSString *)path;

@end
