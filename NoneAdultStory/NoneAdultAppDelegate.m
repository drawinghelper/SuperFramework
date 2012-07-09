//
//  NoneAdultAppDelegate.m
//  NoneAdultStory
//
//  Created by 王 攀 on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NoneAdultAppDelegate.h"

#import "NoneAdultFirstViewController.h"

#import "NoneAdultSecondViewController.h"
#import "NoneAdultMonthTopViewController.h"
#import "NoneAdultWeekTopViewController.h"
#import "NoneAdultSettingViewController.h"

@implementation NoneAdultAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize configContentsource, configVersionForReview;

+(CGColorRef) getColorFromRed:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha
{
    CGFloat r = (CGFloat) red/255.0;
    CGFloat g = (CGFloat) green/255.0;
    CGFloat b = (CGFloat) blue/255.0;
    CGFloat a = (CGFloat) alpha/255.0;  
    CGFloat components[4] = {r,g,b,a};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
	CGColorRef color = (CGColorRef)CGColorCreate(colorSpace, components);
    CGColorSpaceRelease(colorSpace);
	
    return color;
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Updates the device token and registers the token with UA
}

+ (NoneAdultAppDelegate *)sharedAppDelegate
{
    return (NoneAdultAppDelegate *) [UIApplication sharedApplication].delegate;
}

- (NSString *)getConfigContentsource {
    return configContentsource;
}

- (NSString *)getConfigVersionForReview {
    return configVersionForReview;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"wqZfQJvWNjK0zQY7U4G388xJIi4c2C8bOgJXx9Q6"
                  clientKey:@"n8FYn4lelC9FNyshKu1D8hmngdJSYJzKn0H1ZanK"];
    
    //加载各种配置
    //1.服务器接口来源标识
    PFQuery *query = [PFQuery queryWithClassName:@"setting"];
    [query whereKey:@"settingField" equalTo:@"contentsource"];
    NSArray *objects = [query findObjects];
    NSLog(@"Successfully retrieved %d contentsource setting.", objects.count);
    if (objects.count != 0) {
        PFObject *contentsource = [objects objectAtIndex:0];
        configContentsource = [contentsource objectForKey:@"settingValue"];
        NSLog(@"contentsource: %@", configContentsource);
    }
    
    //2.加载当前审核的版本号字段
    query = [PFQuery queryWithClassName:@"setting"];
    [query whereKey:@"settingField" equalTo:@"versionForReview"];
    objects = [query findObjects];
    NSLog(@"Successfully retrieved %d versionForReview setting.", objects.count);
    if (objects.count != 0) {
        PFObject *versionForReview = [objects objectAtIndex:0];
        configVersionForReview = [versionForReview objectForKey:@"settingValue"];
        NSLog(@"configVersionForReview: %@", configVersionForReview);
    }
    
    // Register for notifications
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert)];
    
    
    [MobClick startWithAppkey:@"4fa3232652701556cc00001e" reportPolicy:REALTIME channelId:nil];
    [MobClick checkUpdate];
    [MobClick updateOnlineConfig];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIViewController *newController = [[NoneAdultFirstViewController alloc] initWithNibName:@"NoneAdultFirstViewController" bundle:nil];
    UINavigationController *newNavViewController = [[UINavigationController alloc] initWithRootViewController:newController];
    [newNavViewController.navigationBar setTintColor:[UIColor darkGrayColor]];
    
    UIViewController *historyTopController = [[NoneAdultSecondViewController alloc] initWithNibName:@"NoneAdultSecondViewController" bundle:nil];
    UINavigationController *historyTopNavViewController = [[UINavigationController alloc] initWithRootViewController:historyTopController];
    [historyTopNavViewController.navigationBar setTintColor:[UIColor darkGrayColor]];
   
    UIViewController *monthTopController = [[NoneAdultMonthTopViewController alloc] initWithNibName:@"NoneAdultMonthTopViewController" bundle:nil];
    UINavigationController *monthTopNavViewController = [[UINavigationController alloc] initWithRootViewController:monthTopController];
    [monthTopNavViewController.navigationBar setTintColor:[UIColor darkGrayColor]];
    
    UIViewController *weekTopController = [[NoneAdultWeekTopViewController alloc] initWithNibName:@"NoneAdultWeekTopViewController" bundle:nil];
    UINavigationController *weekTopNavViewController = [[UINavigationController alloc] initWithRootViewController:weekTopController];
    [weekTopNavViewController.navigationBar setTintColor:[UIColor darkGrayColor]];
    
    UIViewController *settingViewController = [[NoneAdultSettingViewController alloc] initWithNibName:@"NoneAdultSettingViewController" bundle:nil];
    UINavigationController *settingNavViewController = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    [settingNavViewController.navigationBar setTintColor:[UIColor darkGrayColor]];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:
                                             newNavViewController, 
                                             historyTopNavViewController,
                                             monthTopNavViewController,
                                             weekTopNavViewController,
                                             settingNavViewController,
                                             nil];
    self.window.rootViewController = self.tabBarController;
    //[NSThread sleepForTimeInterval:2.0];
    [self.window makeKeyAndVisible];
    [Appirater appLaunched:YES];
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
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
