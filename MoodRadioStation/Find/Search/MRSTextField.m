//
//  MRSTextField.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSTextField.h"

@implementation MRSTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
//    self.background = [[UIImage alloc] init];
    self.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
    _leftViewOffsetX = 15;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(_edgeInsets.left, _edgeInsets.top, bounds.size.width - _edgeInsets.left - _edgeInsets.right, bounds.size.height - _edgeInsets.top - _edgeInsets.bottom);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(_edgeInsets.left, _edgeInsets.top, bounds.size.width - _edgeInsets.left - _edgeInsets.right, bounds.size.height - _edgeInsets.top - _edgeInsets.bottom);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    return CGRectMake(_leftViewOffsetX, (self.frame.size.height - self.leftView.frame.size.height)/2, self.leftView.frame.size.width, self.leftView.frame.size.height);
}

@end
