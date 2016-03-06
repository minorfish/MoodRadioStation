//
//  MRSFetchResultSectionInfo.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/6.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSFetchResultSectionInfo.h"

@interface MRSFetchResultSectionInfo()

@property (nonatomic, readwrite) NSMutableArray *objects;

@end

@implementation MRSFetchResultSectionInfo

- (instancetype)initWithArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        _objects = [NSMutableArray arrayWithArray:array];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithArray:nil];
}

- (NSUInteger)numberOfObject
{
    return [self.objects count];
}

@end
