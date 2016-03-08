//
//  MRSNoContentView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/8.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSNoContentView.h"
#import "UIKitMacros.h"
#import <Masonry/Masonry.h>

@interface MRSNoContentView()

@property (nonatomic, strong) UIImageView *noContentImageView;
@property (nonatomic, strong) UILabel *noContentLabel;

@end

@implementation MRSNoContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        UIView *view = [[UIView alloc] initWithFrame:frame];
        view.backgroundColor = [UIColor clearColor];
        [view addSubview:self.noContentLabel];
        [view addSubview:self.noContentImageView];
        [view addSubview:self.refreshBtn];
        [self addSubview:view];
        
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        [_noContentImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(view);
            make.centerX.equalTo(view);
        }];
        [_noContentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.noContentImageView.mas_bottom).offset(10);
            make.centerX.equalTo(self.noContentImageView);
        }];
        [_refreshBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.noContentLabel.mas_bottom).offset(30);
            make.centerX.equalTo(self.noContentLabel);
            make.bottom.equalTo(view);
        }];
    }
    return self;
}

- (UIImageView *)noContentImageView
{
    if (!_noContentImageView) {
        _noContentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_content_image"]];
    }
    return _noContentImageView;
}

- (UILabel *)noContentLabel
{
    if (!_noContentLabel) {
        _noContentLabel = [[UILabel alloc] init];
        _noContentLabel.font = Font(12);
        _noContentLabel.textColor = HEXCOLOR(0x999999);
        _noContentLabel.text = @"什么都没找到。。。";
    }
    return _noContentLabel;
}

- (UIButton *)refreshBtn
{
    if (!_refreshBtn) {
        _refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
        _refreshBtn.userInteractionEnabled = YES;
        [_refreshBtn setBackgroundColor:[UIColor clearColor]];
        _refreshBtn.layer.masksToBounds = YES;
        
        [_refreshBtn setTitle:@"点击刷新" forState:UIControlStateNormal];
        [_refreshBtn setTitleColor:HEXCOLOR(0x666666) forState:UIControlStateNormal];
        
        _refreshBtn.layer.borderColor = HEXCOLOR(0x666666).CGColor;
        _refreshBtn.layer.cornerRadius = 5;
        _refreshBtn.layer.borderWidth = 1;
        
        _refreshBtn.contentEdgeInsets = UIEdgeInsetsMake(5, 20, 5, 20);
        
        _refreshBtn.titleLabel.font = Font(12);
        _refreshBtn.titleLabel.text = @"点击刷新";
        _refreshBtn.titleLabel.textColor = HEXCOLOR(0x666666);
    }
    return _refreshBtn;
}

@end
