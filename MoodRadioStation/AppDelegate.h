//
//  AppDelegate.h
//  MoodRadioStation
//
//  Created by Minor on 16/2/26.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RadioPlayerViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) RadioPlayerViewController *radioPlayer;

@end

