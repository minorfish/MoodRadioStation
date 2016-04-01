//
//  MRSRadioDao.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/31.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RadioInfo;

@interface MRSRadioDao : NSObject

- (id)getCacheForRadioID:(long long)ID;
- (void)saveCache:(RadioInfo *)cache ForID:(long long)ID;

- (NSURL *)getFilePathForRadioURL:(NSString *)radioURL;
- (void)saveFilePath:(NSURL *)filePath ForRadioURL:(NSString *)radioURL;

@end
