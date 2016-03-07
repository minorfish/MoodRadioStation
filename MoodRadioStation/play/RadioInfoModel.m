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

@property (nonatomic, strong) NSString *key;

@end

@implementation RadioInfoModel

@dynamic key;

- (instancetype)init{
    self = [super init];
    if (self) {
        [self.manager setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest * _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLResponse * _Nonnull response, NSURLRequest * _Nonnull request) {
            return request;
        }];
    }
    return self;
}

// 获取播放界面需要的信息
- (AFHTTPRequestOperation *)getRadioWithID:(NSUInteger)ID finished:(void (^)(NSDictionary* dict, NSError* error))finished
{
    NSString *path = @"http://yiapi.xinli001.com/fm/broadcast-detail-old.json?";
    
    NSDictionary *dict = @{@"key": self.key,
                           @"id": @(ID)};
    return [self getURL:path
          Parmas:dict
        finished:^(NSDictionary *data, NSError *error) {
            finished(data[@"data"], error);
        }];
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
