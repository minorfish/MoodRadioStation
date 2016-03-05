//
//  FMListViewModel.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/5.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "FMListViewModel.h"
#import "FMListModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface FMListViewModel()

@property (nonatomic, strong) FMListModel *model;

@end

@implementation FMListViewModel
{
    NSMutableArray *_infoArray;
}

- (instancetype)initWithRows:(NSNumber *)rows Tag:(NSString *)tag
{
    self = [super init];
    if (self) {
        _model = [[FMListModel alloc] init];
        _model.offset  = @(0);
        _model.tag = tag;
        _model.rows = rows;
    }
    return self;
}

- (RACCommand *)refreshListCommand
{
    @weakify(self);
    _refreshListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSNumber *reset) {
        @strongify(self);
        
        if ([reset boolValue]) {
            self.model.offset = @(0);
            _infoArray = [NSMutableArray array];
        } else {
            self.model.offset = @([self.model.rows longLongValue] + [self.model.rows longLongValue]);
        }
        
        return [[[self.model refreshList] catch:^RACSignal *(NSError *error) {
            return [RACSignal empty];
        }] doNext:^(NSArray *dictArray) {
            @strongify(self);
            [_infoArray addObjectsFromArray:dictArray];
            NSLog(@"%@", self.infoArray);
        }];
    }];
    return _refreshListCommand;
}

- (NSArray *)infoArray
{
    return _infoArray;
}

@end
