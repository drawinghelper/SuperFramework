//
//  NewWeiboViewController.m
//  WeiMeiShiSNSOperation
//
//  Created by 王 攀 on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewWeiboViewController.h"
#define kWBSDKDemoAppKey @"23047618"
#define kWBSDKDemoAppSecret @"7a270c2a948042c4d6740acc5321d374"

#ifndef kWBSDKDemoAppKey
#error
#endif

#ifndef kWBSDKDemoAppSecret
#error
#endif

#define kWBAlertViewLogOutTag 100
#define kWBAlertViewLogInTag  101

@interface NewWeiboViewController ()

@end

@implementation NewWeiboViewController
@synthesize weiBoEngine;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTitle:(NSString *)title
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(title, @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"tab_weibo"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.shadowColor = [UIColor colorWithRed:219.0f/255 green:241.0f/225 blue:241.0f/255 alpha:1];     
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:37.0f/255 green:149.0f/225 blue:149.0f/255 alpha:1];        
        [label setShadowOffset:CGSizeMake(0, 1.0)];
        
        self.navigationItem.titleView = label;
        label.text = NSLocalizedString(title, @"");
        [label sizeToFit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        
    WBEngine *engine = [[WBEngine alloc] initWithAppKey:kWBSDKDemoAppKey appSecret:kWBSDKDemoAppSecret];
    [engine setRootViewController:self];
    [engine setDelegate:self];
    [engine setRedirectURI:@"http://"];
    [engine setIsUserExclusive:NO];
    self.weiBoEngine = engine;

    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView setCenter:CGPointMake(160, 240)];
    [self.view addSubview:indicatorView];
    
    logoutBarItem = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStyleBordered target:self action:@selector(onLogOutButtonPressed)];
    loginBarItem = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStyleBordered target:self action:@selector(onLogInOAuthButtonPressed)];

    [self checkLeftBarButton];
    if ([weiBoEngine isLoggedIn] && ![weiBoEngine isAuthorizeExpired]) {
        [self refreshTimeline];
        [indicatorView startAnimating];
    }
}

#pragma mark - WBEngineDelegate Methods

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    [indicatorView stopAnimating];
    NSLog(@"requestDidSucceedWithResult: %@", result);
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)result;
        [timeLine addObjectsFromArray:[dict objectForKey:@"statuses"]];
        //NSLog(@"timeLine: %d", [timeLine count]);
        [self performSelectorOnMainThread:@selector(appendTableWith:) withObject:timeLine waitUntilDone:NO];
    }
}

- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    [indicatorView stopAnimating];
    NSLog(@"requestDidFailWithError: %@", error);
}

- (void)refreshTimeline
{
    timeLine = [[NSMutableArray alloc] init];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    [params setObject:[NSString stringWithFormat:@"%d",1] forKey:@"feature"];//只显示原创微博
    [params setObject:[NSString stringWithFormat:@"%d",1] forKey:@"page"];
    [params setObject:[NSString stringWithFormat:@"%d",100] forKey:@"count"];
    [weiBoEngine loadRequestWithMethodName:@"statuses/home_timeline.json"
                           httpMethod:@"GET"
                               params:params
                         postDataType:kWBRequestPostDataTypeNone
                     httpHeaderFields:nil];
}

- (void)checkLeftBarButton {
    if ([weiBoEngine isLoggedIn] && ![weiBoEngine isAuthorizeExpired])
    {
        self.navigationItem.leftBarButtonItem = logoutBarItem;
    } else {
        self.navigationItem.leftBarButtonItem = loginBarItem;
    }
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        [indicatorView setCenter:CGPointMake(240, 160)];
    }
    else
    {
        [indicatorView setCenter:CGPointMake(160, 240)];
    }
}

#pragma mark - WBLogInAlertViewDelegate Methods

- (void)logInAlertView:(WBLogInAlertView *)alertView logInWithUserID:(NSString *)userID password:(NSString *)password
{
    [weiBoEngine logInUsingUserID:userID password:password];
    
    [indicatorView startAnimating];
}

