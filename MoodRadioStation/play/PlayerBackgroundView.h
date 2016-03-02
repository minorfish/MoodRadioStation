//
//  PlayerBackgroundView.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerBackgroundView : UIView

@property (nonatomic, strong) NSString *URLString;

- (instancetype)initWithFrame:(CGRect)frame Title:(NSString *)titleString;

@end
