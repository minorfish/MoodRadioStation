//
//  MRSHomeViewController.m
//  MoodRadioStation
//
//  Created by Minor on 16/3/13.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "MRSHomeViewController.h"
#import "MRSFindViewController.h"
#import "MRSIndexViewController.h"
#import "MRSSettingViewController.h"

@interface MRSHomeViewController ()<UITabBarControllerDelegate>

@end

@implementation MRSHomeViewController

- (void)viewDidLoad
{
    MRSIndexViewController *indexBarController = [[MRSIndexViewController alloc] init];
    indexBarController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"主页" image:[UIImage imageNamed:@"nav_index"] selectedImage:[UIImage imageNamed:@"nav_index_act"]];
    
    MRSFindViewController *findBarController = [[MRSFindViewController alloc] init];
    findBarController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现" image:[UIImage imageNamed:@"nav_find"] selectedImage:[UIImage imageNamed:@"nav_find_act"]];
    
    MRSSettingViewController *settingBarController = [[MRSSettingViewController alloc] init];
    settingBarController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"设置" image:[UIImage imageNamed:@"nav_setting"] selectedImage:[UIImage imageNamed:@"nav_setting_act"]];
    
    self.viewControllers = @[indexBarController, findBarController, settingBarController];
    
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"index_first_meng"]];
    self.tabBar.tintColor = [UIColor whiteColor];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
}

# pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSInteger index = tabBarController.selectedIndex;
    [self.navigationController presentViewController:viewController animated:YES completion:^{}];
}

@end
