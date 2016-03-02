//
//  MRSImageView.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/2.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSImageView.h"
#import "UIKitMacros.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImageManager.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MRSImageView()

@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, strong) id<SDWebImageOperation> operation;
@property (nonatomic, strong) UILabel *statsLabel;
@property (nonatomic, strong) UITapGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) RACDisposable *gestureSubscription;

@end

@implementation MRSImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        const CGFloat labelHeight = 30;
        _statsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (frame.size.height - labelHeight)/2, frame.size.width, labelHeight)];
        _statsLabel.font = Font(12);
        _statsLabel.textColor = HEXCOLOR(0xBCBCBC);
        _statsLabel.text = @"点击加载";
        [self addSubview:_statsLabel];
        [_statsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(@(labelHeight));
        }];
    }
    return self;
}

- (UITapGestureRecognizer *)gestureRecognizer
{
    if (!_gestureRecognizer) {
        _gestureRecognizer = [[UITapGestureRecognizer alloc] init];
        [self addGestureRecognizer:_gestureRecognizer];
    }
    return _gestureRecognizer;
}

- (void)sd_setImageWithURL:(NSURL *)URL
                     placeholderImage:(UIImage *)placeholderImage fallback:(UIImage *)fallbackImage
                   options:(SDWebImageOptions)options
             progressBlock:(SDWebImageDownloaderProgressBlock)progressBlock
                completion:(SDWebImageCompletionBlock)completion
{
    [self.operation cancel];
    self.operation = nil;
    [self.gestureSubscription dispose];
    
    self.statsLabel.hidden = YES;
    self.URL = URL;
    
    // URL为nil，默认set参数中的Image
    if (![[self.URL absoluteString] length]) {
        self.image = fallbackImage;
        return;
    }
    
    @weakify(self);
    SDWebImageCompletionBlock __block recursiveCompletion;
    SDWebImageCompletionBlock completionBlock = ^(UIImage *fallbackImage, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self);
        self.statsLabel.hidden = YES;
        if (error) {
            self.statsLabel.hidden = NO;
            self.image = fallbackImage;
            self.userInteractionEnabled = YES;
            
            [self.gestureSubscription dispose];
            self.gestureSubscription = [[self.gestureRecognizer rac_gestureSignal] subscribeNext:^(id x) {
                @strongify(self);
                [self sd_setImageWithURL:self.URL
                        placeholderImage:placeholderImage
                                fallback:fallbackImage
                                 options:options|SDWebImageRetryFailed
                                progressBlock:nil
                              completion:recursiveCompletion];

            }];
            
        } else {
            if (fallbackImage && [imageURL isEqual:self.URL]) {
                self.userInteractionEnabled = NO;
                self.image = fallbackImage;
                [self setNeedsLayout];
            }
            
            if (completionBlock) {
                completionBlock(fallbackImage, error, cacheType, imageURL);
            }
            
            recursiveCompletion = nil;
        }
    };
    recursiveCompletion = completionBlock;
    
    // getImagefromMemoryOrDiskOrDownload
    NSString *keyURLString = [[SDWebImageManager sharedManager] cacheKeyForURL:URL];
    UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromMemoryCacheForKey:keyURLString];
    if (image) {
        if (completionBlock) {
            completionBlock(image, nil, SDImageCacheTypeMemory, URL);
        }
    } else if ([[SDWebImageManager sharedManager] diskImageExistsForURL:URL]) {
        UIImage *cachedURLImage = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:keyURLString];
        
        if (completionBlock) {
            completionBlock(cachedURLImage, nil, SDImageCacheTypeDisk, URL);
        }
    } else {
        self.image = placeholderImage;
        
        self.operation = [SDWebImageManager.sharedManager
                          downloadImageWithURL:URL
                           options:options
                          progress:progressBlock
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                              @strongify(self);
                              if (!self)
                                  return;
                              if (!error) {
                                  if (completion) {
                                      dispatch_main_sync_safe(^{
                                          completion(image, nil, SDImageCacheTypeNone, imageURL);
                                      });
                                  }
                              }
                          }];
    }
}

@end

