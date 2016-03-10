//
//  MRSHotTagADViewController.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/9.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSADViewController.h"

@interface MRSHotTagADViewController : MRSADViewController

@property (nonatomic, strong) void(^didTapWithTag)(NSString *tag);

@end
