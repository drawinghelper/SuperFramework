//
//  NewWeiboViewController.h
//  WeiMeiShiSNSOperation
//
//  Created by 王 攀 on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewCommonViewController.h"
#import "WBEngine.h"
#import "WBSendView.h"
#import "WBLogInAlertView.h"

@interface NewWeiboViewController : NewCommonViewController <WBEngineDelegate, UIAlertViewDelegate, WBLogInAlertViewDelegate>{
    WBEngine *weiBoEngine;
    UIActivityIndicatorView *indicatorView;
    
    UIBarButtonItem *logoutBarItem;
    UIBarButtonItem *loginBarItem;
}
@property (nonatomic, retain) WBEngine *weiBoEngine;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTitle:(NSString *)title;
@end
