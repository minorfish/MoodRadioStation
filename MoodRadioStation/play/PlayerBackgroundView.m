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
#import "MRSImageView.h"
#import "UIKitMacros.h"
#import <Masonry/Masonry.h>

@interface PlayerBackgroundView()

@property (nonatomic, strong) UIImage *loadingImage;
@property (nonatomic, strong) UIImage *defaultImage;

@property (nonatomic, strong) MRSImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

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

- (UIImage *)loadingImage
{
    if (!_loadingImage) {
        _loadingImage = [UIImage imageNamed:@"default_photo"];
    }
    return _loadingImage;
}

- (UIImage *)defaultImage
{
    if (!_defaultImage) {
        _defaultImage = [UIImage imageNamed:@"default_photo"];
    }
    return _defaultImage;
}

- (MRSImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[MRSImageView alloc] init];
    }
    return _imageView;
}

- (void)setURLString:(NSString *)URLString
{
    if ([_URLString isEqualToString:URLString])
        return;
    
    _URLString = [URLString copy];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:URLString]
                      placeholderImage:self.loadingImage
                              fallback:self.defaultImage
                               options:SDWebImageRetryFailed
                         progressBlock:nil
                            completion:nil];
}

@end

