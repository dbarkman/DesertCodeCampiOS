//
//  DCCAppDelegate.m
//  DesertCodeCamp
//
//  Created by David Barkman on 10/21/12.
//  Copyright (c) 2012 RealSimpleApps. All rights reserved.
//

#import "DCCAppDelegate.h"
#import "Flurry.h"
#import "TracksViewController.h"
#import "MySessionsViewController.h"
#import "MyScheduleViewController.h"

@implementation DCCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[Flurry startSession:@"HN3K9PGV7HXR2DD9X38K"];
	
	NSString *shortName = @"nov2012";
	NSString *campId = @"5";
	NSString *getSessionsByCampIdURL = @"http://desertcodecamp.com/Services/Session.svc/GetSessionsByCampId?campId=%@";
	NSString *getMyPresentationsByLoginURL = @"http://desertcodecamp.com/Services/Session.svc/GetMyPresentationsByLogin?login=%@&shortName=%@";
	NSString *getMyInterestedInSessionsByLoginURL = @"http://desertcodecamp.com/Services/Session.svc/GetMyInterestedInSessionsByLogin?login=%@&shortName=%@";
	
	[[NSUserDefaults standardUserDefaults] setObject:shortName forKey:@"shortName"];
	[[NSUserDefaults standardUserDefaults] setObject:campId forKey:@"campId"];
	[[NSUserDefaults standardUserDefaults] setObject:getSessionsByCampIdURL forKey:@"getSessionsByCampIdURL"];
	[[NSUserDefaults standardUserDefaults] setObject:getMyPresentationsByLoginURL forKey:@"getMyPresentationsByLoginURL"];
	[[NSUserDefaults standardUserDefaults] setObject:getMyInterestedInSessionsByLoginURL forKey:@"getMyInterestedInSessionsByLoginURL"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	TracksViewController *tracksViewController = [[TracksViewController alloc] init];
	[tracksViewController setUrl:[NSString stringWithFormat:getSessionsByCampIdURL, campId]];
	[tracksViewController setFilterType:0];
	[tracksViewController setTitle:@"All Sessions"];
	
	MySessionsViewController *mySessionsViewController = [[MySessionsViewController alloc] init];
	[mySessionsViewController setFilterType:0];
	[mySessionsViewController setTitle:@"My Sessions"];
	
	MyScheduleViewController *myScheduleViewController = [[MyScheduleViewController alloc] init];
	[myScheduleViewController setTitle:@"My Schedule"];
	
	UIColor *dccOrange = [UIColor colorWithRed:221/255.0f green:72/255.0f blue:20/255.0f alpha:1];
	NSData *dccOrangeData = [NSKeyedArchiver archivedDataWithRootObject:dccOrange];
	[[NSUserDefaults standardUserDefaults] setObject:dccOrangeData forKey:@"dccOrange"];

	UINavigationController *navController0 = [[UINavigationController alloc] initWithRootViewController:tracksViewController];
	[navController0.navigationBar setTintColor:dccOrange];
	
	[navController0 setToolbarHidden:NO];
	[navController0.toolbar setTintColor:dccOrange];
	
	UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:mySessionsViewController];
	[navController1.navigationBar setTintColor:dccOrange];
	
	[navController1 setToolbarHidden:NO];
	[navController1.toolbar setTintColor:dccOrange];
	
	UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:myScheduleViewController];
	[navController2.navigationBar setTintColor:dccOrange];
	
	[navController2 setToolbarHidden:NO];
	[navController2.toolbar setTintColor:dccOrange];
	
	UITabBarController *tabBarController = [[UITabBarController alloc] init];
	NSArray *viewControllers = [NSArray arrayWithObjects:navController0, navController1, navController2, nil];
	[tabBarController setViewControllers:viewControllers];
	
	[[self window] setRootViewController:tabBarController];
	
	self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
