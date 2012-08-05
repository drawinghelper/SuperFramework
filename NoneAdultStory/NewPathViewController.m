//
//  HistoryPathViewController.m
//  ParseStarterProject
//
//  Created by James Yu on 12/29/11.
//  Copyright (c) 2011 Parse Inc. All rights reserved.
//

#import "NewPathViewController.h"

@implementation NewPathViewController
@synthesize adView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    newChannel = YES;
    if (self) {
        self.title = NSLocalizedString(@"精选", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"new"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.shadowColor = [UIColor colorWithRed:219.0f/255 green:241.0f/225 blue:241.0f/255 alpha:1];     
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:37.0f/255 green:149.0f/225 blue:149.0f/255 alpha:1];        
        [label setShadowOffset:CGSizeMake(0, 1.0)];
        
        self.navigationItem.titleView = label;
        label.text = NSLocalizedString(@"精选", @"");
        [label sizeToFit];
        
        // Custom the table
        // The className to query on
        self.className = @"newfiltered";
        
        // The key of the PFObject to display in the label of the default cell style
        //self.keyToDisplay = @"text";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
    }
    return self;
}
#pragma mark -
#pragma mark AdMogo Methods
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
    newFrame.origin.y = self.navigationController.view.bounds.size.height - adSize.height;
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


#pragma mark - View lifecycle
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
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
        [self.navigationController.view addSubview:adView];
    }
    
    UIButton *btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom]; 
    btnRefresh.frame = CGRectMake(0, 0, 44, 44);
    [btnRefresh addTarget:self action:@selector(performRefresh) forControlEvents:UIControlEventTouchUpInside];
    UIImage *btnImage = [UIImage imageNamed:@"refresh.png"];
    [btnRefresh setImage:btnImage forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRefresh];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] 
                                                  forBarMetrics:UIBarMetricsDefault]; 
    
    self.tableView.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1];
}

- (void)performRefresh {
    [self loadObjects];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadCollectedIds];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [HUD hide:YES afterDelay:0];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
    NSLog(@"加载完成...");
    
    [self loadCollectedIds];
    /*NSMutableDictionary *dic = nil;
    newObjectArray = [[NSMutableArray alloc] init];
    for (int i=0;i<[self.objects count];i++) {
        dic = [self.objects objectAtIndex:i];
        [self adaptDic:dic];
        [self checkCollected:dic];
        [newObjectArray addObject:dic];
    }
     */
    [self.tableView reloadData];
}

//- (void)adaptDic:(NSMutableDictionary *)dic {
//    NSString *idString = [dic objectForKey:@"weiboId"];
//    [dic setObject:idString forKey:@"id"];
//}

/*- (void)checkCollected:(NSMutableDictionary *)dic {
    
    NSString *idString = [dic objectForKey:@"weiboId"];
    
    if ([collectedIdsDic objectForKey:idString] != nil) {
        NSLog(@"idString YES: %@", idString);
        [dic setObject:@"YES" forKey:@"collected_tag"];
    } else {
        NSLog(@"idString NO: %@", idString);
        [dic setObject:@"NO" forKey:@"collected_tag"];
    }
}*/

- (void)objectsWillLoad {
    [super objectsWillLoad];
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.labelText = @"努力加载中...";
    [HUD setOpacity:1.0f];
    
    // This method is called before a PFQuery is fired to get more objects
    NSLog(@"开始加载...");
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    if (newChannel) {//最新精选栏目排序字段
        [query orderByDescending:@"timestamp"];
    } else {//历史最热栏目排序字段
        [query orderByDescending:@"score"];
    }
    
    return query;
}

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

