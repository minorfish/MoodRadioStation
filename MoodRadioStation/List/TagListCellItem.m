//
//  TagListCellItem.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/5.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "TagListCellItem.h"
#import "MRSURLImageView.h"
#import "UIKitMacros.h"
#import "FMInfo.h"
#import <Masonry/Masonry.h>

@implementation TagListCellItem

+ (CGFloat)CellHeight
{
    return 74;
}

@end

@interface TagListCellView()

@property (nonatomic, strong) MRSURLImageView *URLImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *speakLabel;

@end

@implementation TagListCellView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.URLImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.speakLabel];
        [self.contentView setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setItem:(TagListCellItem *)item
{
    self.URLImageView.URLString = item.fmInfo.cover;
    self.titleLabel.text = item.fmInfo.title;
    self.speakLabel.text = [NSString stringWithFormat:@"主播 %@", item.fmInfo.speak];
}

- (void)updateConstraints
{
    [super updateConstraints];
    [_URLImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@50);
        make.left.top.equalTo(self.contentView).offset(12);
        make.bottom.equalTo(self.contentView).offset(-12);
    }];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.URLImageView);
        make.left.equalTo(self.URLImageView.mas_right).offset(10);
        make.right.lessThanOrEqualTo(self.contentView).offset(-12);
    }];
    [_speakLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.left.equalTo(self.titleLabel);
    }];
}

- (MRSURLImageView *)URLImageView
{
    if (!_URLImageView) {
        _URLImageView = [[MRSURLImageView alloc] init];
        _URLImageView.defaultImage = [UIImage imageNamed:@"list_default"];
        _URLImageView.loadingImage = [UIImage imageNamed:@"list_default"];
    }
    return _URLImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = Font(14);
        _titleLabel.textColor = HEXCOLOR(0x666666);
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLabel;
}

- (UILabel *)speakLabel
{
    if (!_speakLabel) {
        _speakLabel = [[UILabel alloc] init];
        _speakLabel.font = Font(13);
        _speakLabel.textColor = HEXCOLOR(0x999999);
    }
    return _speakLabel;
}

@end
