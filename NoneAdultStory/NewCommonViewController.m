//
//  NewCommonViewController.m
//  NoneAdultStory
//
//  Created by 王 攀 on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewCommonViewController.h"

@interface NewCommonViewController ()

@end

@implementation NewCommonViewController
@synthesize tableView;
@synthesize adView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTitle:(NSString *)title withCid:(NSString *)cid
{
    currentCid = cid;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(title, @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"new"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.shadowColor = [UIColor colorWithRed:219.0f/255 green:241.0f/225 blue:241.0f/255 alpha:1];     
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:37.0f/255 green:149.0f/225 blue:149.0f/255 alpha:1];        
        [label setShadowOffset:CGSizeMake(0, 1.0)];
        
        self.navigationItem.titleView = label;
        label.text = NSLocalizedString(title, @"");
        [label sizeToFit];
    }
    return self;
}

- (NSString *)adMoGoApplicationKey{
    return [[NoneAdultAppDelegate sharedAppDelegate] getMogoAppKey];
    //return @"8263cdaa8f724e2293b2f9f3aff849ee"; //此字符串为您的 App 在芒果上的唯一
}

-(UIViewController *)viewControllerForPresentingModalView{
    return self;//返回的对象为 adView 的父视图控制器
}

- (void)adjustAdSize {	
	[UIView beginAnimations:@"AdResize" context:nil];
	[UIView setAnimationDuration:0.7];
	CGSize adSize = [adView actualAdSize];
	CGRect newFrame = adView.frame;
	newFrame.size.height = adSize.height;
	newFrame.size.width = adSize.width;
	newFrame.origin.x = (self.view.bounds.size.width - adSize.width)/2;
    newFrame.origin.y = self.view.bounds.size.height - adSize.height;
	adView.frame = newFrame;
    
	[UIView commitAnimations];
} 

- (void)adMoGoDidReceiveAd:(AdMoGoView *)adMoGoView {
	//广告成功展示时调用
    [self adjustAdSize];
}

- (void)adMoGoDidFailToReceiveAd:(AdMoGoView *)adMoGoView 
                     usingBackup:(BOOL)yesOrNo {
    //请求广告失败
}

- (void)adMoGoWillPresentFullScreenModal {
    //点击广告后打开内置浏览器时调用
}

- (void)adMoGoDidDismissFullScreenModal {
    //关闭广告内置浏览器时调用 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self processPullMessage];

    NSString *showAd = [MobClick getConfigParams:@"showAd"];
    if (showAd == nil || showAd == [NSNull null]  || [showAd isEqualToString:@""]) {
        showAd = @"off";
    }
    //总：AudioToolbox、CoreLocation、CoreTelephony、MessageUI、SystemConfiguration、QuartzCore、EventKit、MapKit、libxml2

    if ([showAd isEqualToString:@"on"]) {
        //增加广告条显示
        self.adView = [AdMoGoView requestAdMoGoViewWithDelegate:self AndAdType:AdViewTypeNormalBanner
                                                    ExpressMode:NO];
        [adView setFrame:CGRectZero];
        [self.view addSubview:adView];
    }
        
    UIButton *btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom]; 
    btnRefresh.frame = CGRectMake(0, 0, 44, 44);
    [btnRefresh addTarget:self action:@selector(performRefresh) forControlEvents:UIControlEventTouchUpInside];
    UIImage *btnImage = [UIImage imageNamed:@"refresh.png"];
    [btnRefresh setImage:btnImage forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRefresh];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] 
                                                  forBarMetrics:UIBarMetricsDefault];   
    
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;        
    }
    
    //  update the last update date
    [_refreshHeaderView refreshLastUpdatedDate];
    
	// Do any additional setup after loading the view, typically from a nib.
    canLoadNew = YES;
    canLoadOld = YES;
    loadOld = NO;
    _reloading = YES;
    
    [self performRefresh];
    self.tableView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1];
    
    //分类页的“返回”按钮定制化
    if (![self.title isEqualToString:@"最新"] 
        && ![self.title isEqualToString:@"收藏"]) {
        UIImage *buttonImage = [UIImage imageNamed:@"custombackbutton.png"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
}

-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)performRefresh {
    loadOld = NO;
    searchDuanZiList = [[NSMutableArray alloc] init];
    [self performSelector:@selector(requestResultFromServer) withObject:nil];
    
}

