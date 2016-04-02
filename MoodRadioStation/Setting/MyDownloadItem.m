//
//  MyDownloadItem.m
//  MoodRadioStation
//
//  Created by Minor on 16/4/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MyDownloadItem.h"
#import "RadioInfo.h"
#import "MRSSpeakerInfo.h"
#import "MRSURLImageView.h"
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIKitMacros.h"

@implementation MyDownloadItem

+ (CGFloat)CellHeight
{
    return 74;
}

@end

@interface MyDownloadCellView ()

@property (nonatomic, strong) MRSURLImageView *URLImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *speakLabel;
@property (nonatomic, strong) UIView *seperateLine;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UIImageView *detailView;

@end

@implementation MyDownloadCellView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isShowSeperateLine = YES;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.URLImageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.speakLabel];
        [self.contentView addSubview:self.sizeLabel];
        [self.contentView addSubview:self.detailView];
        [self.contentView addSubview:self.seperateLine];
        [self.contentView setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setItem:(MyDownloadItem *)item
{
    self.URLImageView.URLString = item.radioInfo.coverURL;
    self.titleLabel.text = item.radioInfo.title;
    self.speakLabel.text = [NSString stringWithFormat:@"主播 %@", item.radioInfo.speakerInfo.name];
    self.sizeLabel.text = item.radioInfo.dataSize;
}

- (void)setIsShowSeperateLine:(BOOL)isShowSeperateLine
{
    _isShowSeperateLine = isShowSeperateLine;
    [self.contentView setNeedsLayout];
}

- (void)setCellInfoWithCover:(NSString *)cover Title:(NSString *)title Speak:(NSString *)speak
{
    self.URLImageView.URLString = cover;
    self.titleLabel.text = title;
    self.speakLabel.text = [NSString stringWithFormat:@"主播 %@", speak];
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
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
        make.left.equalTo(self.titleLabel);
    }];
    [_sizeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.speakLabel.mas_bottom).offset(5);
        make.left.equalTo(self.titleLabel);
    }];
    [_detailView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.URLImageView);
        make.width.height.equalTo(@20);
        make.right.equalTo(self.contentView).offset(-12);
    }];
    [_seperateLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        if (_isShowSeperateLine) {
            make.height.equalTo(@0.5);
        } else {
            make.height.equalTo(@0);
        }
        make.left.equalTo(self).offset(12);
        make.bottom.equalTo(self);
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

- (UIView*)seperateLine
{
    if (!_seperateLine) {
        _seperateLine = [[UIView alloc] init];
        _seperateLine.backgroundColor = HEXCOLOR(0xe5e5e5);
    }
    return _seperateLine;
}

- (UILabel *)sizeLabel
{
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] init];
        _sizeLabel.font = Font(13);
        _sizeLabel.textColor = HEXCOLOR(0x999999);
    }
    return _sizeLabel;
}

- (UIImageView *)detailView
{
    if (!_detailView) {
        _detailView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"myDownload_detail_icon"]];
        _detailView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
        [tapGes.rac_gestureSignal subscribeNext:^(id x) {
            self.didTap(self.item.radioInfo.title, self.item.radioInfo.speak, self.item.radioInfo.radioID);
        }];
        [_detailView addGestureRecognizer:tapGes];
    }
    return _detailView;
}

@end
