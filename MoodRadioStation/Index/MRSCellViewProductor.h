//
//  MRSCellViewProductor.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/14.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSCellViewProductor : UIView

@property (nonatomic, strong) NSArray *infoArray;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, copy) void(^didTap)(NSInteger index, NSArray *array);

- (UIView *)loadCellView;

@end
