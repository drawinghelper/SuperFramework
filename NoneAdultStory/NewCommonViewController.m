//
//  NewCommonViewController.m
//  NoneAdultStory
//
//  Created by 王 攀 on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewCommonViewController.h"
#import "UITabBarController+hidable.h"

@interface NewCommonViewController ()

@end

@implementation NewCommonViewController
{
    CGFloat startContentOffset;
    CGFloat lastContentOffset;
    BOOL hidden;
}

@synthesize tableView;
//@synthesize adView;
@synthesize keyword;
@synthesize flowView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTitle:(NSString *)title withCategory:(int)pCategory withKeyword:(NSString *)pKeyword withViewType:(int)pViewType;
{
    category = pCategory;
    keyword = pKeyword;
    viewType = pViewType;
    //0 - 最新； 1 - 最热； 2 - 分类； 3 - 收藏
    switch (pViewType) {
        case 0:
        case 2:
            canLoadOld = YES;
            canLoadNew = YES;
            shouldExpandContract = YES;
            shouldScore = YES;
            //numOfPagesize = 10;
            numOfPagesize = 20;
            break;
        case 1:
            canLoadOld = NO;
            canLoadNew = YES;
            shouldExpandContract = YES;
            shouldScore = NO;
            numOfPagesize = 50;
            break;
        case 3:
            canLoadOld = NO;
            canLoadNew = NO;
            shouldExpandContract = NO;
            shouldScore = NO;
            numOfPagesize = 10000;
            break;
        default:
            break;
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(title, @"First");
        if (viewType == 1) {
            self.tabBarItem.image = [UIImage imageNamed:@"historyhot"];
        } else {
            self.tabBarItem.image = [UIImage imageNamed:@"new"];
        }
        
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

/*
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
    newFrame.origin.y = 0;
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
*/
- (void)viewDidAppear:(BOOL)animated
{
    [adView continueAdRequest];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [adView pauseAdRequest];
    if (shouldExpandContract) {
        [self contract];
    }
}
- (void)showLianMeng {
    UMTableViewDemo *lianMengViewController = [[UMTableViewDemo alloc]init];
    lianMengViewController.title = @"精彩应用推荐";
    lianMengViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lianMengViewController animated:YES];
}

#pragma mark - AdSageDelegate
- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}


- (void)rankClick:(id)sender {
    if (self.rankView.isAppeared) {
        UIButton *rankbtn = (UIButton *) sender;
        rankbtn.selected = YES;
        self.rankBtnv.selected = YES;
        [self.rankBtnv doArrow];
        [self.rankView disappeared];
    }
    else {
        self.rankBtnv.selected = NO;
        [self.rankBtnv doArrow];
        [self.rankView appeared];
    }
}

- (void)rankbtnselected:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *) sender;
        NSString *text = @"今日最热";
        NSString *previousType = [NSString stringWithString:type];
        if (btn.tag == 0) {
            text = @"今日最热";
            type = @"day";
        } else if (btn.tag == 1) {
            text = @"本周最热";
            type = @"week";
        } else if (btn.tag == 2) {
            text = @"本月最热";
            type = @"month";
        }
        [self.rankView disappeared];
        self.rankBtnv.selected = YES;
        [self.rankBtnv setText:text];
        [self.rankBtnv doArrow];
        if (![type isEqualToString:previousType]) { //排序选择有变化后，才需要刷新
            [self performRefresh];
        }
    }
}

