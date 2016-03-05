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
    return @{@keypath(info, ID): @"id",
             @keypath(info, cover): @"cover",
             @keypath(info, mediaURL): @"url",
             @keypath(info, background): @"background",
             @keypath(info, title): @"title",
             @keypath(info, speak): @"speak"};
}

@end
