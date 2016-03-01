//
//  RadioInfoModel.m
//  MoodRadioStation
//
//  Created by Minor on 16/2/27.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "RadioInfoModel.h"
#import <AFNetworking/AFNetworking.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RadioInfo.h"

@interface RadioInfoModel()

@property (nonatomic, strong) AFURLSessionManager *manager;

@end

@implementation RadioInfoModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return self;
}

// 获取播放界面需要的信息
- (AFHTTPRequestOperation *)getRadioWithID:(NSUInteger)ID finished:(void (^)(NSDictionary* dict, NSError* error))finished
{
    NSString *URL = [NSString stringWithFormat:@"http://fm.xinli001.com/broadcast?pk=%lu", ID];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            finished(responseObject[@"data"], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        finished(nil, error);
    }];
    [[NSOperationQueue currentQueue] addOperation:op];
    return op;
}

// 下载音频文件
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

- (RACSignal*)getRadioInfo
{
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        
        __block RACDisposable *disposable = nil;
        AFHTTPRequestOperation *requestOperation = [self getRadioWithID:[self.ID longLongValue] finished:^(NSDictionary *dict, NSError *error) {
            if (!disposable.disposed) {
                if (error) {
                    [subscriber sendError:error];
                } else {
                    NSError *error = nil;
                    RadioInfo *radioInfo = [MTLJSONAdapter modelOfClass:[RadioInfo class] fromJSONDictionary:dict error:&error];
                    if (!error && radioInfo) {
                        [subscriber sendNext:radioInfo];
                    } else {
                        [subscriber sendError:error];
                    }
                }
                [subscriber sendCompleted];
            }
        }];
        
        disposable = [RACSerialDisposable disposableWithBlock:^{
            [requestOperation cancel];
        }];
        return disposable;
    }];
}

- (RACSignal *)getRadio
{
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        __block RACDisposable *disposable = nil;
        NSURLSessionDownloadTask *task = [self getRadioWithURL:self.radioURL
                                                      finished:^(NSURL *filePath, NSError *error) {
                                                          if (!disposable.disposed) {
                                                              if (filePath && !error) {
                                                                  [subscriber sendNext:filePath];
                                                              } else {
                                                                  [subscriber sendError:error];
                                                              }
                                                          }
                                                          [subscriber sendCompleted];
                                                      }];
        disposable = [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
        return disposable;
    }];
}

@end