- (void)loadView {
    [super loadView];
    if (viewType == 1) {
        CustomButtonView *btnView = [[CustomButtonView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        btnView.delegate = self;
        btnView.buttonClick = @selector(rankClick:);
        self.navigationItem.titleView = btnView;
        self.rankBtnv = btnView;
        
        MenuView *pop = [[MenuView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 50, 0.0f, 100.0f, 84.0f+34.5f)];
        self.rankView = pop;
        [pop addTarget:self action:@selector(rankbtnselected:)];
        [self.view addSubview:pop];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self processPullMessage];

    NSString *showAdList = [MobClick getConfigParams:@"showAdList"];
    if (showAdList == nil || showAdList == [NSNull null]  || [showAdList isEqualToString:@""]) {
        showAdList = @"NO";
    }

    if ([showAdList isEqualToString:@"YES"]) {
        //增加广告条显示
        adView = [AdSageView requestAdSageBannerAdView:self
                                              sizeType:AdSageBannerAdViewSize_320X50];
        [adView setFrame:CGRectMake(0, 0, 320, 50)];
        [self.view addSubview:adView];
    }
      
    UIButton *btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom]; 
    btnRefresh.frame = CGRectMake(0, 0, 44, 44);
    [btnRefresh addTarget:self action:@selector(performRefresh) forControlEvents:UIControlEventTouchUpInside];
    UIImage *btnImage = [UIImage imageNamed:@"refresh.png"];
    [btnRefresh setImage:btnImage forState:UIControlStateNormal];
    
    /*UIButton *btnLianMeng = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLianMeng.frame = CGRectMake(0, 0, 55, 30);
    [btnLianMeng addTarget:self action:@selector(showLianMeng) forControlEvents:UIControlEventTouchUpInside];
    [btnLianMeng setTitle:@"推荐(1)" forState:UIControlStateNormal];
    [btnLianMeng setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnLianMeng setBackgroundImage:[UIImage imageNamed:@"btn_header.png"] forState:UIControlStateNormal];
    [btnLianMeng.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
    [btnLianMeng.titleLabel setShadowOffset:CGSizeMake(0, -1.0f)];
    [btnLianMeng.titleLabel setShadowColor:[UIColor darkGrayColor]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLianMeng];
    */
    recmdView = [[MobiSageRecommendView
                  alloc]initWithDelegate:self andImg:nil];
    recmdView.frame = CGRectMake(10, 10,recmdView.frame.size.width, recmdView.frame.size.height);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:recmdView];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRefresh];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbarBackground.png"] 
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
    //canLoadNew = YES;
    //canLoadOld = YES;
    //loadOld = NO;
    _reloading = YES;
    
    type = @"day";
    [self performRefresh];
    self.tableView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1];
    
    //分类页的“返回”按钮定制化
    if (viewType == 2) {
        UIImage *buttonImage = [UIImage imageNamed:@"navigationButtonReturn.png"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
    /*
    handleView = [[UMUFPHandleView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-88, 32, 88) appKey:[[NoneAdultAppDelegate sharedAppDelegate] getUmengAppKey] slotId:nil currentViewController:self];
    handleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [handleView setHandleViewBackgroundImage:[UIImage imageNamed:@"um_handle_placeholder.png"]];
    [self.view addSubview:handleView];
    [handleView requestPromoterDataInBackground];*/
    
    //[tableView setHidden:YES];
    
    /*
    flowView = [[WaterflowView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - 44)];
    flowView.flowdatasource = self;
    flowView.flowdelegate = self;
    [self.view addSubview:flowView];
     */
}

#pragma mark-
#pragma mark- WaterflowDataSource

- (NSInteger)numberOfColumnsInFlowView:(WaterflowView *)flowView
{
    return NUMBER_OF_COLUMNS;
}

- (NSInteger)flowView:(WaterflowView *)flowView numberOfRowsInColumn:(NSInteger)column
{
    //return NUMBER_OF_PAGESIZE/NUMBER_OF_COLUMNS;
    //if ([sort isEqualToString:@"recent"]) {
        NSLog(@"recnet: %d", [searchDuanZiList count]/NUMBER_OF_COLUMNS);
        switch ([searchDuanZiList count] % NUMBER_OF_COLUMNS) {
            case 0:
                return [searchDuanZiList count]/NUMBER_OF_COLUMNS;
            case 1:
                if (column == 0) {
                    return [searchDuanZiList count]/NUMBER_OF_COLUMNS + 1;
                } else if (column == 1) {
                    return [searchDuanZiList count]/NUMBER_OF_COLUMNS;
                } else if (column == 2) {
                    return [searchDuanZiList count]/NUMBER_OF_COLUMNS;
                }
            case 2:
                if (column == 0) {
                    return [searchDuanZiList count]/NUMBER_OF_COLUMNS + 1;
                } else if (column == 1) {
                    return [searchDuanZiList count]/NUMBER_OF_COLUMNS + 1;
                } else if (column == 2) {
                    return [searchDuanZiList count]/NUMBER_OF_COLUMNS;
                }
            default:
                break;
        }
    //}
    return NUMBER_OF_HISTORY_PAGESIZE/NUMBER_OF_COLUMNS;
}

/*
 image_height      中图高度
 image_width       中图宽度
 height            大图宽度
 width             大图宽度
 */
 
- (WaterFlowCell*)flowView:(WaterflowView *)flowView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	WaterFlowCell *cell = [flowView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.flowdelegate = self;
	if(cell == nil)
	{
		cell  = [[WaterFlowCell alloc] initWithReuseIdentifier:CellIdentifier];
		
		AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectZero];
		[cell addSubview:imageView];
        imageView.contentMode = UIViewContentModeScaleToFill;
		imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
		imageView.layer.borderWidth = 3;
		imageView.tag = 1001;
	}
	
	float height = [self flowView:nil heightForRowAtIndexPath:indexPath];
	
	AsyncImageView *imageView  = (AsyncImageView *)[cell viewWithTag:1001];
    imageView.frame = CGRectMake(0, 0, self.view.frame.size.width / NUMBER_OF_COLUMNS, height);
    
    int row = indexPath.row;
    int column = indexPath.section;
    int finalNum = row * NUMBER_OF_COLUMNS + column;
    if (finalNum < [searchDuanZiList count]) {
        NSDictionary *record = [searchDuanZiList objectAtIndex:finalNum];
        NSString *thumbURL = [record objectForKey:@"middle_url"];
        if ([thumbURL hasPrefix:@"http://"]) {
            [imageView loadImage:thumbURL
              withPlaceholdImage:[UIImage imageNamed:@"defaultCover.png"]];
        } else {
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* documentsDirectory = [paths objectAtIndex:0];
            NSString* thumbFullPathToFile = [documentsDirectory stringByAppendingPathComponent:thumbURL];
            NSLog(@"[fullPathToFile]: %@", thumbFullPathToFile);
            [imageView setImage:[[UIImage alloc] initWithContentsOfFile:thumbFullPathToFile]];
        }
    }
    
    cell.type=@"DAILY";
    
	//NSLog(@"row: %d, section: %d", indexPath.row, indexPath.section);
	return cell;
    
}

