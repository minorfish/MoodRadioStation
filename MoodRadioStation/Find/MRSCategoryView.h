//
//  MRSCategoryView.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/12.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSCategoryView : UIView

@property (nonatomic, copy) void(^didTag)(NSString *tagString);

- (instancetype)initWithFrame:(CGRect)frame
                       Images:(NSArray *)images
                        Names:(NSArray *)names
                      Cloumns:(NSInteger)cloumns;

@end
