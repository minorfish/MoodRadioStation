//
//  MRSSearchViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSSearchViewController.h"
#import "UIKitMacros.h"
#import "MRSTextField.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "TagListViewController.h"

@interface MRSSearchViewController () <UITextFieldDelegate>

@property (nonatomic, strong) MRSTextField *searchField;

@end

@implementation MRSSearchViewController

- (void)viewWillAppear:(BOOL)animated
{
    if (self.navigationController.navigationBar.hidden) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

- (void)viewDidLoad
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    [containerView addSubview:self.searchField];
    
    self.navigationItem.titleView = containerView;
    UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (self.navigationController.navigationBar.frame.size.height - 20)/2, 20, 20)];
    backView.image = [UIImage imageNamed:@"back"];
    backView.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
    [tapGes.rac_gestureSignal subscribeNext:^(id x) {
        [self navBack];
    }];
    [backView addGestureRecognizer:tapGes];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
}

- (MRSTextField *)searchField
{
    if (!_searchField) {
        _searchField = [[MRSTextField alloc] initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH - 60, 34)];
        _searchField.borderStyle = UITextBorderStyleRoundedRect;
        _searchField.returnKeyType = UIReturnKeySearch;
        _searchField.enablesReturnKeyAutomatically = YES;
        _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _searchField.placeholder = self.placeholder;
        _searchField.edgeInsets = UIEdgeInsetsMake(0, 26, 0, 12);
       
        _searchField.font = Font(13);
        _searchField.textColor = HEXCOLOR(0x000000);
        
        UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        leftView.image = [UIImage imageNamed:@"find_search_icon"];
        _searchField.leftView = leftView;
        
        _searchField.leftViewMode = UITextFieldViewModeAlways;
        _searchField.leftViewOffsetX = 6;
        
        _searchField.delegate = self;
    }
    return _searchField;
}

- (void)navBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchField resignFirstResponder];
    TagListViewController *vc = [[TagListViewController alloc] initWithRows:@15 KeyString:@"q" KeyValue:self.searchField.text];
    [self.navigationController pushViewController:vc animated:YES];
    return YES;
}

@end
