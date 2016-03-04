//
//  FMListModel.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPRequestOperation;

@interface FMListModel : NSObject

- (AFHTTPRequestOperation *)getFMHtmlWithP:(NSString *)p Page:(NSString *)page N:(NSString *)n finished:(void(^)(NSArray *dictArray, NSError *error))finished

@end
