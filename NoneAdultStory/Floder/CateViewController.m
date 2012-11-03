//
//  CateViewController.m
//  top100
//
//  Created by Dai Cloud on 12-7-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CateViewController.h"
#import "SubCateViewController.h"
#import "CateTableCell.h"

@interface CateViewController () <UIFolderTableViewDelegate>

@property (strong, nonatomic) SubCateViewController *subVc;
@property (strong, nonatomic) NSDictionary *currentCate;


@end

@implementation CateViewController

@synthesize cates=_cates;
@synthesize subVc=_subVc;
@synthesize currentCate=_currentCate;
@synthesize tableView=_tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"发型目录", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"tab_zazhi"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.shadowColor = [UIColor colorWithRed:70.0f/255 green:70.0f/225 blue:70.0f/255 alpha:1];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:235.0f/255 green:235.0f/225 blue:235.0f/255 alpha:1];
        [label setShadowOffset:CGSizeMake(0, -1.0)];
        
        self.navigationItem.titleView = label;
        label.text = NSLocalizedString(@"发型目录", @"");
        [label sizeToFit];
        
    }
    return self;
}

- (void)dealloc
{
    [_cates release];
    [_subVc release];
    [_currentCate release];
    [_tableView release];
    [super dealloc];
}

-(NSArray *)cates
{
    if (_cates == nil){
        
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Category" withExtension:@"plist"];
        _cates = [[NSArray arrayWithContentsOfURL:url] retain];
        
    }
    
    return _cates;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] forBarMetrics:UIBarMetricsDefault];

    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tmall_bg_furley.png"]];
    
    UIButton *btnLianMeng = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLianMeng.frame = CGRectMake(0, 0, 55, 30);
    [btnLianMeng addTarget:self action:@selector(showLianMeng) forControlEvents:UIControlEventTouchUpInside];
    [btnLianMeng setTitle:@"推荐(1)" forState:UIControlStateNormal];
    [btnLianMeng setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnLianMeng setBackgroundImage:[UIImage imageNamed:@"btn_header.png"] forState:UIControlStateNormal];
    [btnLianMeng.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
    [btnLianMeng.titleLabel setShadowOffset:CGSizeMake(0, -1.0f)];
    [btnLianMeng.titleLabel setShadowColor:[UIColor darkGrayColor]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLianMeng];
}

- (void)viewDidAppear:(BOOL)animated{
    [self loadDataForGallery];
    [self.tableView reloadData];// performRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.cates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cate_cell";

    CateTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[CateTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                      reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *cate = [self.cates objectAtIndex:indexPath.row];
    cell.logo.image = [UIImage imageNamed:[[cate objectForKey:@"imageName"] stringByAppendingString:@".png"]];
    cell.title.text = [cate objectForKey:@"name"];
    
    NSMutableArray *subTitles = [[NSMutableArray alloc] init];
    NSArray *subClass = [cate objectForKey:@"subClass"];
    for (int i=0; i < MIN(4,  subClass.count); i++) {
        [subTitles addObject:[[subClass objectAtIndex:i] objectForKey:@"name"]];
    }
    cell.subTtile.text = [subTitles componentsJoinedByString:@"/"];
    [subTitles release];
    
    return cell;
}

- (void)loadView {
	[super loadView];
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self loadDataForGallery];
}

- (void)showLianMeng {
    UMTableViewDemo *lianMengViewController = [[UMTableViewDemo alloc]init];
    lianMengViewController.title = @"精彩应用推荐";
    lianMengViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lianMengViewController animated:YES];
}

- (void)loadDataForGallery {
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

#pragma mark - Table view delegate

-(CGFloat)tableView:(UIFolderTableView *)tableView xForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *trashIcon = [UIImage imageNamed:@"photo-gallery-trashcan.png"];
    UIImage *shareIcon = [UIImage imageNamed:@"photo-gallery-share.png"];
    
    UIBarButtonItem *trashButtonCollect = [[UIBarButtonItem alloc] initWithImage:trashIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleTrashButtonTouch:)];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:shareIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleShareButtonTouch:)];
    NSArray *barItemsCollect = [NSArray arrayWithObjects:trashButtonCollect, shareButton, nil];
    
    SubCateViewController *subVc = [[[SubCateViewController alloc]
                                     initWithNibName:NSStringFromClass([SubCateViewController class])
                                     bundle:nil] autorelease];
    NSDictionary *cate = [self.cates objectAtIndex:indexPath.row];
    
    int selectedIndex = [indexPath row];
    if (selectedIndex == 0) {
        NewPathViewController *newPathViewController = [[NewPathViewController alloc] init];
        [newPathViewController setTitleString:[cate objectForKey:@"name"]];
        newPathViewController.keyword = @"【视频】";
        [self.navigationController pushViewController:newPathViewController animated:YES];
    } else {
        subVc.subCates = [cate objectForKey:@"subClass"];
        self.currentCate = cate;
        subVc.cateVC = self;
        
        self.tableView.scrollEnabled = NO;
        UIFolderTableView *folderTableView = (UIFolderTableView *)tableView;
        [folderTableView openFolderAtIndexPath:indexPath WithContentView:subVc.view
                                     openBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                         // opening actions
                                     }
                                    closeBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction){
                                        // closing actions
                                    }
                               completionBlock:^{
                                   // completed actions
                                   self.tableView.scrollEnabled = YES;
                               }];
    }
}

-(void)subCateBtnAction:(UIButton *)btn
{

    NSDictionary *subCate = [[self.currentCate objectForKey:@"subClass"] objectAtIndex:btn.tag];
    NSString *titleStr = [subCate objectForKey:@"name"];
    NSString *keywordStr = [subCate objectForKey:@"keyword"];
    
    NewPathViewController *newPathViewController = [[NewPathViewController alloc] init];
    [newPathViewController setTitleString:titleStr];
    newPathViewController.keyword = keywordStr;
    [self.navigationController pushViewController:newPathViewController animated:YES];
}

#pragma mark - FGalleryViewControllerDelegate Methods


- (int)numberOfPhotosForPhotoGallery:(FGalleryViewController *)gallery
{
	return [networkImages count];
}


- (FGalleryPhotoSourceType)photoGallery:(FGalleryViewController *)gallery sourceTypeForPhotoAtIndex:(NSUInteger)index
{
	return FGalleryPhotoSourceTypeNetwork;
}


- (NSString*)photoGallery:(FGalleryViewController *)gallery captionForPhotoAtIndex:(NSUInteger)index
{
	return [networkCaptions objectAtIndex:index];
}

/*
- (NSString*)photoGallery:(FGalleryViewController*)gallery filePathForPhotoSize:(FGalleryPhotoSize)size atIndex:(NSUInteger)index {
    if (size == FGalleryPhotoSizeThumbnail) {
        return [localThumbnailImages objectAtIndex:index];
    } else {// if ( size == FGalleryPhotoSizeFullsize)
        return [localImages objectAtIndex:index];
    }
}*/

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
        
        //分享网络图片时需要记分
        [[NoneAdultAppDelegate sharedAppDelegate]
         scoreForShareUrl:shareurl channel:UIChannelMagzine action:UIActionShare];
        
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
@end
