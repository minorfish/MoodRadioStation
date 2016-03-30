//
//  MRSPersistentCacheManager.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/30.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRSCacheManagerProtocol.h"

@interface MRSPersistentCacheManager : NSObject<MRSCacheManagerProtocol>

@property (nonatomic, strong) NSString *rootCachePath;
@property (nonatomic, strong) NSString *cachePath;

- (id)initWithRoot:(NSString *)root;
- (BOOL)canSupportObject:(id)object; /*virtual method */
- (BOOL)saveObject:(id)object atPath:(NSString *)path error:(NSError **)error; /* virtual method */
- (id)restoreObjectAtPath:(NSString *)path error:(NSError **)error; /* virtual method */

@end
