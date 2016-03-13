//
//  MRSIndexInfo.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface MRSIndexInfo : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSArray *categoryArray;
@property (nonatomic, strong) NSArray *hotfmArray;
@property (nonatomic, strong) NSArray *latestfmArray;
@property (nonatomic, strong) NSArray *lessonArray;

@end
