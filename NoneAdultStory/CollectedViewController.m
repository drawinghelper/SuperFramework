//
//  CollectedViewController.m
//  NoneAdultStory
//
//  Created by 王 攀 on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CollectedViewController.h"

@interface CollectedViewController ()

@end

@implementation CollectedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTitle:(NSString *)title
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(title, @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"collect"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.shadowColor = [UIColor colorWithRed:70.0f/255 green:70.0f/225 blue:70.0f/255 alpha:1];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:235.0f/255 green:235.0f/225 blue:235.0f/255 alpha:1];
        [label setShadowOffset:CGSizeMake(0, 1.0)];
        
        self.navigationItem.titleView = label;
        label.text = NSLocalizedString(title, @"");
        [label sizeToFit];
    }
    return self;
}

- (void)requestResultFromServer {
    NSLog(@"CollectedViewController.requestResultFromServer...");
    //[HUD hide:YES afterDelay:0];
    
    FMDatabase *db= [FMDatabase databaseWithPath:[[NoneAdultAppDelegate sharedAppDelegate] getDbPath]] ;  
    if (![db open]) {  
        NSLog(@"Could not open db."); 
        return ;  
    } 

    NSMutableArray *addedList = [[NSMutableArray alloc] init];
    FMResultSet *rs=[db executeQuery:@"SELECT * FROM collected ORDER BY collect_time DESC"];
    NSMutableDictionary *dic = nil;
    while ([rs next]){
        dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[rs stringForColumn:@"weiboId"] forKey:@"id"];
        [dic setObject:[rs stringForColumn:@"screen_name"] forKey:@"nick"];
        [dic setObject:[rs stringForColumn:@"profile_image_url"] forKey:@"pic"];
        NSNumber *number = [[NSNumber alloc] initWithInt:[rs intForColumn:@"timestamp"]];
        [dic setObject:number forKey:@"timestamp"];
        [dic setObject:[rs stringForColumn:@"content"] forKey:@"content"];
        
        [dic setObject:[rs stringForColumn:@"large_url"] forKey:@"large_url"];
        [dic setObject:[[NSNumber alloc] initWithInt:[rs intForColumn:@"width"]]
                forKey:@"width"];
        [dic setObject:[[NSNumber alloc] initWithInt:[rs intForColumn:@"height"]]
                forKey:@"height"];
        [dic setObject:[[NSNumber alloc] initWithInt:[rs intForColumn:@"gif_mark"]]
                forKey:@"gif_mark"];

        number = [[NSNumber alloc] initWithInt:[rs intForColumn:@"favorite_count"]];
        [dic setObject:number forKey:@"count"];
        number = [[NSNumber alloc] initWithInt:[rs intForColumn:@"bury_count"]];
        [dic setObject:number forKey:@"bury_count"];
        number = [[NSNumber alloc] initWithInt:[rs intForColumn:@"comments_count"]];
        [dic setObject:number forKey:@"comments_count"];

        [addedList addObject:dic];
    }
    [self performSelectorOnMainThread:@selector(appendTableWith:) withObject:addedList waitUntilDone:NO];
}

//从享评接口格式适配到腾讯微频道接口格式
- (void)adaptDic:(NSMutableDictionary *)dic {
    NSString *idString = [dic objectForKey:@"id"];
    NSString *screenName = [dic objectForKey:@"nick"];
    NSString *profileImageUrl = [dic objectForKey:@"pic"];
    NSString *weiboContent = [dic objectForKey:@"content"];
    
    NSDecimalNumber *favoriteCount = (NSDecimalNumber *)[dic objectForKey:@"count"];
    NSDecimalNumber *buryCount = [[NSDecimalNumber alloc] initWithInt:([favoriteCount intValue]/5)];
    NSDecimalNumber *commentCount = [[NSDecimalNumber alloc] initWithInt:([favoriteCount intValue]/3)];
    
    [dic setObject:screenName forKey:@"screen_name"];
    [dic setObject:profileImageUrl forKey:@"profile_image_url"];
    [dic setObject:[weiboContent stringByConvertingHTMLToPlainText] forKey:@"content"];
    [dic setObject:favoriteCount forKey:@"favorite_count"];
    [dic setObject:buryCount forKey:@"bury_count"];
    [dic setObject:commentCount forKey:@"comments_count"];
}

-(void)goCollect:(id)sender{  
    [super goCollect:sender];
    //刷新一下本页
    [self performRefresh];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = nil;
    firstLoaded = YES;
    self.tableView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1];
    
    if (self.adView != nil) {
        [self.adView removeFromSuperview];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    if (!firstLoaded) {
        [self performRefresh];
    }
    firstLoaded = NO;
}
//覆盖父类的方法
- (void)showLianMeng {
    UMTableViewDemoNew *lianMengViewController = [[UMTableViewDemoNew alloc]init];
    lianMengViewController.title = @"精彩应用推荐";
    lianMengViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lianMengViewController animated:YES];
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