//处理应用内消息
- (void)processPullMessage {
    NSString *pullmessage = [MobClick getConfigParams:@"pullmessage"];
    if (pullmessage != nil 
        && pullmessage != [NSNull null]
        && ![pullmessage isEqualToString:@""]) {
        
        pullmessageInfo = [UMSNSStringJson JSONValue:pullmessage]; 
        NSString *pullmessageTimestamp = [pullmessageInfo objectForKey:@"timestamp"];
        
        //1. 读取已展现消息的时间戳数组
        NSMutableArray *showedMessageTimestampArray = [[NSMutableArray alloc] init];
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        NSData *dataRepresentingSavedArray = [currentDefaults objectForKey:@"showedMessageTimestampArray"];
        if (dataRepresentingSavedArray != nil)
        {
            NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
            if (oldSavedArray != nil)
                showedMessageTimestampArray = [[NSMutableArray alloc] initWithArray:oldSavedArray];
            else
                showedMessageTimestampArray = [[NSMutableArray alloc] init];
        }
        
        //2. 遍历时间戳数组，与本次消息的时间戳做对比
        BOOL showedTag = NO;
        for (int i = 0; i < [showedMessageTimestampArray count]; i++) {
            NSString *showedMessageTimestamp = [showedMessageTimestampArray objectAtIndex:i];
            if ([showedMessageTimestamp isEqualToString:pullmessageTimestamp]) {
                showedTag = YES;
                break;
            }
        }
        
        //是否匹配渠道与版本号
        NSString *currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
        NSString *channelId = [[NoneAdultAppDelegate sharedAppDelegate] getAppChannelTag];
        NSString *pullmessageChannelIdList = [pullmessageInfo objectForKey:@"channelId"];
        NSString *pullmessageAppversionList = [pullmessageInfo objectForKey:@"appversion"];
        BOOL channelTargeted = NO;
        if ([pullmessageChannelIdList isEqualToString:@""]
            ||[pullmessageChannelIdList rangeOfString:channelId].length > 0 ) {
            channelTargeted = YES;
        }
        BOOL versionTargeted = NO;
        if ([pullmessageAppversionList isEqualToString:@""]
            ||[pullmessageAppversionList rangeOfString:currentAppVersion].length > 0 ) {
            versionTargeted = YES;
        }
        
        if (versionTargeted && channelTargeted) {
            //3. 无匹配项，则显示此消息
            if (!showedTag) {
                UIAlertView *pullmessageAlertView = [[UIAlertView alloc] initWithTitle:[pullmessageInfo objectForKey:@"title"]
                                                                  message:[pullmessageInfo objectForKey:@"message"]
                                                                 delegate:self
                                                        cancelButtonTitle:[pullmessageInfo objectForKey:@"oktitle"]
                                                        otherButtonTitles:[pullmessageInfo objectForKey:@"canceltitle"], nil];
                [pullmessageAlertView show];
                
                [showedMessageTimestampArray addObject:pullmessageTimestamp];
                [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:showedMessageTimestampArray] forKey:@"showedMessageTimestampArray"];
            }
        }
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {          
            NSString *okUrl = [pullmessageInfo objectForKey:@"okurl"];
            if (![okUrl isEqualToString:@""]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:okUrl]];
            }
            break;
        }
        case 1:
        {
            // they want to rate it
            NSString *cancelUrl = [pullmessageInfo objectForKey:@"cancelurl"];
            if (![cancelUrl isEqualToString:@""]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cancelUrl]];
            }
            break;
        }
        default:
            break;
    }

}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    if (canLoadNew) {
        _reloading = YES;
        [self requestResultFromServer];
    }
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    if (canLoadOld) {
        CGPoint contentOffsetPoint = tableView.contentOffset;
        CGRect frame = tableView.frame;
        if (contentOffsetPoint.y == tableView.contentSize.height - frame.size.height || tableView.contentSize.height < frame.size.height) 
        {
            NSLog(@"scroll to the end");
            if (!_reloading) {
                loadOld = YES;
                _reloading = YES;
                [self requestResultFromServer];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

/*
 第一次进来
 http://i.snssdk.com/essay/1/recent/?tag=joke&min_behot_time=0&count=20
 1336003210 - 1335974028（作为max_behot_time）
 滑倒底
 http://i.snssdk.com/essay/1/recent/?tag=joke&max_behot_time=1335974028&count=20
 下拉更新
 http://i.snssdk.com/essay/1/recent/?tag=joke&min_behot_time=1336003210&count=20
 */

- (void)loadUrl {
    NSString *recentUrlPrefix = [NSString stringWithFormat:@"http://c.t.qq.com/asyn/selectedAutoUpdate.php?cid=%@&top=1&turn=1&version=0&r=1339057285481&p=2&apiType=7&apiHost=http%3A%2F%2Fapi.t.qq.com&_r=1339057285481&n=20", currentCid];
    NSLog(@".........%@", recentUrlPrefix);
    
    if (loadOld && [searchDuanZiList count] > 0 ) {
        NSDictionary *lastDuanZi = [searchDuanZiList objectAtIndex:([searchDuanZiList count] - 1)];
        NSDecimalNumber *currentMinTimestampNumber = (NSDecimalNumber *)[lastDuanZi objectForKey:@"timestamp"];
        NSString *lastId = [lastDuanZi objectForKey:@"id"];
        int currentMinTimestamp = [currentMinTimestampNumber intValue];
        url = [[NSString alloc] initWithFormat:@"%@&time=%d&id=%@", recentUrlPrefix, currentMinTimestamp, lastId];
    } else {
        url = [[NSString alloc] initWithFormat:@"%@", recentUrlPrefix];
    }
    
    NSLog(@"loadUrl: %@", url);
}

- (void)requestResultFromServer {
	//抽取方法
    NSLog(@"requestResultFromServer...");
    responseData = [NSMutableData data];
    
    //NSLog(@"requestTipInfoFromServer url:%@", url);
    [self loadUrl];
    
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"requestTipInfoFromServer encoded url:%@", url);
	
    NSString *post = nil;  
	post = [[NSString alloc] initWithString:@""];
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];  
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];  
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];  
	[request setURL:[NSURL URLWithString:url]];  
	[request setHTTPMethod:@"GET"]; 
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
    [request setValue:@"http://c.t.qq.com/i/843?top=1" forHTTPHeaderField:@"Referer"];
	[request setHTTPBody:postData];  
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.labelText = @"努力加载中...";
    [HUD setOpacity:1.0f];
}
#pragma mark -
#pragma mark HTTP Response Methods
//HTTP Response - begin
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {  
    NSLog(@"didReceiveResponse...");
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [HUD hide:YES afterDelay:0];
}
/*
 {
     "message": "success",
     "data": [
         {
         "verified_tag": "joke",
         "large_url": "",
         "user_id": 84223809,
         "screen_name": "\u7cd7\u4e8b\u767e\u79d1",     //微博名称
         "bury_count": 0,                               //踩次数
         "profile_image_url": "http://tp1.sinaimg.cn/1850235592/50/5615293852/1", //微博头像
         "timestamp": 1335963205,                       //微博发送时间
         "data_url": "http://weibo.com/1850235592/ybY1U0J88",   //微博地址
         "share_url": "http://www.xiangping.com/detail/e91702210/", 
         "middle_url": "",
         "content": "\u80cc\u666f\u5c0f\u59e8\u5b50\u6700\u8fd1\u8ddf\u8001\u5a46\u6709\u70b9\u95f9\u60c5\u7eea\u2026\u2026\u521a\u521a\u665a\u4e0a\u5c0f\u59e8\u5b50\u6765\u6211\u5bb6\u5403\u996d\uff0c\u7a7f\u4e86\u6761\u9f50x\u5c0f\u77ed\u88d9\u3002\u8001\u5a46\u95ee\u5979\u8fd9\u4e48\u665a\u7a7f\u8fd9\u4e48\u77ed\u7ed9\u8c01\u770b\uff0c\u5c0f\u59e8\u5b50\u4e0d\u5047\u601d\u7d22\u7684\u6765\u4e86\u53e5\u201c\u7ed9\u6211\u59d0\u592b\u770b\u7684\u2026\u2026\u201d\uff0c\u6211\u77ac\u95f4\u5821\u5792\u4e86\uff01\uff01\uff01  ",                              //微博文字内容
         "width": 0,
         "thumbnail_url": "",
         "comments_count": 202,                             //评论次数
         "image_width": 0,
         "image_height": 0,
         "digg_count": 0,
         "height": 0,
         "id": 7489223,
         "favorite_count": 0                               //赞次数
         },...
     ],
     "total_number": 20
 } 
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"CafeCarFirstViewController.connectionDidFinishLoading...");
    [HUD hide:YES afterDelay:0];
    
    /*
     机场列表响应 http:// fd.tourbox.me/getAirportList
     */
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //NSLog(responseString);
    NSDictionary *responseInfo = [UMSNSStringJson JSONValue:responseString]; 
    NSDictionary *dataDic = [responseInfo objectForKey:@"info"];
    NSMutableArray *addedList = [dataDic objectForKey:@"talk"];
    tempPropertyDic = [dataDic objectForKey:@"selectedMap"];
    NSLog(@"result: %@", addedList);
    
    [self performSelectorOnMainThread:@selector(appendTableWith:) withObject:addedList waitUntilDone:NO];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

