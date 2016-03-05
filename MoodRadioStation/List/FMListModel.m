//
//  FMListModel.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "FMListModel.h"
#import <AFNetworking/AFNetworking.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "FMInfo.h"
#import "UIKitMacros.h"
#import "NSArrayAdditions.h"

@interface FMListModel()

@property (nonatomic, strong) NSString *key;

@end

@implementation FMListModel

@dynamic key;

- (AFHTTPRequestOperation *)getFMListWithRows:(NSNumber *)rows
                                      offset:(NSNumber *)offset
                                         tag:(NSString *)tag
                                  finished:(void(^)(NSDictionary *dict, NSError *error))finished
{
    if (!rows || !offset || !tag)
        return nil;
    
    NSString *path = @"http://bapi.xinli001.com/fm2/broadcast_list.json/";
    NSDictionary *parmas = @{@"rows": rows,
                             @"offset": offset,
                             @"tag": tag,
                             @"key": self.key};
    return [self getURL:path Parmas:parmas finished:^(id data, NSError *error) {
        if (!error && [data isKindOfClass:[NSDictionary class]]) {
            finished(data, nil);
        } else {
            finished(nil, error);
        }
    }];
}

- (RACSignal *)refreshList
{
    @weakify(self);
    _refreshList = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        __block RACDisposable *disposable = nil;
        AFHTTPRequestOperation *op = [self getFMListWithRows:self.rows  offset:self.offset tag:self.tag finished:^(NSDictionary *dict, NSError *error) {
            if (!disposable.isDisposed) {
                if (!error && dict[@"data"]) {
                    NSArray *array = [dict[@"data"] mapCar:^id(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                        return [MTLJSONAdapter modelOfClass:[FMInfo class] fromJSONDictionary:obj error:nil];
                    }];
                    [subscriber sendNext:array];
                } else {
                    [subscriber sendError:error];
                }
                [subscriber sendCompleted];
            }
        }];
        disposable = [RACDisposable disposableWithBlock:^{
            [op cancel];
        }];
        return disposable;
    }];
    return _refreshList;
}

@end
