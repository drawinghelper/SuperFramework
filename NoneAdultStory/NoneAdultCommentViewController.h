//
//  NoneAdultCommentViewController.h
//  SuperFramework
//
//  Created by 王 攀 on 13-2-16.
//
//
#define TOP_SECTION_HEIGHT 52.0f

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "UMSNSStringJson.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "NoneAdultAppDelegate.h"
@interface NoneAdultCommentViewController : UITableViewController{
    NSString *recordId;
    
    NSMutableData *responseData;
    NSString *url;
    MBProgressHUD *HUD;
    
    NSMutableArray *searchDuanZiList;
}
@property(nonatomic, retain) NSString *recordId;

@end
