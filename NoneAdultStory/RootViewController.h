//
//  RootViewController.h
//  FGallery
//
//  Created by Grant Davis on 1/6/11.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGalleryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Gradient.h"
#import "SWSnapshotStackView.h"
#import "NoneAdultAppDelegate.h"
#import "SDWebImageManager.h"
#import "MBProgressHUD.h"
#import "UMSNSService.h"
#import "AdMoGoView.h"
#import "NewPathViewController.h"

#define TOP_SECTION_HEIGHT 150.0f
#define kTableViewCellHeight 50.0f
#define kTableViewCellWidth 320.0f
#define kPresetNum 10

@interface RootViewController : UITableViewController <UIActionSheetDelegate, MBProgressHUDDelegate, UMSNSDataSendDelegate, AdMoGoDelegate, FGalleryViewControllerDelegate> {
    AdMoGoView *adView;

	FGalleryViewController *localGallery;
	NSMutableArray *localCaptions;
    NSMutableArray *localImages;
    NSMutableArray *localThumbnailImages;//缩略图数组
    
    FGalleryViewController *networkGallery;
    NSMutableArray *networkCaptions;
    NSMutableArray *networkImages;
    NSMutableArray *networkShareUrl;//对应微博url数组
    
    MBProgressHUD *HUD;
    UIImage *currentImage;
    FGalleryViewController *currentGallery;
}

@property (nonatomic, retain) AdMoGoView *adView;

@end
