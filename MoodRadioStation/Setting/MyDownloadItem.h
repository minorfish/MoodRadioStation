//
//  MyDownloadItem.h
//  MoodRadioStation
//
//  Created by Minor on 16/4/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RadioInfo;

@interface MyDownloadItem : NSObject

@property (nonatomic, strong) RadioInfo *radioInfo;

+ (CGFloat)CellHeight;

@end

@interface MyDownloadCellView : UITableViewCell

@property (nonatomic, strong) MyDownloadItem *item;
@property (nonatomic, assign) BOOL isShowSeperateLine;
@property (nonatomic, copy) void(^didTap)(NSString *title, NSString *speaker, long long ID);

- (void)setCellInfoWithCover:(NSString *)cover Title:(NSString *)title Speak:(NSString *)speak DataSize:(NSString *)dataSize;

@end