- (NSString *)autoCorrectNull:(NSString *)input {
    if (input == nil || input == [NSNull null]) {
        return @"";
    }
    return input;
}
//从享评接口格式适配到腾讯微频道接口格式
- (void)adaptDic:(NSMutableDictionary *)dic {
    NSString *idString = [self autoCorrectNull:[dic objectForKey:@"id"]];
    NSString *screenName = [self autoCorrectNull:[dic objectForKey:@"nick"]];
    NSString *profileImageUrl = [self autoCorrectNull:[dic objectForKey:@"pic"]];
    NSString *weiboContent = [self autoCorrectNull:[dic objectForKey:@"content"]];

    NSDecimalNumber *favoriteCount = (NSDecimalNumber *)[dic objectForKey:@"count"];
    NSDecimalNumber *buryCount = [[NSDecimalNumber alloc] initWithInt:([favoriteCount intValue]/5)];
    NSDecimalNumber *commentCount = [[NSDecimalNumber alloc] initWithInt:([favoriteCount intValue]/3)];
    
    [dic setObject:screenName forKey:@"screen_name"];
    [dic setObject:profileImageUrl forKey:@"profile_image_url"];
    [dic setObject:[weiboContent stringByConvertingHTMLToPlainText] forKey:@"content"];
    [dic setObject:favoriteCount forKey:@"favorite_count"];
    [dic setObject:buryCount forKey:@"bury_count"];
    [dic setObject:commentCount forKey:@"comments_count"];
    
    NSArray *imageArray = [dic objectForKey:@"image"];
    if ( imageArray != nil && [imageArray count] != 0) {
        NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@/2000", [imageArray objectAtIndex:0]];
        [dic setObject:imageUrl forKey:@"large_url"];    //图片内容的url
    } else {
        [dic setObject:@"" forKey:@"large_url"];
    }
    
    [dic setObject:[[tempPropertyDic objectForKey:idString] objectForKey:@"width"] forKey:@"width"];//图片内容的width
    [dic setObject:[[tempPropertyDic objectForKey:idString] objectForKey:@"height"] forKey:@"height"];//图片内容的height
}

//- (void)viewWillAppear:(BOOL)animated {
//    [self loadCollectedIds];
//}

- (void)loadCollectedIds {
    FMDatabase *db= [FMDatabase databaseWithPath:[[NoneAdultAppDelegate sharedAppDelegate] getDbPath]] ;  
    if (![db open]) {  
        NSLog(@"Could not open db."); 
        return ;  
    } 
    
    collectedIdsDic = [[NSMutableDictionary alloc] init];
    FMResultSet *rs=[db executeQuery:@"SELECT * FROM collected ORDER BY collect_time DESC"];
    while ([rs next]){
        NSString *weiboId = [NSString stringWithFormat:@"%lld", [rs longLongIntForColumn:@"weiboId"]];
        [collectedIdsDic setObject:[[NSNumber alloc] initWithInt:1] forKey:weiboId];
    }
}

- (void)loadDingIds {
    FMDatabase *db= [FMDatabase databaseWithPath:[[NoneAdultAppDelegate sharedAppDelegate] getDbPath]] ;  
    if (![db open]) {  
        NSLog(@"Could not open db."); 
        return ;  
    } 
    
    dingIdsDic = [[NSMutableDictionary alloc] init];
    FMResultSet *rs=[db executeQuery:@"SELECT * FROM ding ORDER BY collect_time DESC"];
    while ([rs next]){
        NSString *weiboId = [NSString stringWithFormat:@"%lld", [rs longLongIntForColumn:@"weiboId"]];
        [dingIdsDic setObject:[[NSNumber alloc] initWithInt:1] forKey:weiboId];
    }
}

