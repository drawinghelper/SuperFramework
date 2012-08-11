//
//  MagicWeiboViewController.h
//  WeiMeiShiSNSOperation
//
//  Created by 王 攀 on 12-8-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#define kOAuthConsumerKey				@"1465497702"		//REPLACE ME
#define kOAuthConsumerSecret			@"0d1fda13c23452cb4e7088593b5e6dbe"		//REPLACE ME

#import "NewCommonViewController.h"
#import "OAuthController.h"
#import "WeiboClient.h"

@interface MagicWeiboViewController : NewCommonViewController<OAuthControllerDelegate>{
    OAuthEngine				*_engine;
	WeiboClient *weiboClient;
	NSMutableArray *statuses;           //1.昨日原创微博
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTitle:(NSString *)title;
@end
