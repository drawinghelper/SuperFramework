//
//  RootViewController.m
//  FGallery
//
//  Created by Grant Davis on 1/6/11.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import "RootViewController.h"


@implementation RootViewController


#pragma mark - View lifecycle
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"杂志", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"tab_zazhi"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.shadowColor = [UIColor colorWithRed:219.0f/255 green:241.0f/225 blue:241.0f/255 alpha:1];     
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:37.0f/255 green:149.0f/225 blue:149.0f/255 alpha:1];        
        [label setShadowOffset:CGSizeMake(0, 1.0)];
        
        self.navigationItem.titleView = label;
        label.text = NSLocalizedString(@"杂志", @"");
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
    }
}
- (void)loadView {
	[super loadView];
    
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
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
    return 2;
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
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
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
    //标题
    UILabel *channelTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TOP_SECTION_HEIGHT, 20, 320 - TOP_SECTION_HEIGHT, 35)];
    channelTitleLabel.textAlignment = UITextAlignmentLeft;
    channelTitleLabel.text = @"附赠杂志";
    channelTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
    channelTitleLabel.textColor = [UIColor blackColor];
    channelTitleLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:channelTitleLabel];
    
    //副标题
    UILabel *channelSubtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TOP_SECTION_HEIGHT, 35+20, 320 - TOP_SECTION_HEIGHT, 35)];
    channelSubtitleLabel.textAlignment = UITextAlignmentLeft;    
    channelSubtitleLabel.text = @"图解最火爆的潮流发型";   
    channelSubtitleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    channelSubtitleLabel.textColor = [UIColor darkGrayColor];
    channelSubtitleLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:channelSubtitleLabel];
    
    //内含图片数
    UILabel *channelSumLabel = [[UILabel alloc] initWithFrame:CGRectMake(TOP_SECTION_HEIGHT, 35*2+20, 320 - TOP_SECTION_HEIGHT, 35)];
    channelSumLabel.textAlignment = UITextAlignmentLeft;    
    channelSumLabel.text = [NSString stringWithFormat:@"%d款发型", kPresetNum];   
    channelSumLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    channelSumLabel.textColor = [UIColor darkGrayColor];
    channelSumLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:channelSumLabel];
    
    //频道图标
    SWSnapshotStackView *channelLogoImageView = [[SWSnapshotStackView alloc] initWithFrame:
                                                 CGRectMake(5, 5, kTableViewCellHeight-15, kTableViewCellHeight-15)];
    channelLogoImageView.displayAsStack = YES;
    channelLogoImageView.image = [UIImage imageNamed:@"h1_thumb.jpg"];
    [cell.contentView addSubview:channelLogoImageView];
    
    if (row == 1) {
        channelTitleLabel.text = @"姐的杂志";
        channelSubtitleLabel.text = @"您收藏的发型全在这里";   
        if (networkImages != nil) {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            UIImage *networkImage = [manager imageWithURL:
                                          [NSURL URLWithString:[networkImages objectAtIndex:0]]
                                     ];
            int width = networkImage.size.width;
            int height = networkImage.size.height;
            
            int cropLength = 0;
            int x = 0, y = 0;
            if (width > height) { // -
                cropLength = height;
                x = (width - cropLength)/2;
            } else { // |
                cropLength = width;
                y = (height - cropLength)/2;
            }
            
            //裁减一下呗
            CGRect cropRect = CGRectMake(x, y, cropLength, cropLength);
            CGImageRef imageRef = CGImageCreateWithImageInRect([networkImage CGImage], cropRect);
            networkImage = [UIImage imageWithCGImage:imageRef]; 
            CGImageRelease(imageRef);
            
            channelLogoImageView.image = networkImage;
            channelSumLabel.text = [NSString stringWithFormat:@"%d款发型", [networkImages count]];   

        }
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

- (void)handleLikeButtonTouch:(id)sender {
    // here we could remove images from our local array storage and tell the gallery to remove that image
    // ex:
    //[localGallery removeImageAtIndex:[localGallery currentIndex]];
}


- (void)handleShareButtonTouch:(id)sender {
    // here we could implement some code to change the caption for a stored image
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *likeIcon = [UIImage imageNamed:@"photo-gallery-collect.png"];
    UIImage *shareIcon = [UIImage imageNamed:@"photo-gallery-share.png"];
    UIBarButtonItem *likeButton = [[UIBarButtonItem alloc] initWithImage:likeIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleLikeButtonTouch:)];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:shareIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleShareButtonTouch:)];
    NSArray *barItems = [NSArray arrayWithObjects:likeButton, shareButton, nil];
    
	if( indexPath.row == 0 ) {
		localGallery = [[FGalleryViewController alloc] initWithPhotoSource:self barItems:barItems];
        [self.navigationController pushViewController:localGallery animated:YES];
	} else if( indexPath.row == 1 ) {
		networkGallery = [[FGalleryViewController alloc] initWithPhotoSource:self barItems:barItems];
        [self.navigationController pushViewController:networkGallery animated:YES];
    }
}


#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
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
}



@end

