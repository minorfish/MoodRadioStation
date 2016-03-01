//
//  Radio.h
//  MoodRadioStation
//
//  Created by Minor on 16/2/27.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface RadioInfo : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger radioID;
@property (nonatomic, strong) NSString *coverURL;
@property (nonatomic, strong) NSString *speak;
@property (nonatomic, strong) NSString *URL;
@property (nonatomic, strong) NSString *radiodDesc;

@end
