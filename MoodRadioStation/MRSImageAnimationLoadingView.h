//
//  MRSImageAnimationLoadingView.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSImageAnimationLoadingView : UIView

+ (MRSImageAnimationLoadingView *)loadingViewByView:(UIView *)showView;

- (void)startAnimation;
- (void)stopAnimation;

@end
