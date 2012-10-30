//
//  CateViewController.h
//  top100
//
//  Created by Dai Cloud on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFolderTableView.h"
#import "NewPathViewController.h"
#import "FGalleryViewController.h"

@interface CateViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FGalleryViewControllerDelegate, UIActionSheetDelegate, MBProgressHUDDelegate> {
    
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