#pragma mark-
#pragma mark- WaterflowDelegate

-(CGFloat)flowView:(WaterflowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    int column = indexPath.section;
    int finalNum = row * NUMBER_OF_COLUMNS + column;
    if (finalNum < [searchDuanZiList count]) {
        NSDictionary *duanZi = [searchDuanZiList objectAtIndex:finalNum];
        int imageDisplayHeightForFlowView = [self getImageDisplayRectForFlowView:duanZi];
        return imageDisplayHeightForFlowView;
    }
    return 100;//[self flowView:nil heightForRowAtIndexPath:indexPath];
}

//瀑布流模式中适应屏幕的图片尺寸
- (int)getImageDisplayRectForFlowView:(NSDictionary *)duanZi {    
    int width = [[duanZi objectForKey:@"image_width"] intValue];
    int height = [[duanZi objectForKey:@"image_height"] intValue];
    //int imageDisplayWidth = (320 - 4*HORIZONTAL_PADDING) / 3;
    int imageDisplayWidth = 320 / 3;
    int imageDisplayHeight = (height * imageDisplayWidth) / width;
    
    return imageDisplayHeight;
}

- (void)flowViewDidSelectCell:(NSIndexPath *)indexPath
{
    /*
    int rowIndex = indexPath.row;
    int columnIndex = indexPath.section;
    NSLog(@"did select at (row, column): (%d, %d)", rowIndex, columnIndex);
    
    NSLog(@"[self.imageUrls count]: %d", [searchDuanZiList count]);
    if ([searchDuanZiList count] == 0) {
        return;
    }
    currentSelectedIndex = rowIndex * NUMBER_OF_COLUMNS + columnIndex;

    // Create & present browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    // Set options
    browser.wantsFullScreenLayout = YES; // Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
    [browser setInitialPageIndex:currentSelectedIndex]; // Example: allows second image to be presented first
    // Present
    browser.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentModalViewController:browser animated:YES];
*/
}

