//
//  MRSCircleImageView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/8.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSCircleImageView.h"

@implementation MRSCircleImageView

- (void)setURLString:(NSString *)URLString
{
    [super setURLString:URLString];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 30;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1;
}

@end
