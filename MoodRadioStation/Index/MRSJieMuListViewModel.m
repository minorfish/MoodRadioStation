//
//  MRSJieMuListViewModel.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/14.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSJieMuListViewModel.h"
#import "MRSJieMuListModel.h"

@interface MRSJieMuListViewModel ()

@property (nonatomic, strong) FMListModel *model;

@end

@implementation MRSJieMuListViewModel {
    MRSJieMuListModel *_jiemuModel;
}

- (instancetype)initWithRows:(NSNumber *)rows KeyString:(NSString *)keyString KeyValue:(NSString *)keyValue
{
    self = [super initWithRows:rows KeyString:keyString KeyValue:keyValue];
    if (self) {
        self.model = [[MRSJieMuListModel alloc] init];
        self.model.offset  = @(0);
        self.model.keyString = keyString;
        self.model.keyValue = keyValue;
        self.model.rows = rows;
    }
    return self;
}

- (FMListModel *)model
{
    return _jiemuModel;
}

- (void)setModel:(MRSJieMuListModel *)model
{
    _jiemuModel = model;
}

@end
