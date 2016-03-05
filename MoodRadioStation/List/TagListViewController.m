//
//  MoodCategoryListViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/4.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "TagListViewController.h"
#import "MRSRefreshHeader.h"
#import "MRSLoadingMoreCell.h"
#import "UIKitMacros.h"
#import "FMListViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "TagListCellItem.h"
#import "MRSImageAnimationLoadingView.h"

@interface TagListViewController()

@property (nonatomic, strong) FMListViewModel *viewModel;
@property (nonatomic, strong) NSString *tag;

@property (nonatomic, strong) UIView *noContentView;

@end

@implementation TagListViewController

- (instancetype)initWithRows:(NSNumber *)rows Tag:(NSString *)tag
{
    self = [super init];
    if (self) {
        _viewModel = [[FMListViewModel alloc] initWithRows:rows Tag:tag];
        _tag = tag;
    }
    return self;
}

- (void)viewDidLoad
{
    [self bind];
    
    self.refreshControll = [[MRSRefreshHeader alloc] initWithFrame:CGRectMake(0, -30, SCREEN_WIDTH, 30) RefreshView:self.tableView];
    CGFloat top = self.tableView.frame.origin.y + self.tableView.frame.size.height;
    self.loadigMoreControll = [[MRSLoadingMoreCell alloc] initWithFrame:CGRectMake(0, top, SCREEN_WIDTH, 30) RefreshView:self.tableView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.navigationItem.title = self.tag;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
   }

- (void)refresh
{
    self.tableView.userInteractionEnabled = NO;
    @weakify(self);
    [[[[self.viewModel refreshListCommand] execute:@(YES)] deliverOnMainThread]
     subscribeNext:^(id x) {
         @strongify(self)
         [self.refreshControll stopRefreshing];
         [self.tableView reloadData];
         self.tableView.userInteractionEnabled = YES;
     }];
}

- (void)bind
{
    
}

#pragma mark - tableViewDelete
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TagListCellItem CellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - tableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel.infoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > [self.viewModel.infoArray count])
        return nil;
    
    TagListCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"TagListCellView"];
    if (!cell) {
        cell = [[TagListCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TagListCellView"];
        ;
    }
    TagListCellItem *item = [[TagListCellItem alloc] init];
    item.fmInfo = [self.viewModel.infoArray objectAtIndex:indexPath.row];
    cell.item = item;
    return cell;
}

@end
