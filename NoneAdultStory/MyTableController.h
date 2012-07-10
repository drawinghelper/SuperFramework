//
//  MyTableController.h
//  ParseStarterProject
//
//  Created by James Yu on 12/29/11.
//  Copyright (c) 2011 Parse Inc. All rights reserved.
//

#import <Parse/Parse.h>
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "UMSNSService.h"
#import "NoneAdultAppDelegate.h"

#define FONT_SIZE 14.0f
#define TOP_SECTION_HEIGHT 52.0f
#define BOTTOM_SECTION_HEIGHT 34.0f

@interface MyTableController : PFQueryTableViewController<MBProgressHUDDelegate, UMSNSDataSendDelegate, UIActionSheetDelegate> {
    MBProgressHUD *HUD;
    PFObject *currentDuanZi;
}

@end
