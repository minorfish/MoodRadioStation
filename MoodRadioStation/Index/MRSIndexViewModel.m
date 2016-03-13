//
//  MRSIndexViewModel.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSIndexViewModel.h"
#import "MRSIndexModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "MRSIndexInfo.h"

@implementation MRSIndexViewModel {
    MRSIndexModel *_model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _model = [[MRSIndexModel alloc] init];
    }
    return self;
}

- (RACCommand *)getIndexCommand
{
    if (!_getIndexCommand) {
        @weakify(self);
        _getIndexCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            [self.dataLoaded sendNext:@(NO)];
            return [[[_model getIndexInfo] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }] doNext:^(MRSIndexInfo *x) {
                @strongify(self);
                self.indexInfo = x;
                [self.dataLoaded sendNext:@(YES)];
            }];
        }];
    }
    return _getIndexCommand;
}

- (RACSubject *)dataLoaded
{
    if (!_dataLoaded) {
        _dataLoaded = [RACSubject subject];
    }
    return _dataLoaded;
}

- (void)dealloc
{
    [self.dataLoaded sendCompleted];
}

@end
