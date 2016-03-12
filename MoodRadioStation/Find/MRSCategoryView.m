//
//  MRSCategoryView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/12.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSCategoryView.h"
#import "UIKitMacros.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MRSCategoryView ()

@property (nonatomic, strong) NSArray *imageArrays;
@property (nonatomic, strong) NSArray *nameArrays;
@property (nonatomic, assign) NSInteger cloumns;

@end

@implementation MRSCategoryView

- (instancetype)initWithFrame:(CGRect)frame
                       Images:(NSArray *)images
                        Names:(NSArray *)names
                      Cloumns:(NSInteger)cloumns
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.imageArrays = images;
        self.nameArrays = names;
        self.cloumns = cloumns;
        
        CGFloat viewWidth = SCREEN_WIDTH / self.cloumns;
        CGFloat viewHeight = viewWidth;
        CGFloat top = 0;
        UIView *view = nil;
        UIImageView *preView = nil;
        for (int i = 0; i < self.imageArrays.count; i++) {
            
            if (i % self.cloumns == 0) {
                if (view) {
                    [self addSubview:view];
                    view = nil;
                }
                view = [[UIView alloc] initWithFrame:CGRectMake(0, top , SCREEN_WIDTH, viewHeight)];
                view.userInteractionEnabled = YES;
                top += viewHeight;
                preView = nil;
            }
            
            UIImageView *indexView = [self createCategoryIndexViewWithIndex:i];
            [view addSubview:indexView];
            [indexView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(view);
                make.width.equalTo(@(viewWidth));
                if (preView) {
                    make.left.equalTo(preView.mas_right);
                } else {
                    make.left.equalTo(view);
                }
            }];
            preView = indexView;
        }
        if (view) {
            [self addSubview:view];
            view = nil;
        }
    }
    return self;
}

- (UIImageView *)createCategoryIndexViewWithIndex:(NSInteger)index
{
    UIImageView *bgView = [[UIImageView alloc] init];
    bgView.image = [UIImage imageNamed:@"index_fm_bg"];
    bgView.userInteractionEnabled = YES;
    
    UIView *view = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor blueColor];
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = [self.nameArrays objectAtIndex:index];
        nameLabel.font = Font(14);
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [self.imageArrays objectAtIndex:index];
        
        [view addSubview:nameLabel];
        [view addSubview:imageView];
        
        [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.equalTo(view);
            make.height.width.equalTo(@30);
        }];
        [nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).offset(10);
            make.left.right.equalTo(view);
            make.bottom.equalTo(view);
        }];
        view;
    });
    
    [bgView addSubview:view];
    [view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bgView);
    }];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
    [tapGes.rac_gestureSignal subscribeNext:^(id x) {
        if (self.didTag) {
            self.didTag([self.nameArrays objectAtIndex:index]);
        }
    }];
    [bgView addGestureRecognizer:tapGes];
    
    return bgView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%@", self);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    return view;
}
@end
