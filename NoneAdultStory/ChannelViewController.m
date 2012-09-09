//
//  ChannelViewController.m
//  WeiKanShiJie
//
//  Created by 王 攀 on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChannelViewController.h"

@interface ChannelViewController ()

@end

@implementation ChannelViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"频道", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"tab_category"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.shadowColor = [UIColor colorWithRed:219.0f/255 green:241.0f/225 blue:241.0f/255 alpha:1];     
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:37.0f/255 green:149.0f/225 blue:149.0f/255 alpha:1];        
        [label setShadowOffset:CGSizeMake(0, 1.0)];
        
        self.navigationItem.titleView = label;
        label.text = NSLocalizedString(@"频道", @"");
        [label sizeToFit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] 
                                                  forBarMetrics:UIBarMetricsDefault];   

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //首先读取studentInfo.plist中的数据
    appConfig = [[NSDictionary alloc] initWithContentsOfFile:
                            [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"plist"]];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSArray *channelList = [appConfig objectForKey: @"ChannelList"];
    return [channelList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    NSArray *channelList = [appConfig objectForKey: @"ChannelList"];
    NSDictionary *currentChannelInfo = [channelList objectAtIndex:row];
    
    //标题
    UILabel *channelTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TOP_SECTION_HEIGHT+13, -3, 320 - TOP_SECTION_HEIGHT, TOP_SECTION_HEIGHT)];
    channelTitleLabel.textAlignment = UITextAlignmentLeft;
    channelTitleLabel.text = [currentChannelInfo objectForKey:@"title"];
    channelTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    channelTitleLabel.textColor = [UIColor blackColor];
    channelTitleLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:channelTitleLabel];
    
    //副标题
    UILabel *channelSubtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TOP_SECTION_HEIGHT+13, 29, 320 - TOP_SECTION_HEIGHT, TOP_SECTION_HEIGHT-30)];
    channelSubtitleLabel.textAlignment = UITextAlignmentLeft;    
    channelSubtitleLabel.text = [currentChannelInfo objectForKey:@"subtitle"];   
    channelSubtitleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    channelSubtitleLabel.textColor = [UIColor darkGrayColor];
    channelSubtitleLabel.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:channelSubtitleLabel];
    
    //频道图标
    UIImageView *channelLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon.png"]];
    [channelLogoImageView setFrame:CGRectMake(13, 13, TOP_SECTION_HEIGHT-13, TOP_SECTION_HEIGHT-13)];        
    [cell.contentView addSubview:channelLogoImageView];
    [channelLogoImageView setImage:[UIImage imageNamed:[currentChannelInfo objectForKey:@"icon"]]];
    CALayer *layer = [channelLogoImageView layer];  
    [layer setMasksToBounds:YES];  
    [layer setCornerRadius:4.0];  
    [layer setBorderWidth:1.0];  
    [layer setBorderColor:[[UIColor clearColor] CGColor]];  

    return cell;
}

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
    int row = [indexPath row];
    NSArray *channelList = [appConfig objectForKey: @"ChannelList"];
    NSDictionary *currentChannelInfo = [channelList objectAtIndex:row];
    // Navigation logic may go here. Create and push another view controller.
    NewCommonViewController *detailViewController = [[NewCommonViewController alloc] 
                                                     initWithNibName:@"NewCommonViewController" 
                                                     bundle:nil 
                                                     withTitle:[currentChannelInfo objectForKey:@"title"] 
                                                     withCid:[currentChannelInfo objectForKey:@"cid"]];
     // ...
     // Pass the selected object to the new view controller.
    detailViewController.hidesBottomBarWhenPushed = YES;
     [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
