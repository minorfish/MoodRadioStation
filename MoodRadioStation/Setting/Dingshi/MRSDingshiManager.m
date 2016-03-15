//
//  MRSDingshiManager.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/15.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSDingshiManager.h"
#import <UIKit/UIKit.h>

const NSString *MRSMRSPauseDisplayLinkNotification = @"com.minor.notification.refrshTimeLabel";

@implementation MRSDingshiManager

+ (void)scheduleNotificationWithFireDate:(NSDate *)fireDate
                                timeZone:(NSTimeZone *)timeZone
                         repeateInterval:(NSCalendarUnit)repeatenterval
                               alertBody:(NSString *)alertBody
                             alertAction:(NSString *)alertAction
                              launchImage:(NSString *)launchImage
                               soundName:(NSString *)soundName
                             badgeNumber:(NSInteger)badgeNumber
                                userInfo:(NSDictionary *)userInfo
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate;
    localNotification.timeZone = timeZone;
    localNotification.repeatInterval = repeatenterval;
    localNotification.alertBody = alertBody;
    localNotification.alertLaunchImage = launchImage;
    localNotification.soundName = soundName;
    localNotification.applicationIconBadgeNumber = badgeNumber;
    localNotification.userInfo = userInfo;
    
    if (!alertAction) {
        localNotification.hasAction = NO;
    } else {
        localNotification.alertAction = alertAction;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    });
}

+ (void)scheduleClosePlayOnDate:(NSDate *)date
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"closePlay", @"type",
                              @"cancelAction", MRSMRSPauseDisplayLinkNotification,
                              nil];
    [MRSDingshiManager scheduleNotificationWithFireDate:date
                                               timeZone:[NSTimeZone systemTimeZone] repeateInterval:0 alertBody:nil alertAction:nil launchImage:nil
                                              soundName:nil
                                            badgeNumber:1
                                               userInfo:userInfo];
}


+ (NSArray *)notificationsForType:(NSString *)type
{
    NSMutableArray *typeNotifications = [[NSMutableArray alloc] init];
    
    NSArray *array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in array) {
        if ([[notification.userInfo objectForKey:@"type"] isEqualToString:type]) {
            [typeNotifications addObject:notification];
        }
    }
    return (NSArray *)typeNotifications;
}

+ (void)cancelNotificationsForType:(NSString *)type
{
    NSArray *typeNotifications = [MRSDingshiManager notificationsForType:type];
    for (UILocalNotification *notification in typeNotifications) {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}

@end
