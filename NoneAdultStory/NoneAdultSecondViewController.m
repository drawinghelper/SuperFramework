//
//  NoneAdultSecondViewController.m
//  NoneAdultStory
//
//  Created by 王 攀 on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NoneAdultSecondViewController.h"

@interface NoneAdultSecondViewController ()

@end

@implementation NoneAdultSecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"历史热门", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}
- (void)loadUrl {
    url = [[NSString alloc] initWithString:@"http://i.snssdk.com/essay/1/top/?tag=joke&offset=0&count=100"];
    NSLog(@"loadUrl: %@", url);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    canLoadNew = NO;
    canLoadOld = NO;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end