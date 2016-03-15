//
//  MRSHotTagModel.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/9.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSHotTagModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AFNetworking/AFNetworking.h>
#import "MRSHotTagInfo.h"
#import "NSArrayAdditions.h"

@interface MRSHotTagModel ()

@property (nonatomic, strong) NSString *key;

@end

@implementation MRSHotTagModel
@dynamic key;

- (AFHTTPRequestOperation *)getHotTagWithFlag:(NSInteger)flag
                                         Rows:(NSInteger)rows
                                       Offset:(NSInteger)offset
                                     Finished:(void(^)(id data, NSError *error))finished
{
    NSString *path = @"http://bapi.xinli001.com/fm2/hot_tag_list.json/";
    NSDictionary *parmas = @{@"flag": @(flag),
                             @"rows": @(rows),
                             @"offset": @(offset),
                             @"key": self.key};
    return [self getURL:path
                 Parmas:parmas
               finished:^(id data, NSError *error) {
                   if (!error && [data isKindOfClass:[NSDictionary class]]) {
                       finished(data[@"data"], error);
                   } else {
                       finished(nil, error);
                   }
               }];
}

- (RACSignal *)getHotTag
{
    if (!_getHotTag) {
        @weakify(self);
        _getHotTag = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            RACDisposable *dispose = nil;
            AFHTTPRequestOperation *op = [self getHotTagWithFlag:self.flag
                               Rows:self.rows
                             Offset:self.offset
                           Finished:^(id data, NSError *error) {
                               if (!dispose.isDisposed) {
                                   if (error) {
                                       [subscriber sendError:error];
                                   } else {
                                       if (data && [data isKindOfClass:[NSArray class]]) {
                                           NSArray *dataArray = data;
                                           NSArray *infoAray = [dataArray mapCar:^MRSHotTagInfo*(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                                               return [MTLJSONAdapter modelOfClass:[MRSHotTagInfo class] fromJSONDictionary:obj error:nil];
                                           }];
                                           [subscriber sendNext:infoAray];
                                       } else {
                                           [subscriber sendNext:nil];
                                       }
                                   }
                                   [subscriber sendCompleted];
                               }
                           }];
            dispose = [RACDisposable disposableWithBlock:^{
                [op cancel];
            }];
            return dispose;
        }];
    }
    return _getHotTag;
}

@end
