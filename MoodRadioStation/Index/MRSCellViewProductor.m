//
//  MRSCellViewProductor.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/14.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSCellViewProductor.h"
#import "TagListCellItem.h"
#import "RadioInfo.h"
#import "UIKitMacros.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MRSCellViewProductor ()

@property (nonatomic, assign) CGFloat height;

@end

@implementation MRSCellViewProductor

- (UIView *)loadCellView
{
    UIView *view = [[UIView alloc] init];
    TagListCellView *preView = nil;
    
    int i = 0;
    for (RadioInfo *info in self.infoArray) {
        i++;
        TagListCellView *cellView = [[TagListCellView alloc] init];
        cellView.isShowSeperateLine = NO;
        
        [cellView setCellInfoWithCover:info.coverURL Title:info.title Speak:info.speak];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
        [tapGes.rac_gestureSignal subscribeNext:^(id x) {
            if (self.didTap) {
                self.didTap(i - 1, self.infoArray);
            }
        }];
        [cellView addGestureRecognizer:tapGes];
        
        [view addSubview:cellView];
        [cellView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (!preView) {
                make.top.equalTo(view);
            } else {
                make.top.equalTo(preView.mas_bottom);
            }
            make.left.right.equalTo(view);
            make.width.equalTo(@(SCREEN_WIDTH));
            make.height.equalTo(@(74));
            if (i == self.infoArray.count) {
                make.bottom.equalTo(view);
            }
        }];
        preView = cellView;
    }
    self.height = self.infoArray.count * 74;

    return view;
}

@end