#pragma mark - User Actions
- (void)onLogInOAuthButtonPressed
{
    [weiBoEngine logIn];
}
- (void)onLogOutButtonPressed
{
    [weiBoEngine logOut];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - WBEngineDelegate Methods

#pragma mark Authorize

- (void)engineAlreadyLoggedIn:(WBEngine *)engine
{
    [indicatorView stopAnimating];
    if ([engine isUserExclusive])
    {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil 
                                                           message:@"请先登出！" 
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定" 
                                                 otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)engineDidLogIn:(WBEngine *)engine
{
    [indicatorView stopAnimating];
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil 
													   message:@"登录成功！" 
													  delegate:self
											 cancelButtonTitle:@"确定" 
											 otherButtonTitles:nil];
    [alertView setTag:kWBAlertViewLogInTag];
	[alertView show];
    
    [self checkLeftBarButton];
}

- (void)engine:(WBEngine *)engine didFailToLogInWithError:(NSError *)error
{
    [indicatorView stopAnimating];
    NSLog(@"didFailToLogInWithError: %@", error);
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil 
													   message:@"登录失败！" 
													  delegate:nil
											 cancelButtonTitle:@"确定" 
											 otherButtonTitles:nil];
	[alertView show];
}

- (void)engineDidLogOut:(WBEngine *)engine
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil 
													   message:@"登出成功！" 
													  delegate:self
											 cancelButtonTitle:@"确定" 
											 otherButtonTitles:nil];
    [alertView setTag:kWBAlertViewLogOutTag];
	[alertView show];
    [self checkLeftBarButton];
}

- (void)engineNotAuthorized:(WBEngine *)engine
{
    
}

- (void)engineAuthorizeExpired:(WBEngine *)engine
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil 
													   message:@"请重新登录！" 
													  delegate:nil
											 cancelButtonTitle:@"确定" 
											 otherButtonTitles:nil];
	[alertView show];
}

//从微博接口格式适配到腾讯微频道接口格式
- (void)adaptDic:(NSMutableDictionary *)dic {
    NSString *idString = [self autoCorrectNull:[dic objectForKey:@"idstr"]];
    NSString *weiboContent = [self autoCorrectNull:[dic objectForKey:@"text"]];
    
    NSDictionary *user = [dic objectForKey:@"user"];
    NSString *screenName = [self autoCorrectNull:[user objectForKey:@"screen_name"]];
    NSString *profileImageUrl = [self autoCorrectNull:[user objectForKey:@"profile_image_url"]];
    
    NSDecimalNumber *favoriteCount = (NSDecimalNumber *)[dic objectForKey:@"reposts_count"];
    NSDecimalNumber *buryCount = [[NSDecimalNumber alloc] initWithInt:([favoriteCount intValue]/5)];
    NSDecimalNumber *commentCount = [[NSDecimalNumber alloc] initWithInt:([favoriteCount intValue]/3)];
    
    NSString *createAtStr = [dic objectForKey:@"created_at"];
    NSDateFormatter *dateTimeFormatter=[[NSDateFormatter alloc] init];
    //    "created_at" = "Thu Jul 26 21:50:23 +0800 2012";
    [dateTimeFormatter setDateFormat:@"EEE MMM d HH:mm:ss Z yyyy"];
    [dateTimeFormatter setLocale:
        [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]
     ];

    NSDate *createAt = [dateTimeFormatter dateFromString:createAtStr];
    NSDecimalNumber *timestamp = [NSDecimalNumber numberWithDouble:
                                  [createAt timeIntervalSince1970]];
    NSLog(@"timestamp: %@, createAtStr: %@, createAt: %@", timestamp, createAtStr, createAt);
    
    [dic setObject:screenName forKey:@"screen_name"];
    [dic setObject:profileImageUrl forKey:@"profile_image_url"];
    [dic setObject:[weiboContent stringByConvertingHTMLToPlainText] forKey:@"content"];
    [dic setObject:favoriteCount forKey:@"favorite_count"];
    [dic setObject:buryCount forKey:@"bury_count"];
    [dic setObject:commentCount forKey:@"comments_count"];
    [dic setObject:timestamp forKey:@"timestamp"];

    NSString *imageUrl = [self autoCorrectNull:[dic objectForKey:@"bmiddle_pic"]];
    [dic setObject:imageUrl forKey:@"large_url"];    //图片内容的url

    if (![imageUrl isEqualToString:@""]) {
        [dic setObject:[NSNumber numberWithInt:200] forKey:@"width"];//图片内容的width
        [dic setObject:[NSNumber numberWithInt:400] forKey:@"height"];//图片内容的height
    }
    
}

- (NSString *)autoCorrectNull:(NSString *)input {
    if (input == nil || input == [NSNull null]) {
        return @"";
    }
    return input;
}
@end
