//
//  MRSRadioRequestTask.h
//  MoodRadioStation
//
//  Created by Minor on 16/4/12.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRSRadioRequestTask;

@protocol MRSRadioRequestTaskDelegate <NSObject>

- (void)task:(MRSRadioRequestTask *)task didReceiveRadioLength:(NSUInteger)radioLength mimeType:(NSString *)mimeType;
- (void)didReceiveRadioDataWithTask:(MRSRadioRequestTask *)task;
- (void)didFinishLoadingWithTask:(MRSRadioRequestTask *)task;
- (void)didFailLoadingWithTask:(MRSRadioRequestTask *)task WithError:(NSInteger )errorCode;

@end

@interface MRSRadioRequestTask : NSObject

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) NSUInteger offset;
@property (nonatomic, readonly) NSUInteger radioLength;
@property (nonatomic, readonly) NSUInteger downLoadingOffset;
@property (nonatomic, readonly) NSString *mimeType;
@property (nonatomic, readonly) BOOL isFinishLoad;
@property (nonatomic, weak) id <MRSRadioRequestTaskDelegate> delegate;

- (void)setUrl:(NSURL *)url offset:(NSUInteger)offset;

@end