- (void)checkDing:(NSMutableDictionary *)dic {
    NSString *idString = [dic objectForKey:@"id"];
    
    if ([dingIdsDic objectForKey:idString] != nil) {
        //NSLog(@"idString YES: %@", idString);
        [dic setObject:@"YES" forKey:@"ding_tag"];
    } else {
        //NSLog(@"idString NO: %@", idString);
        [dic setObject:@"NO" forKey:@"ding_tag"];
    }
}

- (void)checkCollected:(NSMutableDictionary *)dic {
    NSString *idString = [dic objectForKey:@"id"];
    
    if ([collectedIdsDic objectForKey:idString] != nil) {
        //NSLog(@"idString YES: %@", idString);
        [dic setObject:@"YES" forKey:@"collected_tag"];
    } else {
        //NSLog(@"idString NO: %@", idString);
        [dic setObject:@"NO" forKey:@"collected_tag"];
    }
}

-(void)appendTableWith:(NSMutableArray *)data
{
    [self loadCollectedIds];
    [self loadDingIds];
    int minWordCount = 40;
    NSMutableDictionary *dic = nil;
    if (loadOld) {
        for (int i=0;i<[data count];i++) {
            dic = [data objectAtIndex:i];
            [self adaptDic:dic];
            [self checkCollected:dic];
            [self checkDing:dic];
/*
            [originalNewDuanZiList addObject:dic];
 */
            NSString *largeUrl = [dic objectForKey:@"large_url"];
            if ([largeUrl isEqualToString:@""]) {
                continue;
            }
            [searchDuanZiList addObject:dic];
        }
    } else {
        for (int i=[data count]-1;i>=0;i--) {
            dic = [data objectAtIndex:i];
            [self adaptDic:dic];
            [self checkCollected:dic];
            [self checkDing:dic];

/*
            [originalNewDuanZiList insertObject:dic atIndex:0];
 */
            NSString *largeUrl = [dic objectForKey:@"large_url"];
            if ([largeUrl isEqualToString:@""]) {
                continue;
            }
            [searchDuanZiList insertObject:dic atIndex:0];
        }
    }
    
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:10];
    for (int ind = 0; ind < [data count]; ind++) {
        int row = [searchDuanZiList indexOfObject:[data objectAtIndex:ind]];
        NSIndexPath *newPath =  [NSIndexPath indexPathForRow:row inSection:0];
        [insertIndexPaths addObject:newPath];
    }
    //[tableView beginUpdates];
    //[self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
    //[tableView endUpdates];
    _reloading = NO;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int row = [indexPath row];
    NSDictionary *duanZi = [searchDuanZiList objectAtIndex:row];
    
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    
    CGRect imageDisplayRect = [self getImageDisplayRect:duanZi];    
    
    return cell.frame.size.height + TOP_SECTION_HEIGHT + BOTTOM_SECTION_HEIGHT + imageDisplayRect.size.height;

//    return cell.frame.size.height + TOP_SECTION_HEIGHT + BOTTOM_SECTION_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchDuanZiList count];
}


-(void)goShare:(id)sender{  
    //这个sender其实就是UIButton，因此通过sender.tag就可以拿到刚才的参数  
    int i = [sender tag] - 1000;
    currentDuanZi = [searchDuanZiList objectAtIndex:i];
    [self shareDuanZi];
}
- (void)shareDuanZi {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"分享到" 
                                                             delegate:self
                                                    cancelButtonTitle:@"取消" 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles: @"新浪微博",@"腾讯微博",@"复制文本", nil];//@"邮件分享", nil];     
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

-(void)goCollect:(id)sender{  
    //这个sender其实就是UIButton，因此通过sender.tag就可以拿到刚才的参数  
    int i = [sender tag] - 2000;
    
    //得到网络图片的实际大小
    
    currentDuanZi = [searchDuanZiList objectAtIndex:i];
    
    BOOL tag = YES;
    NSString *collectedTag = [currentDuanZi objectForKey:@"collected_tag"];
    if ([collectedTag isEqual:@"YES"]) {
        tag = NO;
        [currentDuanZi setObject:@"NO" forKey:@"collected_tag"];
    } else {
        tag = YES;
        [currentDuanZi setObject:@"YES" forKey:@"collected_tag"];
    }
    [self toggleCollect:tag withSender:sender];
    [self collectHUDMessage:tag]; 
    [self collectDuanZi:tag];
    [self sendToParseDB:tag];
}

- (void)sendToParseDB:(BOOL)tag {
    //初期用于提纯内容的，和审核的
    PFUser *user = [PFUser currentUser];
    if (user && [user.username isEqualToString:@"drawinghelper@gmail.com"]
        && ([self.title isEqualToString:@"最新"] || [self.title isEqualToString:@"微博"])) {
        [self storeIntoParseDB:tag withClassName:@"newfiltered"];
    }
}

-(void)goDing:(id)sender {
    int i = [sender tag] - 3000;
    currentDuanZi = [searchDuanZiList objectAtIndex:i];
    
    BOOL tag = YES;
    NSString *dingTag = [currentDuanZi objectForKey:@"ding_tag"];
    if ([dingTag isEqual:@"YES"]) {
        tag = NO;
        [currentDuanZi setObject:@"NO" forKey:@"ding_tag"];
    } else {
        tag = YES;
        [currentDuanZi setObject:@"YES" forKey:@"ding_tag"];
    }
    [self toggleDing:tag withSender:sender];
    [self dingDuanZi:tag];
    //初期用于提纯内容的，和审核的
    [self storeIntoParseDB:tag withClassName:@"newfiltered"];
}

