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
        [[AdSageManager getInstance] setAdSageKey:@"6d744669b2b4419bb30cb30b56f3f744"];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([NoneAdultAppDelegate class]));
    }
}
