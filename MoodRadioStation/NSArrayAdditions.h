//
//  NSArrayAdditions.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/5.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (ListOperation)

- (NSArray *)mapCar:(id (^)(id obj, NSUInteger idx, BOOL *stop))block;

@end
