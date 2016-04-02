//
//  MRSMyDownloadViewModel.m
//  MoodRadioStation
//
//  Created by Minor on 16/4/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSMyDownloadViewModel.h"
#import "MRSFetchResultController.h"
#import "MRSDownloadHelper.h"
#import "RadioInfo.h"
#import "MRSRadioDao.h"

const NSInteger kMaxLine = 15;

@interface MRSMyDownloadViewModel () <MRSFetchResultControllerProtocol>

@property (nonatomic, strong) MRSDownloadHelper *downloadHelper;
@property (nonatomic, strong) MRSFetchResultController *fetchResultController;
@property (nonatomic, strong) RACCommand *refreshCommand;
@property (nonatomic, strong) RACCommand *loadMoreCommand;
@property (nonatomic, assign) BOOL isloading;
@property (nonatomic, strong) RACSubject *dataLoadSignal;
@property (nonatomic, strong) MRSRadioDao *dao;

@end

@implementation MRSMyDownloadViewModel {
    NSMutableArray *_infoArray;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fetchResultController = [[MRSFetchResultController alloc] init];
        _fetchResultController.delegate = self;
        _infoArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self.dataLoadSignal sendCompleted];
}

- (void)controllerDidChangeContent:(MRSFetchResultController *)controller{
    [self.dataLoadSignal sendNext:@(self.fetchResultController.numberOfObject > 0)];
}

- (BOOL)deleteFileWithID:(long long)ID
{
    return [self.downloadHelper deleteRadioWithID:ID];
}

- (NSArray *)infoArray
{
    return _infoArray;
}

- (MRSDownloadHelper *)downloadHelper
{
    if (!_downloadHelper) {
        _downloadHelper = [MRSDownloadHelper shareDownloadHelper];
    }
    return _downloadHelper;
}

- (RACSubject *)dataLoadSignal
{
    if (!_dataLoadSignal) {
        _dataLoadSignal = [RACSubject subject];
    }
    return _dataLoadSignal;
}

- (RACCommand *)refreshCommand
{
    if (!_refreshCommand) {
        _refreshCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            self.isloading = YES;
            NSMutableDictionary *dictionary = [[self.downloadHelper getDownLoadRadios] mutableCopy];
            [self.fetchResultController removeAllSections];
            [_infoArray removeAllObjects];
            __block int count = 0;
            __block NSMutableArray *array = [[NSMutableArray alloc] init];
            [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSString*  _Nonnull obj, BOOL * _Nonnull stop) {
                
                RadioInfo *info = [self.dao getCacheForRadioID:[key longLongValue]];
                info.dataSize = obj;
                [array addObject:info];
                count++;
                if (count >= kMaxLine) {
                    *stop = YES;
                }
            }];
            [_infoArray addObjectsFromArray:array];
            [self.fetchResultController addObjectsInLastSection:array];
            self.isloading = NO;
            return [RACSignal empty];
        }];
    }
    return _refreshCommand;
}

- (RACCommand *)loadMoreCommand
{
    if (!_loadMoreCommand) {
        _loadMoreCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            self.isloading = YES;
            NSMutableDictionary *dictionary = [[self.downloadHelper getDownLoadRadios] mutableCopy];
            __block int count = 0;
            __block NSMutableArray *array = [[NSMutableArray alloc] init];
            [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSString*  _Nonnull obj, BOOL * _Nonnull stop) {
                
                if (count >= self.fetchResultController.numberOfObject) {
                    RadioInfo *info = [self.dao getCacheForRadioID:[key longLongValue]];
                    info.dataSize = obj;
                    [array addObject:info];
                }
                count++;
                
                if (count >= kMaxLine + self.fetchResultController.numberOfObject) {
                    *stop = YES;
                }
            }];
            [_infoArray arrayByAddingObjectsFromArray:array];
            [self.fetchResultController addObjectsInLastSection:array];
            self.isloading = NO;
            return [RACSignal empty];
        }];
    }
    return _loadMoreCommand;
}

- (MRSRadioDao *)dao
{
    if (!_dao) {
        _dao = [[MRSRadioDao alloc] init];
    }
    return _dao;
}

@end