- (void)storeIntoParseDB:(BOOL)tag withClassName:(NSString *)className {
    if (!tag) {
        return;
    }

    PFObject *newFiltered = [PFObject objectWithClassName:className];
    //PFObject *newFiltered = [PFObject objectWithClassName:@"historytop"];
    [newFiltered setObject:[currentDuanZi objectForKey:@"id"] forKey:@"weiboId"];
    [newFiltered setObject:[currentDuanZi objectForKey:@"profile_image_url"] forKey:@"profile_image_url"];
    [newFiltered setObject:[currentDuanZi objectForKey:@"screen_name"] forKey:@"screen_name"];
    [newFiltered setObject:[currentDuanZi objectForKey:@"content"] forKey:@"content"];
    [newFiltered setObject:[currentDuanZi objectForKey:@"favorite_count"] forKey:@"favorite_count"];
    [newFiltered setObject:[currentDuanZi objectForKey:@"bury_count"] forKey:@"bury_count"];
    [newFiltered setObject:[currentDuanZi objectForKey:@"comments_count"] forKey:@"comments_count"];
    [newFiltered setObject:[currentDuanZi objectForKey:@"timestamp"] forKey:@"timestamp"];

    [newFiltered setObject:[currentDuanZi objectForKey:@"large_url"] forKey:@"large_url"];
    NSNumber *imageWidth = [currentDuanZi objectForKey:@"width"];
    NSNumber *imageHeight = [currentDuanZi objectForKey:@"height"];
    if ([self.title isEqualToString:@"微博"]) {
        imageWidth = [currentDuanZi objectForKey:@"width_weibo"];
        imageHeight = [currentDuanZi objectForKey:@"height_weibo"];
    }

    [newFiltered setObject:imageWidth forKey:@"width"];
    [newFiltered setObject:imageHeight forKey:@"height"];
    //feature 媒体类型ID，0：图片、1：视频、2：音乐，默认为0。
    [newFiltered setObject:[[NSNumber alloc] initWithInt:0] forKey:@"feature"];
    //是否动态图，feature为0时有意义
    [newFiltered setObject:[[NSNumber alloc] initWithInt:0] forKey:@"gif_mark"];
    [newFiltered setObject:[currentDuanZi objectForKey:@"shareurl"] forKey:@"shareurl"];
    [newFiltered setObject:[[NSNumber alloc] initWithInt:0] forKey:@"score"];
    
    [newFiltered saveEventually];
}
    
-(void)toggleCollect:(BOOL)tag withSender:(id)sender {
    UIButton *heartButton = (UIButton *)sender;
    UIImage *btnStarImage = [UIImage imageNamed:@"star.png"];
    UIImage *btnStarImagePressed = [UIImage imageNamed:@"star_pressed.png"];
    if (tag) {
        [heartButton setImage:btnStarImagePressed forState:UIControlStateNormal];
        [heartButton setImage:btnStarImage forState:UIControlStateHighlighted];
    } else {
        [heartButton setImage:btnStarImage forState:UIControlStateNormal];
        [heartButton setImage:btnStarImagePressed forState:UIControlStateHighlighted];
    }
}

-(void)toggleDing:(BOOL)tag withSender:(id)sender {
    UIButton *dingButton = (UIButton *)sender;
    UIImage *btnDingImage = [UIImage imageNamed:@"ding.png"];
    UIImage *btnDingImagePressed = [UIImage imageNamed:@"ding_pressed.png"];
    if (tag) {
        [dingButton setImage:btnDingImagePressed forState:UIControlStateNormal];
        [dingButton setImage:btnDingImage forState:UIControlStateHighlighted];
    } else {
        [dingButton setImage:btnDingImage forState:UIControlStateNormal];
        [dingButton setImage:btnDingImagePressed forState:UIControlStateHighlighted];
    }
}
/*
 YES - 顶成功
 NO - 取消顶
 */
- (void)dingDuanZi:(BOOL)tag {
    FMDatabase *db= [FMDatabase databaseWithPath:[[NoneAdultAppDelegate sharedAppDelegate] getDbPath]] ;  
    if (![db open]) {  
        NSLog(@"Could not open db."); 
        return ;  
    }
    if (tag) {
        NSDate *nowDate = [[NSDate alloc] init];
        NSArray *dataArray = [NSArray arrayWithObjects:
                              [currentDuanZi objectForKey:@"id"], 
                              [currentDuanZi objectForKey:@"profile_image_url"], 
                              [currentDuanZi objectForKey:@"screen_name"],
                              [currentDuanZi objectForKey:@"timestamp"],
                              [currentDuanZi objectForKey:@"content"],
                              
                              [currentDuanZi objectForKey:@"large_url"], 
                              [currentDuanZi objectForKey:@"width"],
                              [currentDuanZi objectForKey:@"height"],
                              [[NSNumber alloc] initWithInt:0],
                              
                              [currentDuanZi objectForKey:@"favorite_count"], 
                              [currentDuanZi objectForKey:@"bury_count"],
                              [currentDuanZi objectForKey:@"comments_count"],
                              [[NSNumber alloc] initWithLongLong:[nowDate timeIntervalSince1970]],
                              //[currentDuanZi objectForKey:@"collect_time"],
                              nil
                              ];
        [db executeUpdate:@"replace into ding(weiboId, profile_image_url, screen_name, timestamp, content, large_url, width, height, gif_mark, favorite_count, bury_count, comments_count, collect_time) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" withArgumentsInArray:dataArray];
    } else {
        NSArray *dataArray = [NSArray arrayWithObjects:[currentDuanZi objectForKey:@"id"], nil];
        [db executeUpdate:@"delete from ding where weiboId = ?" withArgumentsInArray:dataArray];
    }
}

/*
 YES - 收藏成功
 NO - 取消收藏
 */
