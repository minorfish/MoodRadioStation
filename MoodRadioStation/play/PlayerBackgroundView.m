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

@implementation PlayerBackgroundView

- (instancetype)initWithFrame:(CGRect)frame Title:(NSString *)titleString
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.imageView];
        [self addSubview:self.titleLabel];
        
        self.imageView.clipsToBounds = YES;
        self.titleLabel.text = titleString;
        
        [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self);
            make.edges.equalTo(self);
        }];
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-10);
            make.left.equalTo(self).offset(12);
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
        _imageView.defaultImage = [UIImage imageNamed:@"default_photo"];
        _imageView.loadingImage = [UIImage imageNamed:@"default_photo"];
    }
    return _imageView;
}

@end

