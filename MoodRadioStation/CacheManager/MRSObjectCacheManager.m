//
//  MRSObjectCacheManager.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/31.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSObjectCacheManager.h"

@implementation MRSObjectCacheManager

- (instancetype)init
{
    self = [super initWithRoot:@"object"];
    return self;
}

- (BOOL)canSupportObject:(id)object
{
    return !object || [object conformsToProtocol:@protocol(NSCoding)];
}

- (BOOL)saveObject:(id)object atPath:(NSString *)path error:(NSError *__autoreleasing *)error
{
    if (error) {
        *error = nil;
    }
    BOOL success = [NSKeyedArchiver archiveRootObject:object toFile:path];
    return success;
}

- (id)restoreObjectAtPath:(NSString *)path error:(NSError *__autoreleasing *)error
{
    if (error) {
        *error = nil;
    }
    id object = nil;
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    return object;
}

@end
