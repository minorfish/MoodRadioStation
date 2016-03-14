//
//  MRSHotFmView.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/14.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSHotFmViewProductor : UIView

@property (nonatomic, strong) NSArray *infoArray;
@property (nonatomic, copy) void (^didTap)(NSInteger index, NSArray *array);
@property (nonatomic, assign) NSInteger cloumn;
@property (nonatomic, readonly) CGFloat height;

- (UIView *)loadHotFmView;

@end
