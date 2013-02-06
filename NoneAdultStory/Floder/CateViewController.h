//
//  CateViewController.h
//  top100
//
//  Created by Dai Cloud on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFolderTableView.h"
#import "NewCommonViewController.h"
#import "FGalleryViewController.h"
#import "MobiSageRecommendSDK.h"

@interface CateViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FGalleryViewControllerDelegate, UIActionSheetDelegate, MBProgressHUDDelegate, MobiSageRecommendDelegate> {
    MobiSageRecommendView *recmdView;

    FGalleryViewController *networkGallery;
    NSMutableArray *networkCaptions;
    NSMutableArray *networkImages;
    NSMutableArray *networkShareUrl;//对应微博url数组
    
    MBProgressHUD *HUD;
    UIImage *currentImage;
}

@property (strong, nonatomic) NSArray *cates;
@property (strong, nonatomic) IBOutlet UIFolderTableView *tableView;

@end
