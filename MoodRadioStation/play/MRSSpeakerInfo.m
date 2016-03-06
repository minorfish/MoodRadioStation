//
//  MRSSpeakerInfo.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/6.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSSpeakerInfo.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation MRSSpeakerInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    MRSSpeakerInfo *speaker = nil;
    return @{@keypath(speaker, ID): @"id",
             @keypath(speaker, name): @"title",
             @keypath(speaker, cover): @"cover",
             @keypath(speaker, fmNum): @"fmnum"};
}

@end
