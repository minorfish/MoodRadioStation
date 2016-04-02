//
//  MRSDownloadDao.m
//  MoodRadioStation
//
//  Created by Minor on 16/4/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSDownloadHelper.h"

@implementation MRSDownloadHelper

+ (MRSDownloadHelper *)shareDownloadHelper
{
    static MRSDownloadHelper *downloadHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadHelper = [[MRSDownloadHelper alloc] init];
    });
    return downloadHelper;
}

- (NSString *)downloadFileName
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documentPaths objectAtIndex:0];
    return [documentPath stringByAppendingPathComponent:@"download.plist"];
}

- (BOOL)saveRadioSize:(NSString *)radioSize forRadioID:(long long)ID
{
    NSString *downFilePath = [self downloadFileName];
    NSMutableDictionary *rootDict = [NSMutableDictionary dictionaryWithContentsOfFile:downFilePath];
    BOOL success;
    if (!rootDict) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"plist"];
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
        success = [data writeToFile:downFilePath atomically:YES];
        NSLog(@"%@", @(success));
    }
    
    if (success) {
        rootDict = [NSMutableDictionary dictionaryWithContentsOfFile:downFilePath];
    }
    NSString *key = [[NSNumber numberWithLongLong:ID] stringValue];
    if (!rootDict[key]) {
        @synchronized(self) {
            [rootDict setObject:radioSize forKey:key];
            [rootDict writeToFile:downFilePath atomically:YES];
        }
    }
    return YES;
}

- (NSDictionary *)getDownLoadRadios
{
    NSString *downFilePath = [self downloadFileName];
    return [NSDictionary dictionaryWithContentsOfFile:downFilePath];
}

- (BOOL)deleteRadioWithID:(long long)ID
{
    NSString *downFilePath = [self downloadFileName];
    NSMutableDictionary *rootDict = [NSMutableDictionary dictionaryWithContentsOfFile:downFilePath];
    
    if (!rootDict) {
        return NO;
    }
    
    NSString *key = [[NSNumber numberWithLongLong:ID] stringValue];
    if (rootDict[key]) {
        @synchronized(self) {
            [rootDict removeObjectForKey:key];
            [rootDict writeToFile:downFilePath atomically:YES];
        }
    } else {
        return NO;
    }
    return YES;
}

@end
