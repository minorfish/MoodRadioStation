//
//  MRSModel.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/5.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperation;
@class AFURLSessionManager;

@interface MRSModel : NSObject

@property (nonatomic, strong) AFURLSessionManager *manager;

- (AFHTTPRequestOperation *)getURL:(NSString *)path
                            Parmas:(NSDictionary*)parmas
                          finished:(void(^)(id data, NSError *error))finished;

- (NSURLSessionDownloadTask *)getRadioWithURL:(NSString*)radioURL
                                     finished:(void(^)(NSURL *filePath, NSError *error))finished;

@end
