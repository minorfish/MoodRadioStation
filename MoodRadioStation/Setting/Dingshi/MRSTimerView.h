//
//  MRSTimerView.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/15.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSTimerView : UIView

@property (nonatomic, copy) void (^didTap)(NSTimeInterval time);

- (instancetype)initWithTimeArray:(NSArray *)timeArray;

@end
