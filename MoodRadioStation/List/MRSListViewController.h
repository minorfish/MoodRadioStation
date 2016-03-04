//
//  MRSLIstViewController.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSRefreshHeader;
@class MRSLoadingMoreCell;

@interface MRSListViewController : UITableViewController

@property (nonatomic, strong) MRSRefreshHeader *refreshControll;
@property (nonatomic, strong) MRSLoadingMoreCell *loadigMoreControll;

@end
