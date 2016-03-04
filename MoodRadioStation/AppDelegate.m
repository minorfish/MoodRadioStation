//
//  AppDelegate.m
//  MoodRadioStation
//
//  Created by Minor on 16/2/26.
//  Copyright © 2016年 Minor. All rights reserved.
//

#import "AppDelegate.h"
#import "RadioPlayerViewController.h"
#import <hpple/TFHpple.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    NSString *baseURL = @"http://fm.xinli001.com";
//    NSString *URL = @"/fragment?t=1456462608428&n=place";
//    
//    NSURLSessionConfiguration *defaultSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:
//                             [NSURL URLWithString:URL relativeToURL:[NSURL URLWithString:baseURL]]];
//    
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultSessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//    
//    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSString *newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"data%@", newStr);
//        
//    TFHpple * doc = [[TFHpple alloc] initWithHTMLData:data];
//    TFHppleElement *elements = [doc peekAtSearchWithXPathQuery:@"//div"];
//    
//    for (TFHppleElement *e in [elements children]) {
//        if ([e objectForKey:@"class"] && [e text]) {
//            NSLog(@"%@ %@\n", [e objectForKey:@"class"], [e text]);
//        }
//    }
//        
//    }] resume];
    
    
    
    RadioPlayerViewController *playViewContoller = [[RadioPlayerViewController alloc] initWithRadioID:@(99388843)];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = playViewContoller;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