#pragma mark - User Action Methods
-(void)goGallery:(UITapGestureRecognizer *)sender{  
//    NSString *okUrl = @"http://v.youku.com/v_show/id_XNDAyMTM3OTgw.html";    
//    okUrl = @"http://my.tv.sohu.com/u/vw/28703434";
    
    //这个sender其实就是UIButton，因此通过sender.tag就可以拿到刚才的参数  
    int i = [sender.view tag] - 5000;
    NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
    currentDuanZi = [self objectAtIndex:currentIndexPath];
    // shareurl的含义
    // -对于图片，是图解微博的url;
    // -对于视频，是优酷上的详情页url;
    NSString *shareurl = [currentDuanZi objectForKey:@"shareurl"];
    
    //查看详情时记分
    if (newChannel) {
        [[NoneAdultAppDelegate sharedAppDelegate] scoreForShareUrl:shareurl channel:UIChannelNew action:UIActionView];
    } else {
        [[NoneAdultAppDelegate sharedAppDelegate] scoreForShareUrl:shareurl channel:UIChannelHistory action:UIActionView];
    }
    
    NSNumber *feature = [currentDuanZi objectForKey:@"feature"];
    if ([feature intValue] == 0) {
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
        webViewController.hidesBottomBarWhenPushed = YES;
        webViewController.title = @"视频详情";
        [self.navigationController pushViewController:webViewController animated:YES];
    }
    
}

-(void)goShare:(id)sender{  
    //这个sender其实就是UIButton，因此通过sender.tag就可以拿到刚才的参数  
    int i = [sender tag] - 1000;
    NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
    currentDuanZi = [self objectAtIndex:currentIndexPath];
    [self shareDuanZi];
}

-(void)goCollect:(id)sender{  
    //这个sender其实就是UIButton，因此通过sender.tag就可以拿到刚才的参数  
    int i = [sender tag] - 2000;
    NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
    currentDuanZi = [self objectAtIndex:currentIndexPath];
    
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
    [self collectDuanZi:tag];
    [self collectHUDMessage:tag];   
}

- (void)shareDuanZi {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"分享到" 
                                                             delegate:self
                                                    cancelButtonTitle:@"取消" 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"新浪微博",@"腾讯微博",@"保存至相册", nil];     
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
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

- (void)collectDuanZi:(BOOL)tag {
    FMDatabase *db= [FMDatabase databaseWithPath:[[NoneAdultAppDelegate sharedAppDelegate] getDbPath]] ;  
    if (![db open]) {  
        NSLog(@"Could not open db."); 
        return ;  
    }
    if (tag) {
        NSDate *nowDate = [[NSDate alloc] init];
        NSArray *dataArray = [NSArray arrayWithObjects:
                              [currentDuanZi objectForKey:@"weiboId"], 
                              
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
                              [currentDuanZi objectForKey:@"shareurl"],
                              nil
                              ];
        [db executeUpdate:@"replace into collected(weiboId, profile_image_url, screen_name, timestamp, content, large_url, width, height, gif_mark, favorite_count, bury_count, comments_count, collect_time, share_url) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" withArgumentsInArray:dataArray];
    } else {
        NSArray *dataArray = [NSArray arrayWithObjects:[currentDuanZi objectForKey:@"weiboId"], nil];
        [db executeUpdate:@"delete from collected where weiboId = ?" withArgumentsInArray:dataArray];
    }
    
    if (tag) {
        NSString *shareurl = [currentDuanZi objectForKey:@"shareurl"];
        //收藏时记分
        if (newChannel) {
            [[NoneAdultAppDelegate sharedAppDelegate] scoreForShareUrl:shareurl channel:UIChannelNew action:UIActionCollect];
        } else {
            [[NoneAdultAppDelegate sharedAppDelegate] scoreForShareUrl:shareurl channel:UIChannelHistory action:UIActionCollect];
        }
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
	[HUD hide:YES afterDelay:1];
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSString *statusContent = nil;
        NSString *largeUrl = [currentDuanZi objectForKey:@"large_url"];
        NSString *shareurl = [currentDuanZi objectForKey:@"shareurl"];
        NSString *appstoreurl = [[NoneAdultAppDelegate sharedAppDelegate] getAppStoreShortUrl];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        currentImage = [manager imageWithURL:[NSURL URLWithString:largeUrl]];
        //记分
        if (newChannel) {
            [[NoneAdultAppDelegate sharedAppDelegate] 
                scoreForShareUrl:shareurl channel:UIChannelNew action:UIActionShare];
        } else {
            [[NoneAdultAppDelegate sharedAppDelegate] scoreForShareUrl:shareurl channel:UIChannelHistory action:UIActionShare];
        }
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            NSLog(@"custom event share_sina_budong!");
            statusContent = [NSString stringWithFormat:@"今儿偶然在网上发现了一个超喜欢的新发型[爱你]￼，看看，编起来还挺简单的 %@ [兔子]。O(∩_∩)O还有很多更漂亮的，都是从这个神器中找到的￼ %@ [good]。", 
                             shareurl, //微博详情页
                             appstoreurl]; //appstore下载页
            
            /*[MobClick event:@"share_sina_budong"];*/
            [UMSNSService presentSNSInController:self 
                                          appkey:[[NoneAdultAppDelegate sharedAppDelegate] getUmengAppKey] 
                                          status:statusContent 
                                           image:[self getCropImage:currentImage] 
                                        platform:UMShareToTypeSina];
            
            [UMSNSService setDataSendDelegate:self];
            return;
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
            NSLog(@"custom event share_sina_haoxiao!");     
            statusContent = [NSString stringWithFormat:@"今儿偶然在网上发现了一个超喜欢的新发型 /爱心￼，看看，编起来还挺简单的 %@ /猪头。O(∩_∩)O还有很多更漂亮的，都是从这个神器中找到的￼ %@ /强。", 
                             shareurl, //微博详情页
                             appstoreurl]; //appstore下载页
            
            [UMSNSService presentSNSInController:self 
                                          appkey:[[NoneAdultAppDelegate sharedAppDelegate] getUmengAppKey] 
                                          status:statusContent 
                                           image:[self getCropImage:currentImage] 
                                        platform:UMShareToTypeTenc];
            
            [UMSNSService setDataSendDelegate:self];
            return;
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
            NSLog(@"custom event share_email!");
            [self savePhoto];
            
            return;  
        }
    }
}

