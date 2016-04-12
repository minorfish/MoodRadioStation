//
//  MRSURLImageView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/5.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSURLImageView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation MRSURLImageView

- (void)setURLString:(NSString *)URLString
{
    if ([_URLString isEqualToString:URLString])
        return;
    
    _URLString = [URLString copy];
    
    @weakify(self);
    [self sd_setImageWithURL:[NSURL URLWithString:URLString]
                      placeholderImage:self.loadingImage
                              fallback:self.defaultImage
                               options:SDWebImageRetryFailed
                         progressBlock:nil
                        completion:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            @strongify(self);
                            self.image = image;
                        }];
}

@end
