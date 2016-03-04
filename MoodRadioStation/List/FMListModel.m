//
//  FMListModel.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "FMListModel.h"
#import <AFNetworking/AFNetworking.h>
#import <hpple/TFHpple.h>

@implementation FMListModel

- (AFHTTPRequestOperation *)getFMHtmlWithP:(NSString *)p Page:(NSString *)page N:(NSString *)n finished:(void(^)(NSArray *dictArray, NSError *error))finished
{
    NSString *path = @"http://fm.xinli001.com/tagshow";
    NSDictionary *parmas = @{@"p": p,
                             @"page": page,
                             @"n": n};
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperationManager manager] GET:path parameters:parmas success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSLog(@"%@", responseObject);
        if ([responseObject isKindOfClass:[NSData class]]) {
            TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
            TFHppleElement *element = [doc peekAtSearchWithXPathQuery:@"//ul"];
            
            NSArray *liArray = [element childrenWithTagName:@"li"];
            TFHppleElement *secondElement = liArray[1];
            TFHppleElement *ulElement = [secondElement firstChildWithTagName:@"ul"];
            NSMutableArray *dictArray = [[NSMutableArray alloc] init];
            for (TFHppleElement *liElement in [ulElement childrenWithTagName:@"li"]) {
                TFHppleElement *divElement = [liElement firstChildWithTagName:@"div"];
                TFHppleElement *aElement = [liElement firstChildWithTagName:@"a"];
                TFHppleElement *imgElement = [aElement firstChildWithTagName:@"img"];
                NSString *imgURL = [imgElement objectForKey:@"src"];
                aElement = [divElement firstChildWithTagName:@"a"];
                NSString *pkID = [aElement objectForKey:@"data-pk"];
                NSString *text = [aElement text];
                TFHppleElement *spanElement = [divElement firstChildWithTagName:@"span"];
                NSString *speakName = [spanElement text];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                if (imgURL) {
                    [dict setObject:imgURL forKey:@"imgURL"];
                }
                if (pkID) {
                    [dict setObject:pkID forKey:@"pkID"];
                }
                if (text) {
                    [dict setObject:text forKey:@"title"];
                }
                if (speakName) {
                    [dict setObject:speakName forKey:@"speakName"];
                }
                [dictArray addObject:dict];
                NSLog(@"imgURL:%@pkID:%@text:%@speakName:%@", imgURL, pkID, text, speakName);
            }
            finished(dictArray, nil);
        } else {
            finished(nil, nil);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        finished(nil, error);
    }];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    return op;
}

@end
