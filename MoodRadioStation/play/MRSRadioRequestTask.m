//
//  MRSRadioRequestTask.m
//  MoodRadioStation
//
//  Created by Minor on 16/4/12.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSRadioRequestTask.h"
#import <AFNetworking/AFNetworking.h>
#import <AVFoundation/AVFoundation.h>

@interface MRSRadioRequestTask () <NSURLConnectionDataDelegate,AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, assign) NSUInteger radioLength;
@property (nonatomic, assign) NSUInteger downLoadingOffset;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, assign) BOOL isFinishLoad;

@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) NSString *tmpPath;
@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, assign) BOOL once;

@property (nonatomic, strong) NSMutableArray  *taskArr;

@end

@implementation MRSRadioRequestTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [documentPaths objectAtIndex:0];
        _tmpPath = [documentPath stringByAppendingPathComponent:@"tmp.mp3"];
        _taskArr = [NSMutableArray array];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_tmpPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:_tmpPath error:nil];
            [[NSFileManager defaultManager] createFileAtPath:_tmpPath contents:nil attributes:nil];
            
        } else {
            [[NSFileManager defaultManager] createFileAtPath:_tmpPath contents:nil attributes:nil];
        }
    }
    return self;
}

- (void)setUrl:(NSURL *)url offset:(NSUInteger)offset
{
    _url = url;
    _offset = offset;
    
    // 如果建立第二次请求，先移除原来文件，再创建新的
    if (self.taskArr.count >= 1) {
        [[NSFileManager defaultManager] removeItemAtPath:_tmpPath error:nil];
        [[NSFileManager defaultManager] createFileAtPath:_tmpPath contents:nil attributes:nil];
    }
    
    _downLoadingOffset = 0;
    
    NSURLComponents *realURLComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    realURLComponents.scheme = @"http";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[realURLComponents URL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    if (offset > 0 && _radioLength) {
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-",(unsigned long)offset] forHTTPHeaderField:@"Range"];
    }
    
    [self.connection cancel];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection setDelegateQueue:[NSOperationQueue mainQueue]];
    [self.connection start];
}

#pragma mark -  NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(nonnull NSURLResponse *)response
{
    _isFinishLoad = NO;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    self.fileName = [response suggestedFilename];
    
    NSDictionary *dic = (NSDictionary *)[httpResponse allHeaderFields] ;
    
    NSString *content = [dic valueForKey:@"Content-Range"];
    NSArray *array = [content componentsSeparatedByString:@"/"];
    NSString *length = array.lastObject;
    
    NSUInteger radioLength;
    
    if ([length integerValue] == 0) {
        radioLength = (NSUInteger)httpResponse.expectedContentLength;
    } else {
        radioLength = [length integerValue];
    }
    
    self.radioLength = radioLength;
    self.mimeType = @"audio/mpeg";

    if ([self.delegate respondsToSelector:@selector(task:didReceiveRadioLength:mimeType:)]) {
        [self.delegate task:self didReceiveRadioLength:self.radioLength mimeType:self.mimeType];
    }
    
    [self.taskArr addObject:connection];
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:_tmpPath];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.fileHandle seekToEndOfFile];
    [self.fileHandle writeData:data];
    _downLoadingOffset += data.length;
    
    if ([self.delegate respondsToSelector:@selector(didReceiveRadioDataWithTask:)]) {
        [self.delegate didReceiveRadioDataWithTask:self];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _isFinishLoad = YES;
    if (self.taskArr.count <= 1) {
        NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        NSString *movePath = [document stringByAppendingPathComponent:@"tmp.mp3"];
        
        BOOL isSuccess = [[NSFileManager defaultManager] copyItemAtPath:_tmpPath toPath:movePath error:nil];
        if (isSuccess) {
            NSLog(@"move success");
        }else{
            NSLog(@"move fail");
        }
        NSLog(@"----%@", movePath);
    }
    
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingWithTask:)]) {
        [self.delegate didFinishLoadingWithTask:self];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error.code == -1001 && !_once) {      //网络超时，重连一次
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), [NSOperationQueue currentQueue], ^{
            [self continueLoading];
        });
    }
    if ([self.delegate respondsToSelector:@selector(didFailLoadingWithTask:WithError:)]) {
        [self.delegate didFailLoadingWithTask:self WithError:error.code];
    }
    if (error.code == -1009) {
        NSLog(@"无网络连接");
    }
}

- (void)continueLoading
{
    _once = YES;
    NSURLComponents *realURLComponents = [[NSURLComponents alloc] initWithURL:_url resolvingAgainstBaseURL:NO];
    realURLComponents.scheme = @"http";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[realURLComponents URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    
    [request addValue:[NSString stringWithFormat:@"bytes=%ld-",(unsigned long)_downLoadingOffset]forHTTPHeaderField:@"Range"];
    
    [self.connection cancel];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection setDelegateQueue:[NSOperationQueue currentQueue]];
    [self.connection start];
}

- (void)clearData
{
    [self.connection cancel];
    //移除文件
    [[NSFileManager defaultManager] removeItemAtPath:_tmpPath error:nil];
}

@end
