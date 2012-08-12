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
    [logoutBarItem setTintColor:[UIColor colorWithRed:142.0f/255.0f green:203.0f/255.0f blue:203.0f/255.0f alpha:1.0f]];

    loginBarItem = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStyleBordered target:self action:@selector(onLogInOAuthButtonPressed)];
    [loginBarItem setTintColor:[UIColor colorWithRed:142.0f/255.0f green:203.0f/255.0f blue:203.0f/255.0f alpha:1.0f]];

    //暂时隐藏注销登录按钮
    [self checkLeftBarButton];
    
    if ([weiBoEngine isLoggedIn] && ![weiBoEngine isAuthorizeExpired]) {
        [self performRefresh];
    }
}

#pragma mark - WBEngineDelegate Methods

- (void)engine:(WBEngine *)engine requestDidSucceedWithResult:(id)result
{
    NSLog(@"requestDidSucceedWithResult: %@", result);
    
    //[weiBoEngine loadRequestWithMethodName:@"statuses/home_timeline.json"
    NSString *requestUrl = [[engine request] url];
    if ([requestUrl rangeOfString:@"statuses/home_timeline.json"].length > 0) {
        NSLog(@"statuses/home_timeline.json...");
        
        NSString *statusIdArrayStr = [[NSString alloc] initWithString:@""];
        if ([result isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *dict = (NSDictionary *)result;
            statuses = [dict objectForKey:@"statuses"];
            
            NSDictionary *status = nil;
            for (int i=0; i< [statuses count]; i++) {
                status = [statuses objectAtIndex:i];
                statusIdArrayStr = [statusIdArrayStr stringByAppendingFormat:@"%@,", 
                                    [status objectForKey:@"idstr"]];
            }
            int statusIdArrayStrLength = statusIdArrayStr.length;
            statusIdArrayStr = [statusIdArrayStr substringToIndex:(statusIdArrayStrLength-1)];//去掉尾巴上的,
        }
        
        //批量请求微博的mid，用于拼凑shareurl
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
        [params setObject:[NSString stringWithFormat:@"%d",1] forKey:@"is_batch"];//是否使用批量模式
        [params setObject:[NSString stringWithFormat:@"%d",1] forKey:@"type"];//获取类型，1：微博、2：评论、3：私信，默认为1。
        [params setObject:statusIdArrayStr forKey:@"id"];  //带转换mid的微博id      
        [weiBoEngine loadRequestWithMethodName:@"statuses/querymid.json"
                                    httpMethod:@"GET"
                                        params:params
                                  postDataType:kWBRequestPostDataTypeNone
                              httpHeaderFields:nil];
    } else {
        [indicatorView stopAnimating];
        NSMutableDictionary *statusesId2MidDic = [[NSMutableDictionary alloc] init];
        //NSLog(@"statuses/querymid.json... %@", result);
        if ([result isKindOfClass:[NSArray class]]){
            NSArray *statusesId2MidArray = (NSArray *)result;
            for (int i=0; i < [statusesId2MidArray count]; i++) {
                NSDictionary *dic = [statusesId2MidArray objectAtIndex:i];
                NSArray *keys = [dic allKeys];
                for (int j = 0; j < [keys count]; j++) {
                    NSString *key = [keys objectAtIndex:j];
                    [statusesId2MidDic setObject:[dic objectForKey:key]
                                          forKey:key];
                }
            }
        }
        
        NSMutableDictionary *status = nil;
        for (int i=0; i< [statuses count]; i++) {
            status = [statuses objectAtIndex:i];
            NSString *idStr = [status objectForKey:@"idstr"];
            [status setObject:[statusesId2MidDic objectForKey:idStr]
                       forKey:@"mid"];
        }
        
        //NSLog(@"%@", statusesId2MidDic);
        [self performSelectorOnMainThread:@selector(appendTableWith:) withObject:statuses waitUntilDone:NO];
    }
    
}

- (void)engine:(WBEngine *)engine requestDidFailWithError:(NSError *)error
{
    [indicatorView stopAnimating];
    NSLog(@"requestDidFailWithError: %@", error);
}

- (void)requestResultFromServer
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:3];
    [params setObject:[NSString stringWithFormat:@"%d",1] forKey:@"feature"];//只显示原创微博
    [params setObject:[NSString stringWithFormat:@"%d",20] forKey:@"count"];
    
    if (loadOld && [searchDuanZiList count] > 0 ) {
        NSDictionary *lastDuanZi = [searchDuanZiList objectAtIndex:([searchDuanZiList count] - 1)];
        NSNumber *lastIdNum = [lastDuanZi objectForKey:@"id"];
        long long lastId = [lastIdNum longLongValue];
        [params setObject:[NSString stringWithFormat:@"%lld", lastId - 1] forKey:@"max_id"];
    }
    
    [weiBoEngine loadRequestWithMethodName:@"statuses/home_timeline.json"
                           httpMethod:@"GET"
                               params:params
                         postDataType:kWBRequestPostDataTypeNone
                     httpHeaderFields:nil];
    
    [indicatorView startAnimating];
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

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
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
    //NSLog(@"timestamp: %@, createAtStr: %@, createAt: %@", timestamp, createAtStr, createAt);
    
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
    
    //拼凑shareurl
    NSDictionary *userInfo = [dic objectForKey:@"user"];
    [dic setObject:[NSString stringWithFormat:@"http://weibo.com/%@/%@", 
                    [userInfo objectForKey:@"id"],
                    [dic objectForKey:@"mid"]] 
            forKey:@"shareurl"];
    //NSLog(@"shareurl: %@", [dic objectForKey:@"shareurl"]);
}

- (NSString *)autoCorrectNull:(NSString *)input {
    if (input == nil || input == [NSNull null]) {
        return @"";
    }
    return input;
}
@end
