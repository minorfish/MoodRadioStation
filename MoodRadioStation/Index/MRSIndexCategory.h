//
//  MRSIndexCategory.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface MRSIndexCategory : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) NSInteger ID;
@property (nonatomic, strong) NSString *coverURL;
@property (nonatomic, strong) NSString *name;

@end
