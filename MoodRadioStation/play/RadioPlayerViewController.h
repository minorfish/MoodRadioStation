//
//  RadioPlayerViewController.h
//  MoodRadioStation
//
//  Created by Minor on 16/2/27.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadioPlayerViewController : UIViewController

@property (nonatomic, strong) NSNumber *isPlaying;
@property (nonatomic, strong) NSNumber *currentFMIndex;
@property (nonatomic, strong) NSMutableArray *requestFMInfoArray;

- (instancetype)initWithKeyString:(NSString *)keyString KeyVale:(NSString *)keyValue Rows:(NSNumber *)rows;

@end
