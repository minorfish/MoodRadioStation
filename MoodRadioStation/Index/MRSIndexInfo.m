//
//  MRSIndexInfo.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSIndexInfo.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "NSArrayAdditions.h"
#import "MRSIndexCategory.h"
#import "RadioInfo.h"

@implementation MRSIndexInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    MRSIndexInfo *indexInfo = nil;
    return @{@keypath(indexInfo, categoryArray): @"category",
             @keypath(indexInfo, hotfmArray): @"hotfm",
             @keypath(indexInfo, latestfmArray): @"newfm",
             @keypath(indexInfo, lessonArray): @"newlesson"};
}

+ (MTLValueTransformer *)categoryArrayJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^NSArray*(NSArray *dictArray) {
        return [dictArray mapCar:^MRSIndexCategory*(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            return [MTLJSONAdapter modelOfClass:[MRSIndexCategory class] fromJSONDictionary:obj error:nil];
        }];
    }];
}

+ (MTLValueTransformer *)hotfmArrayJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^NSArray*(NSArray *dictArray) {
        return [dictArray mapCar:^RadioInfo*(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            return [MTLJSONAdapter modelOfClass:[RadioInfo class] fromJSONDictionary:obj error:nil];
        }];
    }];
}

+ (MTLValueTransformer *)latestfmArrayJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^NSArray*(NSArray *dictArray) {
        return [dictArray mapCar:^RadioInfo*(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            return [MTLJSONAdapter modelOfClass:[RadioInfo class] fromJSONDictionary:obj error:nil];
        }];
    }];
}

+ (MTLValueTransformer *)lessonArrayJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^NSArray*(NSArray *dictArray) {
        return [dictArray mapCar:^RadioInfo*(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            return [MTLJSONAdapter modelOfClass:[RadioInfo class] fromJSONDictionary:obj error:nil];
        }];
    }];
}

@end
