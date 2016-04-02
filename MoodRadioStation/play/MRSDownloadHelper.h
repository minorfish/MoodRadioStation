//
//  MRSDownloadDao.h
//  MoodRadioStation
//
//  Created by Minor on 16/4/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSDownloadHelper : NSObject

+ (MRSDownloadHelper *)shareDownloadHelper;

- (BOOL)saveRadioSize:(NSString *)radioSize forRadioID:(long long)ID;
- (NSDictionary *)getDownLoadRadios;
- (BOOL)deleteRadioWithID:(long long)ID;

@end
