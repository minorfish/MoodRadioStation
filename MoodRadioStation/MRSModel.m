//
//  MRSModel.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/5.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSModel.h"
#import <AFNetworking/AFNetworking.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MRSModel()

@property (nonatomic, strong) NSString *key;

@end

@implementation MRSModel

- (instancetype)init
{
    self = [super init];
    if (self) {
//        NSURLSessionConfiguration *backGroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"DownLoadFMBackgroundSession"];
        _manager = [[AFURLSessionManager alloc] init];
        _key = @"c0d28ec0954084b4426223366293d190";
    }
    return self;
}

- (AFHTTPRequestOperation *)getURL:(NSString *)path
                            Parmas:(NSDictionary*)parmas
                          finished:(void(^)(id data, NSError *error))finished
{
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperationManager manager] GET:path parameters:parmas success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        finished(responseObject, nil);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        finished(nil, error);
    }];
    
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html", @"application/json"]];
    
    return op;
}

- (NSURLSessionDownloadTask *)getRadioWithURL:(NSString*)radioURL finished:(void(^)(NSURL *filePath, NSError *error))finished
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:radioURL]];
    NSURLSessionDownloadTask *downloadTask = [_manager downloadTaskWithRequest:request
                                                                      progress:nil
                                                                   destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                                       NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                                                                       return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                                                                   } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                                       if (filePath && !error) {
                                                                           finished(filePath, error);
                                                                       } else {
                                                                           finished(nil, error);
                                                                       }
                                                                   }];
    [downloadTask resume];
    return downloadTask;
}

@end
