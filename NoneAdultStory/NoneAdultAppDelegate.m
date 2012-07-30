//
//  NoneAdultAppDelegate.m
//  NoneAdultStory
//
//  Created by 王 攀 on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NoneAdultAppDelegate.h"
#import "NewCommonViewController.h"
#import "NewWeiboViewController.h"
#import "NewPathViewController.h"
#import "HistoryPathViewController.h"

#import "ChannelViewController.h"
#import "CollectedViewController.h"
#import "RootViewController.h"
#import "NoneAdultSettingViewController.h"

@implementation NoneAdultAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void) animateSplashScreen
{
    
    //fade time
    CFTimeInterval animation_duration = 1.0;
    
    //SplashScreen 
    UIImageView * splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)];
    splashView.image = [UIImage imageNamed:@"Default.png"];
    [self.window addSubview:splashView];
    [self.window bringSubviewToFront:splashView];
    
    //Animation (fade away with zoom effect)
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animation_duration];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.window cache:YES];
    [UIView setAnimationDelegate:splashView]; 
    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
    splashView.alpha = 0.0;
    splashView.frame = CGRectMake(-60, -60, 440, 600);
    
    [UIView commitAnimations];
    
}

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
- (void)application:(UIApplication *)application 
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    [PFPush storeDeviceToken:newDeviceToken]; // Send parse the device token
    // Subscribe this user to the broadcast channel, "" 
    [PFPush subscribeToChannelInBackground:@"" block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Successfully subscribed to the broadcast channel.");
        } else {
            NSLog(@"Failed to subscribe to the broadcast channel.");
        }
    }];
}

+ (NoneAdultAppDelegate *)sharedAppDelegate
{
    return (NoneAdultAppDelegate *) [UIApplication sharedApplication].delegate;
}

-(NSString *)getDbPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSString *documentDirectory = [paths objectAtIndex:0];  
    //dbPath： 数据库路径，在Document中。  
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"NeiHanStoryTencent.db"];  
    NSLog(@"dbPath: %@", dbPath);
    return dbPath;
}

