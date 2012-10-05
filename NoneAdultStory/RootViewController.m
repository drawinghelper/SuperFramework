//
//  RootViewController.m
//  FGallery
//
//  Created by Grant Davis on 1/6/11.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import "RootViewController.h"
#import "UIViewController+CMTabBarController.h"


@implementation RootViewController
@synthesize adView;

#pragma mark - View lifecycle
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"杂志收藏", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"tab_zazhi"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.shadowColor = [UIColor colorWithRed:70.0f/255 green:70.0f/225 blue:70.0f/255 alpha:1];     
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:235.0f/255 green:235.0f/225 blue:235.0f/255 alpha:1];        
        [label setShadowOffset:CGSizeMake(0, -1.0)];
        
        self.navigationItem.titleView = label;
        label.text = NSLocalizedString(@"杂志收藏", @"");
        [label sizeToFit];
        
    }
    return self;
}

- (void)loadLocalData {
    localCaptions = [[NSMutableArray alloc] init];
    localImages = [[NSMutableArray alloc] init];
    localThumbnailImages = [[NSMutableArray alloc] init];
    for (int i=1; i<=kPresetNum; i++) {
        [localCaptions addObject:[NSString stringWithFormat:@"编发图解%d",i]];
        [localImages addObject:[NSString stringWithFormat:@"h%d.JPG",i]];
        [localThumbnailImages addObject:[NSString stringWithFormat:@"h%d_thumb.jpg",i]];
    }
}

- (void)loadNetworkData {
    networkCaptions = [[NSMutableArray alloc] init];
    networkImages = [[NSMutableArray alloc] init];
    networkShareUrl = [[NSMutableArray alloc] init];
    
    //从数据库中取出收藏图
    FMDatabase *db= [FMDatabase databaseWithPath:[[NoneAdultAppDelegate sharedAppDelegate] getDbPath]] ;  
    if (![db open]) {  
        NSLog(@"Could not open db."); 
        return ;  
    } 
    
    FMResultSet *rs=[db executeQuery:@"SELECT * FROM collected ORDER BY collect_time DESC"];
    while ([rs next]){
        [networkCaptions addObject:[rs stringForColumn:@"content"]];
        [networkImages addObject:[rs stringForColumn:@"large_url"]];
        [networkShareUrl addObject:[rs stringForColumn:@"share_url"]];
    }
}
- (void)loadView {
	[super loadView];
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self loadDataForGallery];
}

- (void)loadDataForGallery {
    [self loadLocalData];
    [self loadNetworkData];
}

#pragma mark - Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return 2;
    NSArray *channelList = [[NoneAdultAppDelegate sharedAppDelegate] getChannelList];
    return 2 + [channelList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kTableViewCellHeight;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell.
	static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //清除已有数据，防止文字重叠
    for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    CGRect backgroundViewFrame = cell.contentView.frame;
    backgroundViewFrame.size.height = kTableViewCellHeight;
    backgroundViewFrame.size.width = kTableViewCellWidth;
    cell.backgroundView = [[UIView alloc] initWithFrame:backgroundViewFrame];
    [cell.backgroundView addLinearUniformGradient:[NSArray arrayWithObjects:
                                                   (id)[[UIColor whiteColor] CGColor],
                                                   (id)[
                                                        [UIColor colorWithRed:225.0f/255.0f green:225.0f/255.0f blue:225.0f/255.0f alpha:1.0f]
                                                        CGColor], nil]];
    
    // Configure the cell...
    int row = [indexPath row];
    [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
    [cell.textLabel setTextColor:[UIColor colorWithRed:40.0f/255.0f green:40.0f/255.0f blue:40.0f/255.0f alpha:1.0f]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];

    if (row == 0) {
        [cell.textLabel setText:@"姐的收藏"];
        [cell.imageView setImage:[UIImage imageNamed:@"star_pressed.png"]];
    } else if (row == 1) {
        [cell.textLabel setText:@" 附赠杂志"];
    } else {
        NSArray *channelList = [[NoneAdultAppDelegate sharedAppDelegate] getChannelList];
        NSDictionary *channelInfo = [channelList objectAtIndex:(row - 2)];
        NSString *titleStr = [NSString stringWithFormat:@" %@", [channelInfo objectForKey:@"title"]];
        [cell.textLabel setText:titleStr];
    }
    return cell;
}

- (void)viewDidAppear:(BOOL)animated{
    [self loadNetworkData];
    [self.tableView reloadData];// performRefresh];
}

#pragma mark - FGalleryViewControllerDelegate Methods


- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
    int num;
    if( gallery == localGallery ) {
        num = [localImages count];
    }
    else if( gallery == networkGallery ) {
        num = [networkImages count];
    }
	return num;
}


- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
	if( gallery == localGallery ) {
		return FGalleryPhotoSourceTypeLocal;
	}
	else return FGalleryPhotoSourceTypeNetwork;
}


- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
    NSString *caption;
    if( gallery == localGallery ) {
        caption = [localCaptions objectAtIndex:index];
    }
    else if( gallery == networkGallery ) {
        caption = [networkCaptions objectAtIndex:index];
    }
	return caption;
}


- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    if (size == FGalleryPhotoSizeThumbnail) {
        return [localThumbnailImages objectAtIndex:index];
    } else {// if ( size == FGalleryPhotoSizeFullsize) 
        return [localImages objectAtIndex:index];
    }
}

- (NSString*)photoGallery:(FGalleryViewController *)gallery urlForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    return [networkImages objectAtIndex:index];
}

#pragma mark - Other Action Methods

