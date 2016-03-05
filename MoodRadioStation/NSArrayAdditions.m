//
//  NSArrayAdditions.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/5.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "NSArrayAdditions.h"

@implementation NSArray (ListOperation)

- (NSArray *)mapCar:(id (^)(id, NSUInteger, BOOL *))block
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for (NSUInteger index = 0; index < self.count; index++) {
        id object = [self objectAtIndex:index];
        BOOL stop = NO;
        id result = block(object, index, &stop);
        if (result) {
            [array addObject:result];
        }
        if (stop) {
            break;
        }
    }
    return [NSArray arrayWithArray:array];
}

@end

