//
//  MRSHotTagInfo.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/9.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface MRSHotTagInfo : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSString *coverURL;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *name;

@end
