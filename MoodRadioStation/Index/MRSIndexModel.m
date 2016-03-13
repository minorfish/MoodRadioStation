//
//  MRSIndexModel.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSIndexModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AFNetworking/AFNetworking.h>
#import "MRSIndexInfo.h"
#import "NSArrayAdditions.h"

@interface MRSIndexModel ()

@property (nonatomic, strong) NSString *key;

@end

@implementation MRSIndexModel

@dynamic key;

- (AFHTTPRequestOperation *)getFMInfoWithFinished:(void(^)(NSDictionary  *dataDict, NSError *error))finished
{
    NSString *path = @"http://yiapi.xinli001.com/fm/home-list.json";
    NSDictionary *parmas = @{@"key": self.key};
    return [self getURL:path
                Parmas:parmas
              finished:^(id data, NSError *error) {
                  if (error) {
                      finished(nil, error);
                  } else {
                      if ([data isKindOfClass:[NSDictionary class]]) {
                          finished(data[@"data"], nil);
                      } else {
                          finished(nil, nil);
                      }
                  }
              }];
}

- (RACSignal *)getIndexInfo
{
    if (!_getIndexInfo) {
        @weakify(self);
        _getIndexInfo = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            RACDisposable *disposable = nil;
            AFHTTPRequestOperation *op = [self getFMInfoWithFinished:^(NSDictionary *dataDict, NSError *error) {
                if (!disposable.isDisposed) {
                    if (error) {
                        [subscriber sendError:error];
                    } else {
                        MRSIndexInfo *indexInfo = [MTLJSONAdapter modelOfClass:[MRSIndexInfo class] fromJSONDictionary:dataDict error:nil];
                        [subscriber sendNext:indexInfo];
                    }
                    [subscriber sendCompleted];
                }
            }];
            disposable = [RACDisposable disposableWithBlock:^{
                [op cancel];
            }];
            return disposable;
        }];
    }
    return _getIndexInfo;
}

@end