- (void)collectDuanZi:(BOOL)tag {
    FMDatabase *db= [FMDatabase databaseWithPath:[[NoneAdultAppDelegate sharedAppDelegate] getDbPath]] ;  
    if (![db open]) {  
        NSLog(@"Could not open db."); 
        return ;  
    }
    if (tag) {
        NSDate *nowDate = [[NSDate alloc] init];
        NSNumber *imageWidth = [currentDuanZi objectForKey:@"width"];
        NSNumber *imageHeight = [currentDuanZi objectForKey:@"height"];
        if ([self.title isEqualToString:@"微博"]) {
            imageWidth = [currentDuanZi objectForKey:@"width_weibo"];
            imageHeight = [currentDuanZi objectForKey:@"height_weibo"];
        }
        
        NSArray *dataArray = [NSArray arrayWithObjects:
                              [currentDuanZi objectForKey:@"id"], 
                              [currentDuanZi objectForKey:@"profile_image_url"], 
                              [currentDuanZi objectForKey:@"screen_name"],
                              [currentDuanZi objectForKey:@"timestamp"],
                              [currentDuanZi objectForKey:@"content"],
                              
                              [currentDuanZi objectForKey:@"large_url"], 
                              imageWidth,
                              imageHeight,
                              [[NSNumber alloc] initWithInt:0],
                              
                              [currentDuanZi objectForKey:@"favorite_count"], 
                              [currentDuanZi objectForKey:@"bury_count"],
                              [currentDuanZi objectForKey:@"comments_count"],
                              [[NSNumber alloc] initWithLongLong:[nowDate timeIntervalSince1970]],
                              [currentDuanZi objectForKey:@"shareurl"],
                              nil
                              ];
        [db executeUpdate:@"replace into collected(weiboId, profile_image_url, screen_name, timestamp, content, large_url, width, height, gif_mark, favorite_count, bury_count, comments_count, collect_time, share_url) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" withArgumentsInArray:dataArray];
    } else {
        NSArray *dataArray = [NSArray arrayWithObjects:[currentDuanZi objectForKey:@"id"], nil];
        [db executeUpdate:@"delete from collected where weiboId = ?" withArgumentsInArray:dataArray];
    }
    
}

/*
 YES - 收藏成功，
 NO - 取消收藏
*/
-(void)collectHUDMessage:(BOOL)tag{
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	HUD.mode = MBProgressHUDModeText;
    if (tag) {
        HUD.labelText = @"收藏成功";
    } else {
        HUD.labelText = @"取消收藏";
    }
	HUD.margin = 10.f;
	HUD.yOffset = 150.f;
	HUD.removeFromSuperViewOnHide = YES;
	[HUD hide:YES afterDelay:0.5f];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSString *statusContent = nil;
        NSString *weiboContent = [currentDuanZi objectForKey:@"content"];
        NSString *cuttedContent = [[NSString alloc] initWithString:weiboContent];
        int cuttedLength = 136;
        if (cuttedLength < [weiboContent length]) {
            cuttedContent = [weiboContent substringToIndex:cuttedLength];
        }
        statusContent = [NSString stringWithString:cuttedContent];
        NSString *largeUrl = [currentDuanZi objectForKey:@"large_url"];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        UIImage *shareImage = [manager imageWithURL:[NSURL URLWithString:largeUrl]];

        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            NSLog(@"custom event share_sina_budong!");
            /*[MobClick event:@"share_sina_budong"];*/
            [UMSNSService presentSNSInController:self 
                                          appkey:[[NoneAdultAppDelegate sharedAppDelegate] getUmengAppKey] 
                                          status:statusContent 
                                           image:shareImage 
                                        platform:UMShareToTypeSina];
            
            [UMSNSService setDataSendDelegate:self];
            return;
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
            NSLog(@"custom event share_sina_haoxiao!");            
            [UMSNSService presentSNSInController:self 
                                          appkey:[[NoneAdultAppDelegate sharedAppDelegate] getUmengAppKey] 
                                          status:statusContent 
                                           image:shareImage 
                                        platform:UMShareToTypeTenc];
            
            [UMSNSService setDataSendDelegate:self];
            return;
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
            NSLog(@"custom event share_email!");
            /*[MobClick event:@"share_email"];
             [self emailPhoto]; 
             */
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = weiboContent;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"文字内容已成功复制到剪贴板"
                                                                 message:nil
                                                                delegate:self
                                                       cancelButtonTitle:@"确定"
                                                       otherButtonTitles:nil];
            [alertView show];
            
            return;  
        }
    }
}
#pragma mark - Action Sheet Delegate
- (void)dataSendDidFinish:(UIViewController *)viewController andReturnStatus:(UMReturnStatusType)returnStatus andPlatformType:(UMShareToType)platfrom {
    [viewController dismissModalViewControllerAnimated:YES];
}

- (CGRect)getImageDisplayRect:(NSDictionary *)duanZi {
    CGRect rect;
    
    int imageDisplayLeft = 0;
    int imageDisplayTop = TOP_SECTION_HEIGHT;
    int imageDisplayWidth = 320;
    int imageDisplayHeight = 0;
    
    int width = [[duanZi objectForKey:@"width"] intValue];
    int height = [[duanZi objectForKey:@"height"] intValue];
    if (width > (320 - 2*HORIZONTAL_PADDING)) {
        imageDisplayLeft = HORIZONTAL_PADDING;
        imageDisplayWidth = 320 - 2*HORIZONTAL_PADDING;
        imageDisplayHeight = (height * imageDisplayWidth) / width; 
    } else {
        imageDisplayLeft = (320 - width)/2;
        imageDisplayWidth = width;
        imageDisplayHeight = height;
    }
    
    rect.origin.x = imageDisplayLeft; 
    rect.origin.y = imageDisplayTop;
    rect.size.width = imageDisplayWidth; 
    rect.size.height = imageDisplayHeight;
    return rect;
}

