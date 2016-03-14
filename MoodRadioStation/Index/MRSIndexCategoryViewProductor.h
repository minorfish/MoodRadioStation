//
//  MRSIndexCategoryView.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/14.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSIndexCategoryViewProductor : UIView

@property (nonatomic, strong) NSArray *infoArray;
@property (nonatomic, assign) NSInteger cloumn;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, copy) void (^didTap)(NSInteger categoryID, NSString *name);

- (UIView *)loadCategoryView;

@end