//截取编发图解的正方形缩略图
- (UIImage *)getCropImage:(UIImage *)networkImage {
    int width = networkImage.size.width;
    int height = networkImage.size.height;
    
    int cropLength = 0;
    int x = 0, y = 0;
    if (width > height) { // -
        cropLength = height;
        //居中裁减的代码
        //x = (width - cropLength)/2; 
    } else { // |
        cropLength = width;
        //居中裁减的代码
        //y = (height - cropLength)/2; 
    }
    CGRect cropRect = CGRectMake(x, y, cropLength, cropLength);
    CGImageRef imageRef = CGImageCreateWithImageInRect([networkImage CGImage], cropRect);
    networkImage = [UIImage imageWithCGImage:imageRef]; 
    CGImageRelease(imageRef);
    
    return networkImage;
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell.textLabel.text isEqualToString:@"点击\n加载更多"]) {
        return 75;
    } else {
        int row = [indexPath row];
        NSDictionary *duanZi = [self.objects objectAtIndex:row];
        CGRect imageDisplayRect = [self getImageDisplayRect:duanZi];    
        
        return cell.frame.size.height + TOP_SECTION_HEIGHT + BOTTOM_SECTION_HEIGHT + imageDisplayRect.size.height;
    }
}

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = @"点击\n加载更多";
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.highlightedTextColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:@"STHeiti K" size:14];
    cell.textLabel.textColor = [UIColor colorWithRed:109.0f/255 green:109.0f/225 blue:109.0f/255 alpha:1]; 
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    return cell;
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
    //NSLog(@"x: %d, y: %d, width: %d, height: %d", imageDisplayLeft, imageDisplayTop, imageDisplayWidth, imageDisplayHeight);
    return rect;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object. 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)duanZi {
    int row = [indexPath row];
    
    //打上是否收藏过的标记
    NSNumber *weiboId = [duanZi objectForKey:@"weiboId"];
    NSString *idString = [weiboId stringValue];
    //NSString *idString = [duanZi objectForKey:@"weiboId"];
    NSLog(@"collectedIdsDic: %@", collectedIdsDic);
    if ([collectedIdsDic objectForKey:idString] != nil) {
        NSLog(@"idString YES: %@", idString);
        [duanZi setObject:@"YES" forKey:@"collected_tag"];
    } else {
        NSLog(@"idString NO: %@", idString);
        [duanZi setObject:@"NO" forKey:@"collected_tag"];
    }
    
    //NSMutableDictionary *duanZi = [newObjectArray objectAtIndex:row];
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
    
    //分享的按钮+1000
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
    
    //微博图 + 5000
    UIImageView *coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"defaultCover.png"]];
    NSString *imageUrl = [duanZi objectForKey:@"large_url"];
    if ( imageUrl != nil && ![imageUrl isEqualToString:@""]) {
        [coverImageView setImageWithURL:[NSURL URLWithString:imageUrl] 
                       placeholderImage:[UIImage imageNamed:@"defaultCover.png"]
                                success:^(UIImage *image) {
                                    [self fadeInLayer:coverImageView.layer];
                                } 
                                failure:nil
         ];
        
        [cell.contentView addSubview:coverImageView];
        [coverImageView setTag:(row + 5000)];
        coverImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goGallery:)];
        [coverImageView addGestureRecognizer:singleTap];
        
        //[coverImageView addTarget:self action:@selector(goGallery:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //叠加播放按钮
    UIImageView *playImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feedvideoplay.png"]];
    [cell.contentView addSubview:playImageView];
    
    //【底部】
    UIView *bottomBgView = [[UIView alloc] initWithFrame:CGRectZero];
    [cell.contentView addSubview:bottomBgView];
    //[bottomBgView setBackgroundColor:[UIColor lightGrayColor]];
    [bottomBgView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"duanzi_bg_bottom.png"]]];
    //bottomBgView.tag = 1000;
    
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
    
    //收藏按钮 +2000
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
    
    //content图片内容自适应
    CGRect imageDisplayRect = [self getImageDisplayRect:duanZi];    
    imageDisplayRect.origin.y = imageDisplayRect.origin.y + 5;
    [coverImageView setFrame:imageDisplayRect];
    
    int imageX = imageDisplayRect.origin.x;
    int imageY = imageDisplayRect.origin.y;
    int imageWidth = imageDisplayRect.size.width;
    int imageHeight = imageDisplayRect.size.height;
    CGRect playDisplayRect = CGRectMake(imageX + (imageWidth - PLAYBUTTON_WIDTH)/2,
                                        imageY + (imageHeight - PLAYBUTTON_WIDTH)/2,
                                        PLAYBUTTON_WIDTH, PLAYBUTTON_WIDTH);
    [playImageView setFrame:playDisplayRect];
    
    //content内容自适应
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
    [dingLabel setFrame:CGRectMake(17, cellFrame.size.height + TOP_SECTION_HEIGHT - 3 + imageDisplayRect.size.height, 75, BOTTOM_SECTION_HEIGHT)];
    caiLabel = (UILabel *)[cell viewWithTag:3];
    [caiLabel setFrame:CGRectMake(92, cellFrame.size.height + TOP_SECTION_HEIGHT - 3 + imageDisplayRect.size.height, 75, BOTTOM_SECTION_HEIGHT)];
    pingLabel = (UILabel *)[cell viewWithTag:4];
    [pingLabel setFrame:CGRectMake(165, cellFrame.size.height + TOP_SECTION_HEIGHT - 3 + imageDisplayRect.size.height, 75, BOTTOM_SECTION_HEIGHT)];
    
    [btnStar setFrame:CGRectMake(260, cellFrame.size.height + TOP_SECTION_HEIGHT - 3 + imageDisplayRect.size.height, 320-260, BOTTOM_SECTION_HEIGHT)];
    
    //视频资源暂不支持收藏
    if ([[duanZi objectForKey:@"feature"] intValue] == 1) {
        [btnStar setHidden:YES];
    } else {
        [playImageView setHidden:YES];
    }
    
    [cell setFrame:cellFrame];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	return cell;
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

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

/*
 // Override if you need to change the ordering of objects in the table.
 - (PFObject *)objectAtIndex:(NSIndexPath *)indexPath { 
 return [objects objectAtIndex:indexPath.row];
 }
 */

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 }
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

#pragma mark - Table view data source

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
