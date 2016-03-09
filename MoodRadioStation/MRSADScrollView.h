//
//  MRSADScrollerView.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/9.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRSADScrollView;

@protocol MRSADScrollerViewDelegate <NSObject>

@optional
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

@end

@protocol MRSADScrollerViewDataSource <NSObject>

- (NSInteger)pageCountForScrollView:(MRSADScrollView *)scrollView;
- (UIView *)pageAtIndex:(NSInteger)index forScrollView:(MRSADScrollView *)scrollView;

@end

@interface MRSADScrollView : UIScrollView<UIScrollViewDelegate> {
    NSInteger _total;
}

@property (nonatomic, assign) id<MRSADScrollerViewDelegate> ADDelegate;
@property (nonatomic, assign) id<MRSADScrollerViewDataSource> ADDataSource;

@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, assign) NSInteger currentIndex;

- (void)scrollToNextPage;

@end
