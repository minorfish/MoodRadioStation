//
//  MRSJieMuListModel.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/14.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSJieMuListModel.h"

@interface MRSJieMuListModel ()

@property (nonatomic, strong) NSString *key;

@end

@implementation MRSJieMuListModel

@dynamic key;

- (AFHTTPRequestOperation *)getFMListWithRows:(NSNumber *)rows
                                       Offset:(NSNumber *)offset
                                    KeyString:(NSString *)keyString
                                     KeyValue:(NSString *)keyValue
                                     Finished:(void(^)(NSDictionary *dict, NSError *error))finished
{
    if (!rows || !offset || !keyValue || !keyString)
        return nil;
    
    NSString *path = @"http://yiapi.xinli001.com/fm/category-jiemu-list.json";
    NSDictionary *parmas = @{@"limit": rows,
                             @"offset": offset,
                             keyString: keyValue,
                             @"key": self.key};
    return [self getURL:path Parmas:parmas finished:^(id data, NSError *error) {
        if (!error && [data isKindOfClass:[NSDictionary class]]) {
            finished(data, nil);
        } else {
            finished(nil, error);
        }
    }];
}

@end
