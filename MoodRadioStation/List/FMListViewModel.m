//
//  FMListViewModel.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/5.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "FMListViewModel.h"
#import "FMListModel.h"
#import "MRSFetchResultController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface FMListViewModel()<MRSFetchResultControllerProtocol>

@property (nonatomic, strong) FMListModel *model;

@property (nonatomic, strong) RACCommand *refreshListCommand;
@property (nonatomic, strong) RACCommand *loadMoreCommand;

@property (nonatomic, strong) RACSubject *dataLoadedSignal;
@property (nonatomic, strong) RACSubject *refreshingSignal;

@property (nonatomic, strong) NSError *error;

@property (nonatomic, assign) BOOL loading;

@property (nonatomic, strong) MRSFetchResultController *fetchResultController;

@property (nonatomic, strong) RACDisposable *previousDataRefreshDispose;

@end

@implementation FMListViewModel

- (instancetype)initWithRows:(NSNumber *)rows Tag:(NSString *)tag
{
    self = [super init];
    if (self) {
        _model = [[FMListModel alloc] init];
        _model.offset  = @(0);
        _model.tag = tag;
        _model.rows = rows;
        _fetchResultController = [[MRSFetchResultController alloc] init];
        _fetchResultController.delegate = self;
    }
    return self;
}

- (RACCommand *)refreshListCommand
{
    @weakify(self);
    _refreshListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id x) {
        @strongify(self);
        self.error = nil;
        [self refreshDataNeedReset:YES];
        return [RACSignal empty];
    }];
    return _refreshListCommand;
}

- (RACCommand *)loadMoreCommand
{
    @weakify(self);
    _loadMoreCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        self.loading = YES;
        self.error = nil;
       
        return [[[self.model refreshList] catch:^RACSignal *(NSError *error) {
            self.error = error;
            self.loading = NO;
            return [RACSignal empty];
        }] doNext:^(NSArray *dictArray) {
            @strongify(self);
            if (dictArray) {
                [self.fetchResultController addObjectsInLastSection:dictArray];
                self.model.offset = @(self.fetchResultController.numberOfObject);
            }
            self.loading = NO;
        }];

    }];
    return _loadMoreCommand;
}

- (void)refreshDataNeedReset:(BOOL)needRest
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.previousDataRefreshDispose) {
            [self.previousDataRefreshDispose dispose];
        }
        
        if (needRest) {
            self.model.offset = @(0);
            [_fetchResultController removeAllSections];
        }
        
        [self.refreshingSignal sendNext:@"YES"];
        self.loading = YES;
        
        @weakify(self);
        self.previousDataRefreshDispose = [[[[self.model refreshList] takeUntil:self.refreshingSignal] catch:^RACSignal *(NSError *error) {
            self.error = error;
            self.loading = NO;
            return [RACSignal empty];
        }] subscribeNext:^(NSArray *dictArray) {//冷信号必须要注册才会触发
            @strongify(self)
            if (dictArray) {
                [self.fetchResultController addObjectsInLastSection:dictArray];
                self.model.offset = @(self.fetchResultController.numberOfObject);
            }
            self.loading = NO;
        }];
    });
}

- (RACSubject *)dataLoadedSignal
{
    if (!_dataLoadedSignal) {
        _dataLoadedSignal = [RACSubject subject];
    }
    return _dataLoadedSignal;
}

- (RACSubject *)refreshingSignal
{
    if (!_refreshingSignal) {
        _refreshingSignal = [RACSubject subject];
    }
    return _refreshingSignal;
}

#pragma mark - MRSFetchResultController
- (void)controllerDidChangeContent:(MRSFetchResultController *)controller
{
    [(RACSubject *)self.dataLoadedSignal sendNext:@(controller.numberOfObject > 0)];
}

@end
