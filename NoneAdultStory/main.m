//
//  main.m
//  NoneAdultStory
//
//  Created by 王 攀 on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShareSDK/ShareConfig.h>
#import "NoneAdultAppDelegate.h"
#import "AdSageManager.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        [[AdSageManager getInstance] setAdSageKey:@"dd6c983da2f5494e8e6c1349fbcf6ae8"];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([NoneAdultAppDelegate class]));
    }
}
