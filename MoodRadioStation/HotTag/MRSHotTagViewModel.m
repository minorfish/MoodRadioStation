//
//  MRSHotTagViewModel.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/9.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSHotTagViewModel.h"
#import "MRSHotTagModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MRSHotTagViewModel ()

@property (nonatomic, strong) MRSHotTagModel *model;
@property (nonatomic, strong) RACSubject *dataLoaded;

@end

@implementation MRSHotTagViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _model = [[MRSHotTagModel alloc] init];
    }
    return self;
}

- (RACCommand *)getHotTagCommand
{
    if (!_getHotTagCommand) {
        @weakify(self);
        _getHotTagCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            self.model.flag = self.flag;
            self.model.rows = self.rows;
            self.model.offset = self.offset;
            return [[[self.model getHotTag] catch:^RACSignal *(NSError *error) {
                return [RACSignal empty];
            }] doNext:^(NSArray *x) {
                @strongify(self);
                [self.dataLoaded sendNext:x];
            }];
        }];
    }
    return _getHotTagCommand;
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
