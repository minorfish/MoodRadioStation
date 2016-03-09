//
//  MRSADScrollViewController.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/9.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSADViewController : UIViewController

@property (nonatomic, assign) NSInteger flagID;

- (void)loadADView:(NSInteger)flagID finished:(void (^)(UIView *view))finished;
- (void)stopTimer;
- (void)startTimer;

@end
