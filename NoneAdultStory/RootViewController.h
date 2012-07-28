//
//  RootViewController.h
//  FGallery
//
//  Created by Grant Davis on 1/6/11.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGalleryViewController.h"

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
