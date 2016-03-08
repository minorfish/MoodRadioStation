//
//  FMListViewModel.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/5.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACCommand;
@class MRSFetchResultController;
@class RACSubject;
@class RACDisposable;

@interface FMListViewModel : NSObject

@property (nonatomic, readonly) RACCommand *refreshListCommand;
@property (nonatomic, readonly) RACCommand *loadMoreCommand;

// 数据加载完成
@property (nonatomic, readonly) RACSubject *dataLoadedSignal;
//  重新刷新
@property (nonatomic, readonly) RACSubject *refreshingSignal;

@property (nonatomic, readonly) NSError *error;

// 刷新状态
@property (nonatomic, readonly) BOOL loading;

@property (nonatomic, readonly) MRSFetchResultController *fetchResultController;
@property (nonatomic, readonly) NSArray *infoArray;

@property (nonatomic, readonly) RACDisposable *previousDataRefreshDispose;

- (instancetype)initWithRows:(NSNumber *)rows KeyString:(NSString *)keyString KeyValue:(NSString *)keyValue;

@end
