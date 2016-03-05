//
//  FMInfo.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FMInfo : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) long long ID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, strong) NSString *speak;
@property (nonatomic, strong) NSString *background;
@property (nonatomic, strong) NSString *mediaURL;

@end
