//
//  MRSLoaderURLManager.h
//  MoodRadioStation
//
//  Created by Minor on 16/4/12.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MRSRadioRequestTask.h"

@interface MRSLoaderURLManager : NSObject<AVAssetResourceLoaderDelegate>

@property (nonatomic, weak) id<MRSRadioRequestTaskDelegate> delegate;
+ (NSURL *)getSchemeRadioURL:(NSURL *)radioURL;

@end
