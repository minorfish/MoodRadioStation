//
//  Radio.m
//  MoodRadioStation
//
//  Created by Minor on 16/2/27.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "RadioInfo.h"
#import "MRSSpeakerInfo.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation RadioInfo

+ (NSDictionary*)JSONKeyPathsByPropertyKey
{
    RadioInfo *radio = nil;
    return @{@keypath(radio, radioID): @"id",
              @keypath(radio, title): @"title",
              @keypath(radio, coverURL): @"cover",
              @keypath(radio, speak): @"speak",
              @keypath(radio, URL): @"url",
              @keypath(radio, radiodDesc): @"content",
              @keypath(radio, speakerInfo): @"diantai"
             };
}

+ (MTLValueTransformer *)speakerInfoJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^MRSSpeakerInfo*(NSDictionary *dict) {
        return [MTLJSONAdapter modelOfClass:[MRSSpeakerInfo class] fromJSONDictionary:dict error:nil];
    }];
}

- (BOOL)isEqual:(id)object
{
    if (!object || ![object isKindOfClass:[RadioInfo class]])
        return NO;
    if ([super isEqual:object]) {
        return YES;
    }
    RadioInfo *info = (RadioInfo *)object;
    if (_radioID != info.radioID) {
        return NO;
    } else if(![_title isEqualToString:info.title]) {
        return NO;
    } else if (![_coverURL isEqualToString:info.coverURL]) {
        return NO;
    } else if (![_speak isEqualToString:info.speak]) {
        return NO;
    } else if (![_URL isEqualToString:info.URL]) {
        return NO;
    } else if (![_radiodDesc isEqualToString:info.radiodDesc]) {
        return NO;
    } 
    return  [_speakerInfo isEqual:info.speakerInfo];
}

@end
