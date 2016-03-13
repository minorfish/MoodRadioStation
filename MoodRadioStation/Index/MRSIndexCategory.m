//
//  MRSIndexCategory.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSIndexCategory.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation MRSIndexCategory

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    MRSIndexCategory *category = nil;
    return @{@keypath(category, ID): @"id",
             @keypath(category, coverURL): @"cover",
             @keypath(category, name): @"name"};
}

@end
