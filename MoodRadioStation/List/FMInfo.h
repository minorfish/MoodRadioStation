//
//  FMInfo.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FMInfo : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) long long pkID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *speakName;

@end
