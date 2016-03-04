//
//  FMInfo.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "FMInfo.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation FMInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    FMInfo *info = nil;
    return @{@keypath(info, pkID): @"pkID",
              @keypath(info, title): @"title",
              @keypath(info, imageURL): @"imgURL",
              @keypath(info, speakName): @"speakName"
              };
}

@end
