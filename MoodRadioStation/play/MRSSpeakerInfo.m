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

- (BOOL)isEqual:(id)object {
   
    if (!object || ![object isKindOfClass:[MRSSpeakerInfo class]])
        return  NO;
    if ([super isEqual:object])
        return  YES;
    MRSSpeakerInfo *info = (MRSSpeakerInfo *)object;
    if (_ID != info.ID) {
        return  NO;
    } else if (![_name isEqualToString:info.name]) {
        return NO;
    } else if (![_cover isEqualToString:info.cover]) {
        return NO;
    }
    return _fmNum == info.fmNum;
}

@end