-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)performRefresh {
    //loadOld = NO;
    searchDuanZiList = [[NSMutableArray alloc] init];
    currentPage = 0;
    [self performSelector:@selector(requestResultFromServer) withObject:nil];
}

#pragma mark - The Magic!

-(void)expand
{
    if(hidden)
        return;
    
    hidden = YES;
    
    [self.tabBarController setTabBarHidden:YES 
                                  animated:YES];
    
    [self.navigationController setNavigationBarHidden:YES 
                                             animated:YES];
}

-(void)contract
{
    if(!hidden)
        return;
    
    hidden = NO;
    
    [self.tabBarController setTabBarHidden:NO 
                                  animated:YES];
    
    [self.navigationController setNavigationBarHidden:NO 
                                             animated:YES];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    startContentOffset = lastContentOffset = scrollView.contentOffset.y;
    //NSLog(@"scrollViewWillBeginDragging: %f", scrollView.contentOffset.y);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
    CGFloat currentOffset = scrollView.contentOffset.y;
    CGFloat differenceFromStart = startContentOffset - currentOffset;
    CGFloat differenceFromLast = lastContentOffset - currentOffset;
    lastContentOffset = currentOffset;
    
    if((differenceFromStart) < 0)
    {
        // scroll up
        if(scrollView.isTracking && (abs(differenceFromLast)>1) && shouldExpandContract)
            [self expand];
    }
    else {
        if(scrollView.isTracking && (abs(differenceFromLast)>1) && shouldExpandContract)
            [self contract];
    }
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
    if (canLoadOld) {
        CGPoint contentOffsetPoint = tableView.contentOffset;
        CGRect frame = tableView.frame;
        if (contentOffsetPoint.y == tableView.contentSize.height - frame.size.height || tableView.contentSize.height < frame.size.height) 
        {
            NSLog(@"scroll to the end");
            if (!_reloading) {
                //loadOld = YES;
                _reloading = YES;
                currentPage ++;
                [self requestResultFromServer];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if (shouldExpandContract) {
        [self contract];
    }
    return YES;
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
                pullmessageAlertView = [[UIAlertView alloc] initWithTitle:[pullmessageInfo objectForKey:@"title"]
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
    if (alertView == pullmessageAlertView) {//拉取消息
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
    } else if (alertView == forcedStarredAlertView) {
        //评论前评星
        switch (buttonIndex) {
            case 0:
            {
                NSLog(@"不评");
                break;
            }
            case 1:
            {
                // they want to rate it
                NSLog(@"去评价");
                [[NoneAdultAppDelegate sharedAppDelegate] showStarComment];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:@"YES" forKey:@"forcedStarred"];
                [defaults synchronize];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    NSLog(@"下拉刷新...");
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    if (canLoadNew) {
        _reloading = YES;
        [self performRefresh];
        //[self requestResultFromServer];
    }
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    
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
    //url = [[NSString alloc] initWithFormat:@"%@", recentUrlPrefix];
    if (viewType == 1) { //最热频道
        url = [NSString stringWithFormat:@"http://118.244.225.185:8080/BaguaApp/toplist_history.jsp?count=%d&type=%@", numOfPagesize, type];
    } else {
        url = [NSString stringWithFormat:@"http://118.244.225.185:8080/BaguaApp/recentlist.jsp?pageSize=%d&keyword=%@", numOfPagesize, keyword];
        if (currentPage != 0) {
            url = [url stringByAppendingFormat:@"&max_time=%lld&page=%d", baseTime, currentPage];
        }
        if (category != -1) {
            url = [url stringByAppendingFormat:@"&category=%d", category];
        }
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
	post = @"";
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
    //NSDictionary *dataDic = [responseInfo objectForKey:@"info"];
    NSMutableArray *addedList = [responseInfo objectForKey:@"resources"];
    //tempPropertyDic = [dataDic objectForKey:@"selectedMap"];
    
    if (viewType != 1 && currentPage == 0) {
        NSNumber *baseTimeNum = [responseInfo objectForKey:@"time"];
        NSNumber *totalNum = [responseInfo objectForKey:@"total"];
        baseTime = [baseTimeNum longLongValue];
        total = [totalNum intValue];
    }
    
    //NSLog(@"result: %@", addedList);
    
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
    NSString *idString = [self autoCorrectNull:[dic objectForKey:@"record_id"]];
    NSString *screenName = [self autoCorrectNull:[dic objectForKey:@"nick"]];
    NSString *profileImageUrl = [self autoCorrectNull:[dic objectForKey:@"author_pic"]];
    NSString *weiboContent = [self autoCorrectNull:[dic objectForKey:@"summary"]];
    NSString *largeUrl = [self autoCorrectNull:[dic objectForKey:@"large_url"]];
    NSString  *shareUrl = [self autoCorrectNull:[dic objectForKey:@"share_url"]];
    
    NSDecimalNumber *commentCount = (NSDecimalNumber *)[dic objectForKey:@"comments_count"];
    NSDecimalNumber *favoriteCount = [[NSDecimalNumber alloc] initWithInt:([commentCount intValue]*3)];
    NSDecimalNumber *buryCount = [[NSDecimalNumber alloc] initWithInt:([commentCount intValue]*2)];
    NSDecimalNumber *imageWidth = (NSDecimalNumber *)[dic objectForKey:@"large_width"];
    NSDecimalNumber *imageHeight = (NSDecimalNumber *)[dic objectForKey:@"large_height"];
    NSDecimalNumber *timestamp = (NSDecimalNumber *)[dic objectForKey:@"timestamp"];

    [dic setObject:idString forKey:@"id"];
    [dic setObject:screenName forKey:@"screen_name"];
    [dic setObject:profileImageUrl forKey:@"profile_image_url"];
    [dic setObject:[weiboContent stringByConvertingHTMLToPlainText] forKey:@"content"];
    [dic setObject:favoriteCount forKey:@"favorite_count"];
    [dic setObject:buryCount forKey:@"bury_count"];
    [dic setObject:commentCount forKey:@"comments_count"];
    
    [dic setObject:largeUrl forKey:@"large_url"];
        
    [dic setObject:imageWidth forKey:@"width"];//图片内容的width
    [dic setObject:imageHeight forKey:@"height"];//图片内容的height
    [dic setObject:[NSNumber numberWithDouble:[timestamp doubleValue]/1000] forKey:@"timestamp"];
    
    [dic setObject:shareUrl forKey:@"shareurl"];
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
        [collectedIdsDic setObject:[[NSNumber alloc] initWithInt:1] forKey:[rs stringForColumn:@"weiboId"]];
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
    
    //NSLog(@"collectedIdsDic: %@", collectedIdsDic);
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
    if (viewType != 3 && [searchDuanZiList count] == 0) {
        [self.tableView setContentOffset:CGPointZero animated:YES];
    }
    [self loadCollectedIds];
    [self loadDingIds];
    NSMutableDictionary *dic = nil;
    for (int i=0;i<[data count];i++) {
        dic = [data objectAtIndex:i];
        [self adaptDic:dic];
        [self checkCollected:dic];
        [self checkDing:dic];

        NSString *largeUrl = [dic objectForKey:@"large_url"];
        if ([largeUrl isEqualToString:@""]) {
            continue;
        }
        [searchDuanZiList addObject:dic];
    }
    [self.tableView reloadData];
    [self.flowView reloadData];
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

#pragma mark - User Action Methods
-(void)goGallery:(UITapGestureRecognizer *)sender{
    //点击进入详情页，隐藏的工具栏和Tab栏需要显示出来，要不就退不出来了
    if (shouldExpandContract) {
        [self contract];
    }
    
    //这个sender其实就是UIButton，因此通过sender.tag就可以拿到刚才的参数
    int i = [sender.view tag] - 5000;
    currentDuanZi = [searchDuanZiList objectAtIndex:i];
    // shareurl的含义
    // -对于图片，是图解微博的url;
    // -对于视频，是优酷上的详情页url;
    NSString *shareurl = [currentDuanZi objectForKey:@"shareurl"];
    
    //查看详情时记分
    if (shouldScore) {
        [[NoneAdultAppDelegate sharedAppDelegate] scoreForShareUrlNew:currentDuanZi channel:UIChannelNew action:UIActionView];
    }
    
    NSNumber *categoryNumber = [currentDuanZi objectForKey:@"category"];
    if ([categoryNumber intValue] != 1) {
        //底部工具栏操作项
        UIImage *likeIcon = [UIImage imageNamed:@"photo-gallery-collect-noselect.png"];
        UIImage *likeIconSelected = [UIImage imageNamed:@"photo-gallery-collect.png"];
        NSString *collectedTag = [currentDuanZi objectForKey:@"collected_tag"];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 20, 20);
        [btn addTarget:self action:@selector(handleLikeButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:likeIcon forState:UIControlStateNormal];
        [btn setImage:likeIconSelected forState:UIControlStateSelected];
        UIBarButtonItem *likeButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        if ([collectedTag isEqualToString:@"YES"]) {
            [btn setSelected:YES];
        }
        
        UIImage *shareIcon = [UIImage imageNamed:@"photo-gallery-share.png"];
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:shareIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleShareButtonTouch:)];
        NSArray *barItems = [NSArray arrayWithObjects:likeButton, shareButton, nil];
        
        FGalleryViewController *localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self barItems:barItems];
        [localGallery setUseThumbnailView:NO];
        //[localGallery setHideTitle:YES];
        [self.navigationController pushViewController:localGallery animated:YES];
    } else {
        SVWebViewController *webViewController = [[SVWebViewController alloc]
                                                  initWithURL:[NSURL URLWithString:shareurl]];
        NSLog(@"shareurl: %@", shareurl);
        webViewController.hidesBottomBarWhenPushed = YES;
        webViewController.title = @"视频详情";
        [self.navigationController pushViewController:webViewController animated:YES];
    }
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
                                                    otherButtonTitles: @"微信好友",@"微信朋友圈", @"新浪微博",@"腾讯微博",@"保存至相册", nil];//@"邮件分享", nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)goComment:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *forcedStarred = [defaults objectForKey:@"forcedStarred"];
    
    if (forcedStarred == nil || [forcedStarred isEqualToString:@""]) {
        forcedStarredAlertView = [[UIAlertView alloc] initWithTitle:@"亲,给姐5星评价,再看评论哦"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"不评"
                                              otherButtonTitles:@"去评价",nil];
		[forcedStarredAlertView show];
    } else {
        [self contract];
        int i = [sender tag] - 3000;
        //得到网络图片的实际大小
        NSDictionary *duanZi = [searchDuanZiList objectAtIndex:i];
        NSString *recordId = [duanZi objectForKey:@"record_id"];
        
        NoneAdultCommentViewController *commentViewController = [[NoneAdultCommentViewController alloc] initWithNibName:@"NoneAdultCommentViewController" bundle:nil];
        commentViewController.title = @"热评列表";
        commentViewController.recordId = recordId;
        commentViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:commentViewController animated:YES];
        commentViewController.hidesBottomBarWhenPushed = NO;//马上设置回NO
    }
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
        
        NSString *shareurl = [currentDuanZi objectForKey:@"shareurl"];
        //收藏时记分
        if (shouldScore) {
            [[NoneAdultAppDelegate sharedAppDelegate] scoreForShareUrlNew:currentDuanZi channel:UIChannelNew action:UIActionCollect];
        }
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
        NSString *shareurl = [currentDuanZi objectForKey:@"shareurl"];
        NSLog(@"...shareurl: %@", shareurl);
        if (shouldScore) {
            [[NoneAdultAppDelegate sharedAppDelegate] scoreForShareUrlNew:currentDuanZi channel:UIChannelNew action:UIActionShare];
        }
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        currentImage = [manager imageWithURL:[NSURL URLWithString:largeUrl]];
        
        //@"微信好友",@"微信朋友圈", @"新浪微博",@"腾讯微博",@"保存至相册"
        id<ISSPublishContent> publishContent = [ShareSDK publishContent:statusContent
                                                         defaultContent:statusContent
                                                                  image:currentImage
                                                           imageQuality:0.8
                                                              mediaType:SSPublishContentMediaTypeNews
                                                                  title:@"推荐你看看这个" //微信
                                                                    url:shareurl //微信
                                                           musicFileUrl:nil //微信
                                                                extInfo:nil //微信
                                                               fileData:nil]; //微信
        
        if (buttonIndex == actionSheet.firstOtherButtonIndex + 4) {
            NSLog(@"custom event share_email!");
            [self savePhoto];
        } else {
            ShareType st = ShareTypeWeixiSession;
            if (buttonIndex == actionSheet.firstOtherButtonIndex) {
                st = ShareTypeWeixiSession;
            } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
                st = ShareTypeWeixiTimeline;
            } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
                st = ShareTypeSinaWeibo;
            } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 3) {
                st = ShareTypeTencentWeibo;
            }
            [ShareSDK shareContentWithType:st
                                   content:publishContent
                       containerController:self
                             statusBarTips:YES
                           oneKeyShareList:nil
                            shareViewStyle:ShareViewStyleSimple
                            shareViewTitle:@"分享内容"
                                    result:nil];
        }
    }
}

