//
//  NoneAdultDetailViewController.m
//  NoneAdultStory
//
//  Created by 王 攀 on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NoneAdultDetailViewController.h"

@interface NoneAdultDetailViewController ()

@end

@implementation NoneAdultDetailViewController
@synthesize currentDuanZi;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)showInfo {
    NSLog(@"showInfo...");
    [UMFeedback showFeedback:self withAppkey:[[NoneAdultAppDelegate sharedAppDelegate] getUmengAppKey]];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIButton *infoButton = [UIButton buttonWithType: UIButtonTypeInfoLight];
    [infoButton setFrame:CGRectMake(0.0, 100.0, 25.0, 25.0)];
    [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
}

#pragma mark - Action Sheet Delegate
- (void)dataSendDidFinish:(UIViewController *)viewController andReturnStatus:(UMReturnStatusType)returnStatus andPlatformType:(UMShareToType)platfrom {
    [viewController dismissModalViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSString *statusContent = nil;
        NSString *weiboContent = [currentDuanZi objectForKey:@"content"];
        int cuttedLength = 52;
        if (cuttedLength < [weiboContent length]) {
            weiboContent = [weiboContent substringToIndex:cuttedLength];
        }
        statusContent = [NSString 
                         stringWithFormat:@"%@ %@（#%@# %@）",
                         weiboContent,
                         [currentDuanZi objectForKey:@"data_url"],
                         @"内涵笑话",
                         @"http://itunes.apple.com/app/id483805940"
                         ];
        
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            NSLog(@"custom event share_sina_budong!");
            /*[MobClick event:@"share_sina_budong"];*/
            [UMSNSService presentSNSInController:self appkey:[[NoneAdultAppDelegate sharedAppDelegate] getUmengAppKey] status:statusContent image:nil platform:UMShareToTypeSina];

            [UMSNSService setDataSendDelegate:self];
            return;
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) {
            NSLog(@"custom event share_sina_haoxiao!");            
            [UMSNSService presentSNSInController:self appkey:[[NoneAdultAppDelegate sharedAppDelegate] getUmengAppKey] status:statusContent image:nil platform:UMShareToTypeTenc];

            [UMSNSService setDataSendDelegate:self];
            return;
        } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 2) {
            NSLog(@"custom event share_email!");
            /*[MobClick event:@"share_email"];
            [self emailPhoto]; 
            */
            return;  
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height + TOP_SECTION_HEIGHT + BOTTOM_SECTION_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int row = [indexPath row];
    NSDictionary *duanZi = self.currentDuanZi;
    
    static NSString *CellIdentifier = @"OffenceCustomCellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
        //【顶部】
        UIView *bottomBgView = [[UIView alloc] initWithFrame:CGRectZero];
        [cell.contentView addSubview:bottomBgView];
        [bottomBgView setBackgroundColor:[UIColor lightGrayColor]];
        [bottomBgView setAlpha:0.3f];
        [bottomBgView setFrame:CGRectMake(0, 0, 320, TOP_SECTION_HEIGHT)];
        
        //微博名
        UILabel *brandNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(TOP_SECTION_HEIGHT+5, -7, 320 - TOP_SECTION_HEIGHT, TOP_SECTION_HEIGHT)];
        brandNameLabel.textAlignment = UITextAlignmentLeft;
        brandNameLabel.text = [duanZi objectForKey:@"screen_name"];
        brandNameLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
        brandNameLabel.textColor = [UIColor blackColor];
        brandNameLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:brandNameLabel];
        //发布时间
        UILabel *timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(TOP_SECTION_HEIGHT+5, 27, 320 - TOP_SECTION_HEIGHT, TOP_SECTION_HEIGHT-30)];
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
        [brandLogoImageView setFrame:CGRectMake(5, 5, TOP_SECTION_HEIGHT-10, TOP_SECTION_HEIGHT-10)];        
        [cell.contentView addSubview:brandLogoImageView];
        [brandLogoImageView setImageWithURL:[NSURL URLWithString:[duanZi objectForKey:@"profile_image_url"]] 
                           placeholderImage:[UIImage imageNamed:@"Icon.png"]];
        CALayer * layer = [brandLogoImageView layer];  
        [layer setMasksToBounds:YES];  
        [layer setCornerRadius:17.5f];  
        [layer setBorderWidth:1.0];  
        [layer setBorderColor:[[UIColor clearColor] CGColor]];  
        //【中部】
        //微博内容
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.tag = 1;
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.highlightedTextColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        label.opaque = NO; // 选中Opaque表示视图后面的任何内容都不应该绘制
        label.backgroundColor = [UIColor clearColor];
        //[[label layer] setBorderWidth:1.0f];
        //[[label layer] setBorderColor:[NoneAdultAppDelegate getColorFromRed:255 Green:0 Blue:0 Alpha:100]];
        //[[label layer] setBackgroundColor:[NoneAdultAppDelegate getColorFromRed:200 Green:200 Blue:200 Alpha:100]];
        [cell.contentView addSubview:label];
        
        //【底部】
        /*
        //顶踩评
        UILabel *dingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        NSDecimalNumber *favoriteCount = (NSDecimalNumber *)[duanZi objectForKey:@"favorite_count"];
        dingLabel.text = [NSString stringWithFormat:@"顶: %@",[favoriteCount stringValue]];
        [cell.contentView addSubview:dingLabel];
        dingLabel.tag = 2;
        
        UILabel *caiLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        NSDecimalNumber *buryCount = (NSDecimalNumber *)[duanZi objectForKey:@"bury_count"];
        caiLabel.text = [NSString stringWithFormat:@"踩: %@",[buryCount stringValue]];
        [cell.contentView addSubview:caiLabel];
        caiLabel.tag = 3;
        
        UILabel *pingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        NSDecimalNumber *commentsCount = (NSDecimalNumber *)[duanZi objectForKey:@"comments_count"];
        pingLabel.text = [NSString stringWithFormat:@"评论: %@",[commentsCount stringValue]];
        pingLabel.textAlignment = UITextAlignmentRight;
        [cell.contentView addSubview:pingLabel];
        pingLabel.tag = 4;
        */
    }
    
    //content内容自适应
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    CGRect cellFrame = [cell frame];
    cellFrame.origin = CGPointMake(0, TOP_SECTION_HEIGHT);
    
    label.text = [duanZi objectForKey:@"content"];
    CGRect rect = CGRectInset(cellFrame, 2, 2);
    label.frame = rect;
    [label sizeToFit];
    if (label.frame.size.height > 46) {
        cellFrame.size.height = 50 + label.frame.size.height - 46;
    }
    else {
        cellFrame.size.height = 50;
    }
    
    UILabel *dingLabel = (UILabel *)[cell viewWithTag:2];
    [dingLabel setFrame:CGRectMake(0, cellFrame.size.height + TOP_SECTION_HEIGHT, 75, BOTTOM_SECTION_HEIGHT)];
    UILabel *caiLabel = (UILabel *)[cell viewWithTag:3];
    [caiLabel setFrame:CGRectMake(75, cellFrame.size.height + TOP_SECTION_HEIGHT, 75, BOTTOM_SECTION_HEIGHT)];
    UILabel *pingLabel = (UILabel *)[cell viewWithTag:4];
    [pingLabel setFrame:CGRectMake(150, cellFrame.size.height + TOP_SECTION_HEIGHT, 320 - 150, BOTTOM_SECTION_HEIGHT)];
    
    [cell setFrame:cellFrame];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
