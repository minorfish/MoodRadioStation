//
//  MRSPlayerImageAnimationLoadingView.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/8.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSPlayerImageAnimationLoadingView : UIView

@property (nonatomic, readonly) BOOL isAnimating;

- (void)setImagesArray:(NSArray *)imagesArray;
- (void)setAnimationDuration:(NSTimeInterval)animationDuration;
- (void)setAnimationRepeatCount:(NSInteger)animationRepeatCount;

- (void)startAnimation;
- (void)stopAnimation;

@end
