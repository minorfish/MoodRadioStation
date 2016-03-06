//
//  MRSSpeakerInfo.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/6.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface MRSSpeakerInfo : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) long long ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, assign) NSInteger fmNum;

@end
