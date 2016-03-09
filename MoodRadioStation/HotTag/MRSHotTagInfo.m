//
//  MRSHotTagInfo.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/9.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSHotTagInfo.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation MRSHotTagInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    MRSHotTagInfo *info = nil;
    return @{@keypath(info, coverURL): @"cover",
             @keypath(info, name): @"name",
             @keypath(info, title): @"title"};
}

@end
