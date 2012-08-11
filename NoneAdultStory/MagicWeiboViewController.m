//
//  MagicWeiboViewController.m
//  WeiMeiShiSNSOperation
//
//  Created by 王 攀 on 12-8-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MagicWeiboViewController.h"

@interface MagicWeiboViewController ()

@end

@implementation MagicWeiboViewController

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadTimeline {
	UIViewController *controller = [OAuthController controllerToEnterCredentialsWithEngine: _engine delegate:self];
	
	if (controller) {
        NSLog(@"controller != null");
		[self presentModalViewController: controller animated: YES];
	} else {
        NSLog(@"controller == null");
		NSLog(@"Authenicated for %@..", _engine.username);
		[OAuthEngine setCurrentOAuthEngine:_engine];
        
		[self loadData];
        
		
		/*
         WeiboClient *followClient = [[WeiboClient alloc] initWithTarget:self 
         engine:_engine
         action:@selector(followDidReceive:obj:)];
         [followClient follow:1727858283]; // follow the author!
		 */ 
	}
}

- (void)openAuthenticateView {
	[self removeCachedOAuthDataForUsername:_engine.username];
	[_engine signOut];
	UIViewController *controller = [OAuthController controllerToEnterCredentialsWithEngine: _engine delegate: self];
	
	if (controller) 
		[self presentModalViewController: controller animated: YES];
}

- (void)timelineDidReceive:(WeiboClient*)sender obj:(NSObject*)obj
{
	NSLog(@"begin timelineDidReceive");
        
    //处理数据
    if (sender.hasError) {
		NSLog(@"timelineDidReceive error!!!, errorMessage:%@, errordetail:%@"
			  , sender.errorMessage, sender.errorDetail);
		[sender alert];
        if (sender.statusCode == 401) {
            [self openAuthenticateView];
        }
    }
	weiboClient = nil;
    
    if (obj == nil || ![obj isKindOfClass:[NSArray class]]) {
        return;
    }
	NSArray *ary = (NSArray*)obj;  
    
    //查找微博时间线上昨天的微博，放入statuses
	for (int i = 0; i < [ary count]; i++) {
		NSDictionary *dic = (NSDictionary*)[ary objectAtIndex:i];
		if (![dic isKindOfClass:[NSDictionary class]]) {
			continue;
		}
		Status* sts = [Status statusWithJsonDictionary:[ary objectAtIndex:i]];
        NSDate *someDate = [NSDate dateWithTimeIntervalSince1970:sts.createdAt];
        NSLog(@"id = %lld, date = %@, large_url = %@", sts.statusId ,[someDate description], sts.originalPic);
        
    }		
}


- (void)loadData {
	if (weiboClient) { 
		return;
	}
	weiboClient = [[WeiboClient alloc] initWithTarget:self 
											   engine:_engine
											   action:@selector(timelineDidReceive:obj:)];
	[weiboClient getFollowedTimelineSinceID:0 
                             startingAtPage:1 count:200];						
     //startingAtPage:currentPageIndex++ count:200];
}

//=============================================================================================================================
#pragma mark OAuthEngineDelegate
- (void) storeCachedOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

- (void)removeCachedOAuthDataForUsername:(NSString *) username{
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults removeObjectForKey: @"authData"];
	[defaults synchronize];
}
//=============================================================================================================================
#pragma mark OAuthSinaWeiboControllerDelegate
- (void) OAuthController: (OAuthController *) controller authenticatedWithUsername: (NSString *) username {
	NSLog(@"Authenicated for %@", username);
	[self loadTimeline];
}

- (void) OAuthControllerFailed: (OAuthController *) controller {
	NSLog(@"Authentication Failed!");
	//UIViewController *controller = [OAuthController controllerToEnterCredentialsWithEngine: _engine delegate: self];
	
	if (controller) 
		[self presentModalViewController: controller animated: YES];
	
}

- (void) OAuthControllerCanceled: (OAuthController *) controller {
	NSLog(@"Authentication Canceled.");
	//UIViewController *controller = [OAuthController controllerToEnterCredentialsWithEngine: _engine delegate: self];
	
	//if (controller) 
    //[self presentModalViewController: controller animated: YES];
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"RootViewController.viewDidAppear...");
    [super viewDidAppear:animated];
	if (!_engine){
		_engine = [[OAuthEngine alloc] initOAuthWithDelegate: self];
		_engine.consumerKey = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;
	}
    [self loadTimeline];
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

@end
