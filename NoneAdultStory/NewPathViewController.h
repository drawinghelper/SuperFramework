//
//  HistoryPathViewController.h
//  ParseStarterProject
//
//  Created by James Yu on 12/29/11.
//  Copyright (c) 2011 Parse Inc. All rights reserved.
//

#import <Parse/Parse.h>
#import "UMSNSStringJson.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "UMSNSService.h"
#import "NoneAdultAppDelegate.h"
#import "AdMoGoView.h"
#import "FGalleryViewController.h"
#import "SVWebViewController.h"

#define FONT_SIZE 14.0f
#define TOP_SECTION_HEIGHT 52.0f
#define BOTTOM_SECTION_HEIGHT 34.0f
#define HORIZONTAL_PADDING 16.0f
#define PLAYBUTTON_WIDTH 30.0f

@interface NewPathViewController : PFQueryTableViewController<MBProgressHUDDelegate, UMSNSDataSendDelegate, UIActionSheetDelegate, UIAlertViewDelegate, AdMoGoDelegate, FGalleryViewControllerDelegate> {
    AdMoGoView *adView;

    MBProgressHUD *HUD;
    PFObject *currentDuanZi;
    UIImage *currentImage;
    
    NSMutableDictionary *collectedIdsDic;
    NSMutableArray *newObjectArray;
    NSDictionary *pullmessageInfo;
    
    BOOL newChannel;
    
    NSString *keyword;
}
@property (nonatomic, retain) AdMoGoView *adView;
@property (nonatomic, retain) NSString *keyword;

@end
