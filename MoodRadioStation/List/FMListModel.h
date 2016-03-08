//
//  FMListModel.h
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSModel.h"
@class AFHTTPRequestOperation;
@class  RACSignal;

@interface FMListModel : MRSModel

@property (nonatomic, strong) NSNumber *rows;
@property (nonatomic, strong) NSNumber *offset;
@property (nonatomic, strong) NSString *keyString;
@property (nonatomic, strong) NSString *keyValue;

@property (nonatomic, strong) RACSignal *refreshList;

@end
