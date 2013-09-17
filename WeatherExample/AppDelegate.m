//
//  AppDelegate.m
//  WeatherExample
//
//  Created by Ryan Nystrom on 9/2/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import "AppDelegate.h"
#import "WXController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[WXController alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
