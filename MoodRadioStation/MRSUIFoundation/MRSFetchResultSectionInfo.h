//
//  MRSFetchResultSectionInfo.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/6.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MRSFetchResultSectionInfo <NSObject>

@property (nonatomic, readonly) NSArray *objects;
@property (nonatomic, readonly) NSUInteger numberOfObject;

@end

@interface MRSFetchResultSectionInfo : NSObject<MRSFetchResultSectionInfo>

- (instancetype)initWithArray:(NSArray *)array;

@end