#pragma mark - Save Photo Action
- (void)savePhoto {
    if (currentImage) {
        [self showProgressHUDCompleteMessage:[NSString stringWithFormat:@"%@\u2026" , NSLocalizedString(@"正在保存", @"Displayed with ellipsis as 'Saving...' when an item is in the process of being saved")]];
    }
}

- (void)showProgressHUDCompleteMessage:(NSString *)message {
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	HUD.delegate = self;
	HUD.labelText = message;
	
	[HUD showWhileExecuting:@selector(actuallySavePhoto:) onTarget:self withObject:currentImage animated:YES];
    //self.navigationController.navigationBar.userInteractionEnabled = YES;
}

- (void)actuallySavePhoto:(UIImage *)photo {
    if (photo) {
        sleep(1);
        UIImageWriteToSavedPhotosAlbum(photo, self,
                                       @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    //[self showProgressHUDCompleteMessage: error ? NSLocalizedString(@"Failed", @"Informing the user a process has failed") : NSLocalizedString(@"Saved", @"Informing the user an item has been saved")];
}


#pragma mark - Action Sheet Delegate
- (void)dataSendDidFinish:(UIViewController *)viewController andReturnStatus:(UMReturnStatusType)returnStatus andPlatformType:(UMShareToType)platfrom {
    [viewController dismissModalViewControllerAnimated:YES];
}

//时间线模式中适应屏幕的图片尺寸
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
    UIImageView *brandLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon.png"]];
    [brandLogoImageView setFrame:CGRectMake(17, 13, TOP_SECTION_HEIGHT-20, TOP_SECTION_HEIGHT-20)];        
    [cell.contentView addSubview:brandLogoImageView];
    [brandLogoImageView setImageWithURL:[NSURL URLWithString:[duanZi objectForKey:@"profile_image_url"]] 
                       placeholderImage:[UIImage imageNamed:@"Icon.png"]];
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
        
        [coverImageView setTag:(row + 5000)];
        coverImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goGallery:)];
        [coverImageView addGestureRecognizer:singleTap];
    }
    
    //叠加播放按钮
    UIImageView *playImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feedvideoplay.png"]];
    [cell.contentView addSubview:playImageView];
    
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
    pingLabel.text = [NSString stringWithFormat:@"%@",[commentsCount stringValue]];
    //pingLabel.textAlignment = UITextAlignmentRight;
    pingLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    [pingLabel setBackgroundColor:[UIColor clearColor]];
    pingLabel.textColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1];
    //[cell.contentView addSubview:pingLabel];
    pingLabel.tag = 4;
    

    //content图片内容自适应
    CGRect imageDisplayRect = [self getImageDisplayRect:duanZi];    
    imageDisplayRect.origin.y = imageDisplayRect.origin.y + 5;
    [coverImageView setFrame:imageDisplayRect];
    
    //叠加播放按钮
    int imageX = imageDisplayRect.origin.x;
    int imageY = imageDisplayRect.origin.y;
    int imageWidth = imageDisplayRect.size.width;
    int imageHeight = imageDisplayRect.size.height;
    CGRect playDisplayRect = CGRectMake(imageX + (imageWidth - PLAYBUTTON_WIDTH)/2,
                                        imageY + (imageHeight - PLAYBUTTON_WIDTH)/2,
                                        PLAYBUTTON_WIDTH, PLAYBUTTON_WIDTH);
    [playImageView setFrame:playDisplayRect];
    
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
    [dingLabel setFrame:CGRectMake(17, cellFrame.size.height + TOP_SECTION_HEIGHT - 3 + imageDisplayRect.size.height, 70, BOTTOM_SECTION_HEIGHT)];
    caiLabel = (UILabel *)[cell viewWithTag:3];
    [caiLabel setFrame:CGRectMake(87, cellFrame.size.height + TOP_SECTION_HEIGHT - 3 + imageDisplayRect.size.height, 70, BOTTOM_SECTION_HEIGHT)];
    pingLabel = (UILabel *)[cell viewWithTag:4];
    [pingLabel setFrame:CGRectMake(155, cellFrame.size.height + TOP_SECTION_HEIGHT - 3 + imageDisplayRect.size.height, 70, BOTTOM_SECTION_HEIGHT)];
    
    //评论按钮
    UIButton *btnComment = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnComment setTitle:[NSString stringWithFormat:@"  %@",[commentsCount stringValue]]
             forState:UIControlStateNormal];
    [btnComment.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [btnComment setTitleColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1] forState:UIControlStateNormal];
    [btnComment setTag:(row + 3000)];
    [btnComment addTarget:self action:@selector(goComment:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnComment];
    UIImage *btnCommentImage = [UIImage imageNamed:@"comment.png"];
    [btnComment setBackgroundImage:btnCommentImage forState:UIControlStateNormal];
    [btnComment setFrame:CGRectMake(155, cellFrame.size.height + TOP_SECTION_HEIGHT - 3 + imageDisplayRect.size.height+8, 70, 18)];

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
    
    //视频资源暂不支持收藏
    if ([[duanZi objectForKey:@"category"] intValue] == 1) {
        [btnStar setHidden:YES];
    } else {
        [playImageView setHidden:YES];
    }
    
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
    [self contract];
    int row = [indexPath row];
    NSDictionary *duanZi = [searchDuanZiList objectAtIndex:row];
    NSString *recordId = [duanZi objectForKey:@"record_id"];
    
    NoneAdultCommentViewController *commentViewController = [[NoneAdultCommentViewController alloc] initWithNibName:@"NoneAdultCommentViewController" bundle:nil];
    commentViewController.title = @"热评列表";
    commentViewController.recordId = recordId;
    commentViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:commentViewController animated:YES];
    commentViewController.hidesBottomBarWhenPushed = NO;//马上设置回NO
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

#pragma mark - FGalleryViewControllerDelegate Methods

- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
	return 1;
}

- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
	return FGalleryPhotoSourceTypeNetwork;
}

- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
	return [currentDuanZi objectForKey:@"content"];
}

- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return [currentDuanZi objectForKey:@"large_url"];
}

- (void)handleLikeButtonTouch:(id)sender {
    // here we could remove images from our local array storage and tell the gallery to remove that image
    // ex:
    //[localGallery removeImageAtIndex:[localGallery currentIndex]];
    NSLog(@"handleLikeButtonTouch...");
    
    NSString *collectedTag = [currentDuanZi objectForKey:@"collected_tag"];
    if ([collectedTag isEqual:@"YES"]) {
        [currentDuanZi setObject:@"NO" forKey:@"collected_tag"];
    } else {
        [currentDuanZi setObject:@"YES" forKey:@"collected_tag"];
    }
    
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    [self collectDuanZi:button.selected];
    [self collectHUDMessage:button.selected];
}


- (void)handleShareButtonTouch:(id)sender {
    // here we could implement some code to change the caption for a stored image
    [self shareDuanZi];
}
@end
