//
//  Radio.m
//  MoodRadioStation
//
//  Created by Minor on 16/2/27.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "RadioInfo.h"
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
              @keypath(radio, radiodDesc): @"content"
             };
}

@end
