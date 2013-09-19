//
//  AppDelegate.m
//  ios-locationtrack
//
//  Created by ozgend on 9/19/13.
//  Copyright (c) 2013 denolk. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "LocationWatcherSingleton.h"
//#import "LocationWatcher.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[LocationWatcherSingleton shared] stopListening];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[LocationWatcherSingleton shared] startListening];
}

@end
