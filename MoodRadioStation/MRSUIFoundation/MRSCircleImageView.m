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
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
}

@end
