//
//  MRSLoaderURLManager.m
//  MoodRadioStation
//
//  Created by Minor on 16/4/12.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSLoaderURLManager.h"
#import <AFNetworking/AFNetworking.h>
#import "MRSRadioRequestTask.h"

extern const NSString *MRSResourceLoaderRequestCompleted;
extern const NSString *MRSResourceLoaderRequestFailed;

@interface MRSLoaderURLManager ()

@property (nonatomic, strong) NSMutableArray *pendingRequests;
@property (nonatomic, copy) NSString *radioPath;
@property (nonatomic, strong) MRSRadioRequestTask *task;

@end

@implementation MRSLoaderURLManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pendingRequests = [[NSMutableArray alloc] init];
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [documentPaths objectAtIndex:0];
        _radioPath = [documentPath stringByAppendingPathComponent:@"tmp.mp3"];
    }
    return self;
}

+ (NSURL *)getSchemeRadioURL:(NSURL *)radioURL
{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:radioURL resolvingAgainstBaseURL:NO];
    components.scheme = @"MinorMinor";
    return [components URL];
}

// 在完成loadfinished之前，需要将返回数据的关键信息写进AVAssetResourceLoadingContentInformationRequest里，为了后面处理数据使用
- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest
{
    NSString *mineType = self.task.mimeType;
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)mineType, NULL);
    contentInformationRequest.byteRangeAccessSupported = YES;
    contentInformationRequest.contentType = CFBridgingRelease(contentType);
    contentInformationRequest.contentLength = self.task.radioLength;
}

- (BOOL)respondCompletedWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest
{
    // 当前请求的loadingRequest的开始请求的第一个字节
    long long startOffset = dataRequest.requestedOffset;
    
    if (dataRequest.currentOffset != 0) {
        startOffset = dataRequest.currentOffset;
    }
    
    // 这个下载请求都没下载数据
    if (self.task.offset + self.task.downLoadingOffset < startOffset) {
        return NO;
    }
    
    if (startOffset < self.task.offset) {
        return NO;
    }
    
    NSData *filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:_radioPath] options:NSDataReadingMappedIfSafe error:nil];
    
    NSUInteger unreadBytes = self.task.downLoadingOffset + self.task.offset - startOffset;
    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    
    // 更新currentOffset
    [dataRequest respondWithData:[filedata subdataWithRange:NSMakeRange((NSUInteger)startOffset - self.task.offset,(NSUInteger)numberOfBytesToRespondWith)]];
    
    long long endOffset = startOffset + dataRequest.requestedLength;
    
    return (self.task.offset + self.task.downLoadingOffset) >= endOffset;
}

- (void)processPendingRequests
{
    NSMutableArray *completedRequest = [NSMutableArray array];
    
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests) {
        
        [self fillInContentInformation:loadingRequest.contentInformationRequest];
        
        BOOL isRespondConpletely = [self respondCompletedWithDataForRequest:loadingRequest.dataRequest];
        
        if (isRespondConpletely) {
            [completedRequest addObject:loadingRequest];
            [loadingRequest finishLoading];
        }
    }
    [self.pendingRequests removeObjectsInArray:completedRequest];
}

- (void)dealWithLoadingRequset:(AVAssetResourceLoadingRequest *)loaderRequest
{
    NSURL *interceivedURL = [loaderRequest.request URL];
    // 缓存资源的下个字节位置
    NSRange range = NSMakeRange((NSUInteger)loaderRequest.dataRequest.currentOffset, NSUIntegerMax);
    
    if (self.task.downLoadingOffset > 0) {
        [self processPendingRequests];
    }
    
    if (!self.task) {
        self.task = [[MRSRadioRequestTask alloc] init];
        self.task.delegate = self;
        [self.task setUrl:interceivedURL offset:0];
    } else {
        // 如果新的rang的起始位置比当前缓存的位置还大，则重新按照range请求数据, 往回拖也重新请求 ？？
        if (self.task.offset + self.task.downLoadingOffset < range.location || range.location < self.task.offset) {
            [self.task setUrl:interceivedURL offset:range.location];
        }
    }
}

#pragma resourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [self.pendingRequests addObject:loadingRequest];
    [self dealWithLoadingRequset:loadingRequest];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [self.pendingRequests removeObject:loadingRequest];
}

#pragma mark - MRSRadioRequestTaskDelegate

- (void)task:(MRSRadioRequestTask *)task didReceiveRadioLength:(NSUInteger)radioLength mimeType:(NSString *)mimeType
{
    
}
- (void)didReceiveRadioDataWithTask:(MRSRadioRequestTask *)task;
{
    [self processPendingRequests];
    
}

- (void)didFinishLoadingWithTask:(MRSRadioRequestTask *)task
{
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingWithTask:)]) {
        [self.delegate didFinishLoadingWithTask:task];
    }
}

- (void)didFailLoadingWithTask:(MRSRadioRequestTask *)task WithError:(NSInteger)errorCode
{
    if ([self.delegate respondsToSelector:@selector(didFailLoadingWithTask:WithError:)]) {
        [self.delegate didFailLoadingWithTask:task WithError:errorCode];
    }
}

@end
