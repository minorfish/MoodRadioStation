//
//  MRSDingshiManager.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/15.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRSDingshiManager : NSObject

+ (void)scheduleClosePlayOnDate:(NSDate *)date;
+ (void)cancelNotificationsForType:(NSString *)type;

@end
