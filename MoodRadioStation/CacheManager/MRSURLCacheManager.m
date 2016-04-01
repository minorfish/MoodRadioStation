//
//  MRSURLCacheManager.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/30.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSURLCacheManager.h"

@implementation MRSURLCacheManager

- (instancetype)init
{
    self = [super initWithRoot:@"url"];
    return self;
}

- (BOOL)canSupportObject:(id)object
{
    return !object || [object isKindOfClass:[NSData class]] || [object isKindOfClass:[NSString class]];
}

- (BOOL)saveObject:(id)object atPath:(NSString *)path error:(NSError **)error
{
    NSData *cacheData = nil;
    if ([object isKindOfClass:[NSData class]]) {
        cacheData = (NSData *)object;
    } else if ([object isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *)object;
        cacheData = [string dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    BOOL success = [cacheData writeToFile:path options:NSDataWritingAtomic error:error];
    return success;
}

- (id)restoreObjectAtPath:(NSString *)path error:(NSError **)error
{
    if (error) {
        *error = nil;
    }
    NSError *thisError = nil;
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&thisError];
    if (thisError) {
        *error = thisError;
        return nil;
    }
    return data;
}

@end
