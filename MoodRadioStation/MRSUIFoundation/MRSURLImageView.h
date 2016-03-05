//
//  MRSURLImageView.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/5.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSImageView.h"

@interface MRSURLImageView : MRSImageView

@property (nonatomic, strong) NSString *URLString;
@property (nonatomic, strong) UIImage *loadingImage;
@property (nonatomic, strong) UIImage *defaultImage;

@end