- (void)fadeInLayer:(CALayer *)l
{
    CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimate.duration            = 0.5;
    fadeInAnimate.repeatCount         = 1;
    fadeInAnimate.autoreverses        = NO;
    fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
    fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
    fadeInAnimate.removedOnCompletion = YES;
    [l addAnimation:fadeInAnimate forKey:@"animateOpacity"];
    return;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int row = [indexPath row];
    NSMutableDictionary *duanZi = [searchDuanZiList objectAtIndex:row];
    
    static NSString *CellIdentifier = @"OffenceCustomCellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //清除已有数据，防止文字重叠
    for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
    }
    //【顶部】
    UIView *topBgView = [[UIView alloc] initWithFrame:CGRectZero];
    [cell.contentView addSubview:topBgView];
    //[bottomBgView setBackgroundColor:[UIColor lightGrayColor]];
    [topBgView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"duanzi_bg_top.png"]]];
    [topBgView setFrame:CGRectMake(0, 0, 320, TOP_SECTION_HEIGHT)]; 
    
    //微博名
    UILabel *brandNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(TOP_SECTION_HEIGHT+5, -3, 320 - TOP_SECTION_HEIGHT, TOP_SECTION_HEIGHT)];
    brandNameLabel.textAlignment = UITextAlignmentLeft;
    brandNameLabel.text = [duanZi objectForKey:@"screen_name"];
    brandNameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    brandNameLabel.textColor = [UIColor darkGrayColor];
    brandNameLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:brandNameLabel];
    //发布时间
    UILabel *timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(TOP_SECTION_HEIGHT+5, 29, 320 - TOP_SECTION_HEIGHT, TOP_SECTION_HEIGHT-30)];
    timestampLabel.textAlignment = UITextAlignmentLeft;
    NSDecimalNumber *number = (NSDecimalNumber *)[duanZi objectForKey:@"timestamp"];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[number doubleValue]];
    
    NSDateFormatter *dateTimeFormatter=[[NSDateFormatter alloc] init];
    [dateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    timestampLabel.text = [dateTimeFormatter stringFromDate:date];   
    timestampLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
    timestampLabel.textColor = [UIColor darkGrayColor];
    timestampLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:timestampLabel];
    
    //微博头像
    UIImageView *brandLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shi.jpeg"]];
    [brandLogoImageView setFrame:CGRectMake(17, 13, TOP_SECTION_HEIGHT-20, TOP_SECTION_HEIGHT-20)];        
    [cell.contentView addSubview:brandLogoImageView];
    [brandLogoImageView setImageWithURL:[NSURL URLWithString:[duanZi objectForKey:@"profile_image_url"]] 
                       placeholderImage:[UIImage imageNamed:@"shi.jpeg"]];
    CALayer *layer = [brandLogoImageView layer];  
    [layer setMasksToBounds:YES];  
    [layer setCornerRadius:1.5];  
    [layer setBorderWidth:1.0];  
    [layer setBorderColor:[[UIColor clearColor] CGColor]];  
    
    //分享的按钮
    UIButton *btnTwo = [UIButton buttonWithType:UIButtonTypeCustom]; 
    btnTwo.frame = CGRectMake(320 - 15 - 35, 10, 40, 40);
    [btnTwo setTitle:@"" forState:UIControlStateNormal];
    [btnTwo setTag:(row + 1000)];
    
    [btnTwo addTarget:self action:@selector(goShare:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnTwo];
    UIImage *btnImage = [UIImage imageNamed:@"share_normal.png"];
    [btnTwo setImage:btnImage forState:UIControlStateNormal];
    
    //【中部】
    //微博内容
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.tag = 1;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.highlightedTextColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    label.opaque = NO; // 选中Opaque表示视图后面的任何内容都不应该绘制
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"STHeiti K" size:14];
    //label.font = [UIFont fontWithName:@"STHeiti SC" size:16];
    label.textColor = [UIColor colorWithRed:109.0f/255 green:109.0f/225 blue:109.0f/255 alpha:1]; 

    //[[label layer] setBorderWidth:1.0f];
    //[[label layer] setBorderColor:[NoneAdultAppDelegate getColorFromRed:255 Green:0 Blue:0 Alpha:100]];
    //[[label layer] setBackgroundColor:[NoneAdultAppDelegate getColorFromRed:200 Green:200 Blue:200 Alpha:100]];
    [cell.contentView addSubview:label];
    [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"duanzi_bg_middle.png"]]];
    
    //微博图
    UIImageView *coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"defaultCover.png"]];
    NSString *largeUrl = [duanZi objectForKey:@"large_url"];
    if ( largeUrl != nil && ![largeUrl isEqualToString:@""]) {
        [coverImageView setImageWithURL:[NSURL URLWithString:largeUrl] 
                       placeholderImage:[UIImage imageNamed:@"defaultCover.png"] 
                                success:^(UIImage *image) {
                                    // do something with image
                                    [self fadeInLayer:coverImageView.layer];
                                    if ([self.title isEqualToString:@"微博"]) {
                                        [duanZi setObject:[NSNumber numberWithInt:image.size.width] forKey:@"width_weibo"];
                                        [duanZi setObject:[NSNumber numberWithInt:image.size.height] forKey:@"height_weibo"];
                                    }
                                } 
                                failure:nil
         ];
        
        [cell.contentView addSubview:coverImageView];
    }
    
    //【底部】
    UIView *bottomBgView = [[UIView alloc] initWithFrame:CGRectZero];
    [cell.contentView addSubview:bottomBgView];
    //[bottomBgView setBackgroundColor:[UIColor lightGrayColor]];
    [bottomBgView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"duanzi_bg_bottom.png"]]];
    bottomBgView.tag = 1000;
    
    //顶踩评
    UILabel *dingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    NSDecimalNumber *favoriteCount = (NSDecimalNumber *)[duanZi objectForKey:@"favorite_count"];
    dingLabel.text = [NSString stringWithFormat:@"顶: %@",[favoriteCount stringValue]];
    dingLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    [dingLabel setBackgroundColor:[UIColor clearColor]];
    dingLabel.textColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1];
    [cell.contentView addSubview:dingLabel];
    dingLabel.tag = 2;

    UILabel *caiLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    NSDecimalNumber *buryCount = (NSDecimalNumber *)[duanZi objectForKey:@"bury_count"];
    caiLabel.text = [NSString stringWithFormat:@"踩: %@",[buryCount stringValue]];
    caiLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    [caiLabel setBackgroundColor:[UIColor clearColor]];
    caiLabel.textColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1];
    [cell.contentView addSubview:caiLabel];
    caiLabel.tag = 3;

    UILabel *pingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    NSDecimalNumber *commentsCount = (NSDecimalNumber *)[duanZi objectForKey:@"comments_count"];
    pingLabel.text = [NSString stringWithFormat:@"评: %@",[commentsCount stringValue]];
    //pingLabel.textAlignment = UITextAlignmentRight;
    pingLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    [pingLabel setBackgroundColor:[UIColor clearColor]];
    pingLabel.textColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1];
    [cell.contentView addSubview:pingLabel];
    pingLabel.tag = 4;
    
    //content图片内容自适应
    CGRect imageDisplayRect = [self getImageDisplayRect:duanZi];    
    imageDisplayRect.origin.y = imageDisplayRect.origin.y + 5;
    [coverImageView setFrame:imageDisplayRect];
    
    
    //content文字内容自适应
    label = (UILabel *)[cell viewWithTag:1];
    CGRect cellFrame = [cell frame];
    cellFrame.origin = CGPointMake(15, TOP_SECTION_HEIGHT + imageDisplayRect.size.height + 8);
    cellFrame.size.width = 320 - 30;

    label.text = [duanZi objectForKey:@"content"];
    CGRect rect = CGRectInset(cellFrame, 2, 2);
    label.frame = rect;
    [label sizeToFit];
    cellFrame.size.height = 13 + label.frame.size.height;

    
    [bottomBgView setFrame:CGRectMake(0, cellFrame.size.height + imageDisplayRect.size.height + TOP_SECTION_HEIGHT, 320, BOTTOM_SECTION_HEIGHT)];

    
    dingLabel = (UILabel *)[cell viewWithTag:2];
    [dingLabel setFrame:CGRectMake(17, cellFrame.size.height + TOP_SECTION_HEIGHT - 3 + imageDisplayRect.size.height, 60, BOTTOM_SECTION_HEIGHT)];
    caiLabel = (UILabel *)[cell viewWithTag:3];
    [caiLabel setFrame:CGRectMake(77, cellFrame.size.height + TOP_SECTION_HEIGHT - 3 + imageDisplayRect.size.height, 60, BOTTOM_SECTION_HEIGHT)];
    pingLabel = (UILabel *)[cell viewWithTag:4];
    [pingLabel setFrame:CGRectMake(135, cellFrame.size.height + TOP_SECTION_HEIGHT - 3 + imageDisplayRect.size.height, 60, BOTTOM_SECTION_HEIGHT)];

    //顶按钮（审核精选）
    PFUser *user = [PFUser currentUser];
    if (user && [user.username isEqualToString:@"drawinghelper@gmail.com"]
        && [self.title isEqualToString:@"最新"]) {
        UIButton *btnDing = [UIButton buttonWithType:UIButtonTypeCustom]; 
        [btnDing setTitle:@"" forState:UIControlStateNormal];
        [btnDing setTag:(row + 3000)];
        [btnDing addTarget:self action:@selector(goDing:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnDing];
        UIImage *btnDingImage = [UIImage imageNamed:@"ding.png"];
        UIImage *btnDingImagePressed = [UIImage imageNamed:@"ding_pressed.png"];
        if ([[duanZi objectForKey:@"ding_tag"] isEqual:@"YES"]) {
            [btnDing setImage:btnDingImagePressed forState:UIControlStateNormal];
            [btnDing setImage:btnDingImage forState:UIControlStateHighlighted];
        } else {
            [btnDing setImage:btnDingImage forState:UIControlStateNormal];
            [btnDing setImage:btnDingImagePressed forState:UIControlStateHighlighted];
        }
        [btnDing setFrame:CGRectMake(210, cellFrame.size.height + TOP_SECTION_HEIGHT - 3 + imageDisplayRect.size.height, 20, BOTTOM_SECTION_HEIGHT)];
    }
    
    //收藏按钮（审核最热）
    UIButton *btnStar = [UIButton buttonWithType:UIButtonTypeCustom]; 
    [btnStar setTitle:@"" forState:UIControlStateNormal];
    [btnStar setTag:(row + 2000)];
    [btnStar addTarget:self action:@selector(goCollect:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnStar];
    UIImage *btnStarImage = [UIImage imageNamed:@"star.png"];
    UIImage *btnStarImagePressed = [UIImage imageNamed:@"star_pressed.png"];
    if ([[duanZi objectForKey:@"collected_tag"] isEqual:@"YES"]) {
        [btnStar setImage:btnStarImagePressed forState:UIControlStateNormal];
        [btnStar setImage:btnStarImage forState:UIControlStateHighlighted];
    } else {
        [btnStar setImage:btnStarImage forState:UIControlStateNormal];
        [btnStar setImage:btnStarImagePressed forState:UIControlStateHighlighted];
    }
    [btnStar setFrame:CGRectMake(280, cellFrame.size.height + TOP_SECTION_HEIGHT - 3 + imageDisplayRect.size.height, 20, BOTTOM_SECTION_HEIGHT)];
    
    [cell setFrame:cellFrame];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"didSelectRowAtIndexPath...");
    /*
    int row = [indexPath row];
    NSDictionary *duanZi = [searchDuanZiList objectAtIndex:row];
    NoneAdultDetailViewController *detailViewController = [[NoneAdultDetailViewController alloc]initWithNibName:@"NoneAdultDetailViewController" bundle:nil];
    detailViewController.title = @"笑话详情";
    detailViewController.currentDuanZi = duanZi;
    detailViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailViewController animated:YES];
    detailViewController.hidesBottomBarWhenPushed = NO;//马上设置回NO
    currentDuanZi = [searchDuanZiList objectAtIndex:row];
    [self shareDuanZi];
     */
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
