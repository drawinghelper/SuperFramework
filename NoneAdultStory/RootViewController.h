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
#define TOP_SECTION_HEIGHT 150.0f
#define kTableViewCellHeight 150.0f
#define kTableViewCellWidth 320.0f

@interface RootViewController : UITableViewController <FGalleryViewControllerDelegate> {
	NSMutableArray *localCaptions;
    NSMutableArray *localImages;
    NSMutableArray *localThumbnailImages;
    NSArray *networkCaptions;
    NSArray *networkImages;
	FGalleryViewController *localGallery;
    FGalleryViewController *networkGallery;
}

@end
