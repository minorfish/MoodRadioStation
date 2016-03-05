//
//  FMListViewModel.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/5.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACCommand;

@interface FMListViewModel : NSObject

@property (nonatomic, strong) RACCommand *refreshListCommand;

@property (nonatomic, strong, readonly) NSArray *infoArray;

- (instancetype)initWithRows:(NSNumber *)rows Tag:(NSString *)tag;

@end
