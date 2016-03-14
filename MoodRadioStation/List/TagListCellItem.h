//
//  TagListCellItem.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/5.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class FMInfo;

@interface TagListCellItem : NSObject

@property (nonatomic, strong) FMInfo *fmInfo;

+ (CGFloat)CellHeight;

@end

@interface TagListCellView : UITableViewCell

@property (nonatomic, strong) TagListCellItem *item;
@property (nonatomic, assign) BOOL isShowSeperateLine;

- (void)setCellInfoWithCover:(NSString *)cover Title:(NSString *)title Speak:(NSString *)speak;

@end
