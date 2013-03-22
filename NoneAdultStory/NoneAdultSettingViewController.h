//
//  NoneAdultSettingViewController.h
//  NeiHanStory
//
//  Created by 王 攀 on 12-6-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobClick.h"
#import "UMFeedback.h"
#import "Appirater.h"
#import "NoneAdultAppDelegate.h"
#import "UMTableViewDemoNew.h"
#import "MyLogInViewController.h"
#import "MySignUpViewController.h"
#import "AGAuthViewController.h"
@interface NoneAdultSettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>{
    IBOutlet UITableView *tableView;
    
    //NSString *versionForReview;
}
@property(nonatomic, retain) UITableView *tableView;

@end