- (void)handleTrashButtonTouch:(id)sender {
    // here we could remove images from our local array storage and tell the gallery to remove that image
    // ex:
    //[localGallery removeImageAtIndex:[localGallery currentIndex]];
    NSLog(@"handleTrashButtonTouch...:%d", [networkGallery currentIndex]);
    int currentImageIndex = [networkGallery currentIndex];
    [self deleteFromDB:currentImageIndex];
    [self collectHUDMessage:NO];   

    [self loadDataForGallery];
    [networkGallery reloadGallery];
    [networkGallery gotoImageByIndex:currentImageIndex animated:NO];
}

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

- (void)deleteFromDB:(int)currentIndex {
    NSString *imageUrl = [networkImages objectAtIndex:currentIndex];
    //从数据库中取出收藏图
    FMDatabase *db= [FMDatabase databaseWithPath:[[NoneAdultAppDelegate sharedAppDelegate] getDbPath]] ;  
    if (![db open]) {  
        NSLog(@"Could not open db."); 
        return ;  
    } 
    
    NSArray *dataArray = [NSArray arrayWithObjects:imageUrl, nil];
    [db executeUpdate:@"DELETE FROM collected WHERE large_url = ?" withArgumentsInArray:dataArray];
}

- (void)handleShareButtonTouch:(id)sender {
    // here we could implement some code to change the caption for a stored image
    [self shareDuanZi];
}

- (void)shareDuanZi {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"分享到" 
                                                             delegate:self
                                                    cancelButtonTitle:@"取消" 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"新浪微博",@"腾讯微博",@"保存至相册", nil];     
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSString *statusContent = nil;
        NSString *appstoreurl = [[NoneAdultAppDelegate sharedAppDelegate] getAppStoreShortUrl];
        int currentImageIndex = [networkGallery currentIndex];   
        //情况一：网络收藏图片的分享，默认
        NSString *shareurl = [networkShareUrl objectAtIndex:currentImageIndex];
        currentImage = networkGallery.currentPhoto.fullsize;
        currentImage = [self getCropImage:currentImage];
        //情况二：本地收藏图片的分享
        if (currentGallery == localGallery) {
            shareurl = @"";
            currentImage = localGallery.currentPhoto.fullsize;
        } else {
            //分享网络图片时需要记分
            [[NoneAdultAppDelegate sharedAppDelegate] 
             scoreForShareUrl:shareurl channel:UIChannelMagzine action:UIActionShare];
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
                                           image:currentImage
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
                                           image:currentImage 
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *trashIcon = [UIImage imageNamed:@"photo-gallery-trashcan.png"];
    UIImage *shareIcon = [UIImage imageNamed:@"photo-gallery-share.png"];
    UIBarButtonItem *trashButtonPreset = [[UIBarButtonItem alloc] initWithImage:trashIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleTrashButtonTouch:)];
    [trashButtonPreset setEnabled:NO];

    UIBarButtonItem *trashButtonCollect = [[UIBarButtonItem alloc] initWithImage:trashIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleTrashButtonTouch:)];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:shareIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleShareButtonTouch:)];
    NSArray *barItemsPreset = [NSArray arrayWithObjects:trashButtonPreset, shareButton, nil];
    NSArray *barItemsCollect = [NSArray arrayWithObjects:trashButtonCollect, shareButton, nil];
    
	if( indexPath.row == 0 ) {
		if ([networkImages count] != 0) {
            networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self barItems:barItemsCollect];
            currentGallery = networkGallery;
            [self.navigationController pushViewController:networkGallery animated:YES];
        }
	} else if( indexPath.row == 1 ) {
        localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self barItems:barItemsPreset];
        currentGallery = localGallery;
        [self.navigationController pushViewController:localGallery animated:YES];
    } else {
        NSArray *channelList = [[NoneAdultAppDelegate sharedAppDelegate] getChannelList];
        NSDictionary *channelInfo = [channelList objectAtIndex:(indexPath.row - 2)];
        NSString *titleStr = [channelInfo objectForKey:@"title"];
        NSString *keywordStr = [channelInfo objectForKey:@"keyword"];

        NewPathViewController *newPathViewController = [[NewPathViewController alloc] init];
        [newPathViewController setTitleString:titleStr];
        newPathViewController.keyword = keywordStr;
        [self.navigationController pushViewController:newPathViewController animated:YES];
    }
}


#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [adView setHidden:NO];
    
    self.customTbBarController.tabBar.tabBarStyle = CMTabBarStyleTranslucent;
    self.customTbBarController.tabBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [adView setHidden:YES];
    
    self.customTbBarController.tabBar.hidden = YES;
}
- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)viewDidLoad {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] forBarMetrics:UIBarMetricsDefault];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
    
    NSString *showAdList = [MobClick getConfigParams:@"showAdList"];
    if (showAdList == nil || showAdList == [NSNull null]  || [showAdList isEqualToString:@""]) {
        showAdList = @"NO";
    }
    //总：AudioToolbox、CoreLocation、CoreTelephony、MessageUI、SystemConfiguration、QuartzCore、EventKit、MapKit、libxml2
    
    if ([showAdList isEqualToString:@"YES"]) {
        //增加广告条显示
        self.adView = [AdMoGoView requestAdMoGoViewWithDelegate:self AndAdType:AdViewTypeNormalBanner
                                                    ExpressMode:NO];
        [adView setFrame:CGRectZero];
        [self.navigationController.view addSubview:adView];
    }
}

#pragma mark -
#pragma mark AdMogo Methods
- (NSString *)adMoGoApplicationKey{
    return [[NoneAdultAppDelegate sharedAppDelegate] getMogoAppKey];
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
    newFrame.origin.y = self.navigationController.view.bounds.size.height - 44 - adSize.height;
    //newFrame.origin.y = 480 - adSize.height;
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

@end

