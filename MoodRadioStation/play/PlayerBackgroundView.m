//
//  PlayerBackgroundView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "PlayerBackgroundView.h"

//
//  PlayerBackgrond.m
//  Music Play
//
//  Created by Minor on 16/3/2.
//  Copyright © 2016年 Aries Li. All rights reserved.
//

#import "PlayerBackgroundView.h"
#import "MRSURLImageView.h"
#import "UIKitMacros.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PlayerBackgroundView()

@property (nonatomic, strong) UIImageView *backView;

@end

@implementation PlayerBackgroundView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.backView];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
        [tapGes.rac_gestureSignal subscribeNext:^(id x) {
            if (self.block) {
                self.block();
            }
        }];
        self.backView.userInteractionEnabled = YES;
        [self.backView addGestureRecognizer:tapGes];
        self.imageView.clipsToBounds = YES;
        
        [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self);
            make.edges.equalTo(self);
        }];
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-10);
            make.left.equalTo(self).offset(12);
        }];
        [_backView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self).offset(10);
        }];
    }
    return self;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = Font(14);
        _titleLabel.textColor = HEXCOLOR(0xffffff);
    }
    return _titleLabel;
}

- (MRSURLImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[MRSURLImageView alloc] init];
        _imageView.defaultImage = [UIImage imageNamed:@"default_cover"];
        _imageView.loadingImage = [UIImage imageNamed:@"default_cover"];
    }
    return _imageView;
}

- (UIImageView *)backView
{
    if (!_backView) {
        _backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white_back"]];
    }
    return _backView;
}

@end

