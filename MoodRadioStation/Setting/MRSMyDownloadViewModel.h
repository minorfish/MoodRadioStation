//
//  MRSMyDownloadViewModel.h
//  MoodRadioStation
//
//  Created by Minor on 16/4/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@class MRSFetchResultController;

@interface MRSMyDownloadViewModel : NSObject

@property (nonatomic, readonly) RACCommand *refreshCommand;
@property (nonatomic, readonly) RACCommand *loadMoreCommand;
@property (nonatomic, readonly) MRSFetchResultController *fetchResultController;
@property (nonatomic, readonly) BOOL isloading;
@property (nonatomic, readonly) RACSubject *dataLoadSignal;
@property (nonatomic, readonly) NSArray *infoArray;

- (BOOL)deleteFileWithID:(long long)ID;

@end
