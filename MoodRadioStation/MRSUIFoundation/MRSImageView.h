//
//  MRSImageView.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImageManager.h>

@interface MRSImageView : UIImageView

- (void)sd_setImageWithURL:(NSURL *)URL
                     placeholderImage:(UIImage *)placeholderImage
                  fallback:(UIImage *)fallbackImage
                   options:(SDWebImageOptions)options
             progressBlock:(SDWebImageDownloaderProgressBlock)progressBlock
                completion:(SDWebImageCompletionBlock)completion;

@end