- (void)createDingTable {
    FMDatabase *db= [FMDatabase databaseWithPath:[self getDbPath]] ;  
    if (![db open]) {  
        NSLog(@"Could not open db."); 
        return ;  
    }
    
    //[db executeUpdate:@"DROP TABLE collected"];
    
    //创建一个名为User的表，有两个字段分别为string类型的Name，integer类型的 Age
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS ding (";
	createSQL = [createSQL stringByAppendingString:@" ID INTEGER PRIMARY KEY AUTOINCREMENT,"];
    
    createSQL = [createSQL stringByAppendingString:@" weiboId INTEGER UNIQUE,"];//微博的id
	createSQL = [createSQL stringByAppendingString:@" profile_image_url TEXT,"];//博主头像图片地址
    createSQL = [createSQL stringByAppendingString:@" screen_name TEXT,"];//微博名
    createSQL = [createSQL stringByAppendingString:@" timestamp INTEGER,"];//微博发表时间
    
	createSQL = [createSQL stringByAppendingString:@" content TEXT,"];//文字内容
    createSQL = [createSQL stringByAppendingString:@" large_url TEXT,"];//图片内容
    createSQL = [createSQL stringByAppendingString:@" width INTEGER,"];//图片宽度
    createSQL = [createSQL stringByAppendingString:@" height INTEGER,"];//图片高度
    createSQL = [createSQL stringByAppendingString:@" gif_mark INTEGER,"];//图片是否为gif，0为不是gif，1是gif
    
    createSQL = [createSQL stringByAppendingString:@" favorite_count INTEGER,"];
    createSQL = [createSQL stringByAppendingString:@" bury_count INTEGER,"];//
    createSQL = [createSQL stringByAppendingString:@" comments_count INTEGER,"];//
    
    createSQL = [createSQL stringByAppendingString:@" collect_time INTEGER"];
    createSQL = [createSQL stringByAppendingString:@");"];
    
    [db executeUpdate:createSQL];
    
}

- (void)createCollectTable {
    FMDatabase *db= [FMDatabase databaseWithPath:[self getDbPath]] ;  
    if (![db open]) {  
        NSLog(@"Could not open db."); 
        return ;  
    }
    
    //[db executeUpdate:@"DROP TABLE collected"];

    //创建一个名为User的表，有两个字段分别为string类型的Name，integer类型的 Age
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS collected (";
	createSQL = [createSQL stringByAppendingString:@" ID INTEGER PRIMARY KEY AUTOINCREMENT,"];

    createSQL = [createSQL stringByAppendingString:@" weiboId INTEGER UNIQUE,"];//微博的id
	createSQL = [createSQL stringByAppendingString:@" profile_image_url TEXT,"];//博主头像图片地址
    createSQL = [createSQL stringByAppendingString:@" screen_name TEXT,"];//微博名
    createSQL = [createSQL stringByAppendingString:@" timestamp INTEGER,"];//微博发表时间
    
	createSQL = [createSQL stringByAppendingString:@" content TEXT,"];//文字内容
    createSQL = [createSQL stringByAppendingString:@" large_url TEXT,"];//图片内容
    createSQL = [createSQL stringByAppendingString:@" width INTEGER,"];//图片宽度
    createSQL = [createSQL stringByAppendingString:@" height INTEGER,"];//图片高度
    createSQL = [createSQL stringByAppendingString:@" gif_mark INTEGER,"];//图片是否为gif，0为不是gif，1是gif

    createSQL = [createSQL stringByAppendingString:@" favorite_count INTEGER,"];
    createSQL = [createSQL stringByAppendingString:@" bury_count INTEGER,"];//
    createSQL = [createSQL stringByAppendingString:@" comments_count INTEGER,"];//
    
    createSQL = [createSQL stringByAppendingString:@" collect_time INTEGER"];
    createSQL = [createSQL stringByAppendingString:@");"];

    [db executeUpdate:createSQL];
    
}

- (NSString *)getMogoAppKey {
    NSDictionary *appConfig = [[NSDictionary alloc] initWithContentsOfFile:
                               [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"plist"]];
    return [appConfig objectForKey:@"MoGoAppKey"];
}

- (NSString *)getUmengAppKey {
    NSDictionary *appConfig = [[NSDictionary alloc] initWithContentsOfFile:
                               [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"plist"]];
    return [appConfig objectForKey:@"UmengAppKey"];
}

- (NSString *)getNewTabCid {
    NSDictionary *appConfig = [[NSDictionary alloc] initWithContentsOfFile:
                               [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"plist"]];
    return [appConfig objectForKey:@"NewTabCid"];
}

- (NSString *)getAppStoreId {
    NSDictionary *appConfig = [[NSDictionary alloc] initWithContentsOfFile:
                               [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"plist"]];
    return [appConfig objectForKey:@"AppStoreId"];
}

- (NSString *)getAppChannelTag {
    NSDictionary *appConfig = [[NSDictionary alloc] initWithContentsOfFile:
                               [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"plist"]];
    return [appConfig objectForKey:@"AppChannelTag"];
}

- (NSString *)getAlertKeyword {
    NSDictionary *appConfig = [[NSDictionary alloc] initWithContentsOfFile:
                               [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"plist"]];
    return [appConfig objectForKey:@"AlertKeyword"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *appConfig = [[NSDictionary alloc] initWithContentsOfFile:
                               [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"plist"]];
    NSDictionary *parseConfig = [appConfig objectForKey:@"ParseConfig"]; 
    [Parse setApplicationId:[parseConfig objectForKey:@"applicationId"]
                  clientKey:[parseConfig objectForKey:@"clientKey"]];
    
    // Set defualt ACLs
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Register for notifications
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert)];
    
    [MobClick startWithAppkey:[[NoneAdultAppDelegate sharedAppDelegate] getUmengAppKey] reportPolicy:REALTIME channelId:[[NoneAdultAppDelegate sharedAppDelegate] getAppChannelTag]];
    [MobClick checkUpdate];
    [MobClick updateOnlineConfig];
    
    [self createDingTable];
    [self createCollectTable];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    UIViewController *newCommonViewController = [[NewCommonViewController alloc] 
                                                 initWithNibName:@"NewCommonViewController" 
                                                 bundle:nil 
                                                 withTitle:@"最新" 
                                                 withCid:[[NoneAdultAppDelegate sharedAppDelegate] getNewTabCid]];
    UINavigationController *newCommonNavViewController = [[UINavigationController alloc] initWithRootViewController:newCommonViewController];
    
    UIViewController *newWeiboViewController = [[NewWeiboViewController alloc] initWithNibName:@"NewWeiboViewController" bundle:nil withTitle:@"微博"];
    UINavigationController *newWeiboNavViewController = [[UINavigationController alloc] initWithRootViewController:newWeiboViewController];
    
    UIViewController *newPathViewController = [[NewPathViewController alloc] init];
    UINavigationController *newPathNavViewController = [[UINavigationController alloc] initWithRootViewController:newPathViewController];
    
    HistoryPathViewController *historyTopController = [[HistoryPathViewController alloc] init];
    UINavigationController *historyTopNavViewController = [[UINavigationController alloc] initWithRootViewController:historyTopController];
    
    ChannelViewController *channelController = [[ChannelViewController alloc] init];
    UINavigationController *channelNavViewController = [[UINavigationController alloc] initWithRootViewController:channelController];
    
    UIViewController *collectViewController = [[CollectedViewController alloc] initWithNibName:@"CollectedViewController" bundle:nil withTitle:@"收藏"];
    UINavigationController *collectNavViewController = [[UINavigationController alloc] initWithRootViewController:collectViewController];
    [collectNavViewController.navigationBar setTintColor:[UIColor darkGrayColor]];

    //Gallery形式的收藏
    UIViewController *collectGalleryViewController = [[RootViewController alloc] init];
    UINavigationController *collectGalleryNavViewController = [[UINavigationController alloc] initWithRootViewController:collectGalleryViewController];
    [collectGalleryNavViewController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    //[collectGalleryNavViewController.navigationBar setTintColor:[UIColor darkGrayColor]];
    
    UIViewController *settingViewController = [[NoneAdultSettingViewController alloc] initWithNibName:@"NoneAdultSettingViewController" bundle:nil];
    UINavigationController *settingNavViewController = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    [settingNavViewController.navigationBar setTintColor:[UIColor darkGrayColor]];
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    NSString *showFilteredNew = [MobClick getConfigParams:@"showFilteredNew"];
    if (showFilteredNew == nil || showFilteredNew == [NSNull null]  || [showFilteredNew isEqualToString:@""]) {
        showFilteredNew = @"YES";
    }
    
    NSString *showChannel = [MobClick getConfigParams:@"showChannel"];
    if (showChannel == nil || showChannel == [NSNull null]  || [showChannel isEqualToString:@""]) {
        showChannel = @"NO";
    }
    
    //为过审和推广初期内容高质量，只显示精选；之后可以显示未精选过的最新笑话
    PFUser *user = [PFUser currentUser];
    if (user && [user.username isEqualToString:@"drawinghelper@gmail.com"]) {
        self.tabBarController.viewControllers = [NSArray arrayWithObjects:
//                                                 newCommonNavViewController,
                                                 newWeiboNavViewController,
                                                 newPathNavViewController,
                                                 historyTopNavViewController,
                                                 collectGalleryNavViewController,
                                                 //channelNavViewController,
                                                 //collectNavViewController,
                                                 settingNavViewController,
                                                 nil];
    } else {
        if ([showFilteredNew isEqualToString:@"YES"]) {
            self.tabBarController.viewControllers = [NSArray arrayWithObjects:
                                                         newPathNavViewController,
                                                         historyTopNavViewController,
                                                         channelNavViewController,
                                                         collectNavViewController,
                                                         settingNavViewController,
                                                         nil];
            if ([showChannel isEqualToString:@"NO"]) {
                self.tabBarController.viewControllers = [NSArray arrayWithObjects:
                                                         newPathNavViewController,
                                                         historyTopNavViewController,
                                                         collectNavViewController,
                                                         settingNavViewController,
                                                         nil];
            }
        } else {
            self.tabBarController.viewControllers = [NSArray arrayWithObjects:
                                                     newCommonNavViewController, 
                                                     historyTopNavViewController,
                                                     channelNavViewController,
                                                     collectNavViewController,
                                                     settingNavViewController,
                                                     nil];
            if ([showChannel isEqualToString:@"NO"]) {
                self.tabBarController.viewControllers = [NSArray arrayWithObjects:
                                                         newCommonNavViewController, 
                                                         historyTopNavViewController,
                                                         collectNavViewController,
                                                         settingNavViewController,
                                                         nil];
            }
        }
    }
        
    self.window.rootViewController = self.tabBarController;
    //[NSThread sleepForTimeInterval:1.0];
    [self.window makeKeyAndVisible];
    [self animateSplashScreen];

    [Appirater appLaunched:YES];
    
    application.applicationIconBadgeNumber = 0;
    [self buryRoutineNotification];
    
    return YES;
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0;
    //从push过来默认来最热tab
    [self.tabBarController setSelectedIndex:1];
    [PFPush handlePush:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //这里，你就可以通过notification的useinfo，干一些你想做的事情了
    application.applicationIconBadgeNumber -= 1;
    
    [self buryRoutineNotification];
}

- (void)buryRoutineNotification {
    //删除所有本地应用外推送
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //设置明天的这个时候推送
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    //NSDate *date = [NSDate dateWithTimeIntervalSinceNow:30];
    //创建一个本地推送
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    if (noti) {
        //设置推送时间
        noti.fireDate = date;
        //设置重复间隔
        noti.repeatInterval = NSWeekCalendarUnit;
        NSString *localNotiRepeatInterval = [MobClick getConfigParams:@"localNotiRepeatInterval"];
        if (localNotiRepeatInterval != nil 
            && localNotiRepeatInterval != [NSNull null] 
            && ![localNotiRepeatInterval isEqualToString:@""]) {
            
            if ([localNotiRepeatInterval isEqualToString:@"week"]) {
                noti.repeatInterval = NSWeekCalendarUnit;
            } else if ([localNotiRepeatInterval isEqualToString:@"day"]) {
                noti.repeatInterval = NSDayCalendarUnit;
            } else {
                noti.repeatInterval = 0;                
            }
        }
        
        //内容
        noti.alertBody = [NSString stringWithFormat:@"今天又有新%@啦，来看看吧！",
                          [[NoneAdultAppDelegate sharedAppDelegate] getAlertKeyword]];
        NSString *localNotiAlertBody = [MobClick getConfigParams:@"localNotiAlertBody"];
        if (localNotiAlertBody != nil 
            && localNotiAlertBody != [NSNull null] 
            && ![localNotiAlertBody isEqualToString:@""]) {
            noti.alertBody = localNotiAlertBody;
        }
        
        //设置时区
        noti.timeZone = [NSTimeZone defaultTimeZone];
        //推送声音
        noti.soundName = UILocalNotificationDefaultSoundName;
        //显示在icon上的红色圈中的数子
        noti.applicationIconBadgeNumber = 1;
        //设置userinfo 方便在之后需要撤销的时候使用
        NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"name" forKey:@"key"];
        noti.userInfo = infoDic;
        //添加推送到uiapplication        
        UIApplication *app = [UIApplication sharedApplication];
        [app scheduleLocalNotification:noti];  
    }
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
