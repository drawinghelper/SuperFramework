//
//  CollectedViewController.h
//  NoneAdultStory
//
//  Created by 王 攀 on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewCommonViewController.h"
#import "UMTableViewDemoNew.h"
@interface CollectedViewController : NewCommonViewController{
    BOOL firstLoaded;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTitle:(NSString *)title;

@end
