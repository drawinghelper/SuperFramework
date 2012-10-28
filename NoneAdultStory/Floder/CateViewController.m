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
//    self.view.backgroundColor = [UIColor blackColor];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    SubCateViewController *subVc = [[[SubCateViewController alloc] 
                  initWithNibName:NSStringFromClass([SubCateViewController class]) 
                  bundle:nil] autorelease];
    NSDictionary *cate = [self.cates objectAtIndex:indexPath.row];
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

-(CGFloat)tableView:(UIFolderTableView *)tableView xForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(void)subCateBtnAction:(UIButton *)btn
{

    NSDictionary *subCate = [[self.currentCate objectForKey:@"subClass"] objectAtIndex:btn.tag];
    NSString *titleStr = [subCate objectForKey:@"name"];
    NSString *keywordStr = [subCate objectForKey:@"keyword"];
    
    
    UIImage *trashIcon = [UIImage imageNamed:@"photo-gallery-trashcan.png"];
    UIImage *shareIcon = [UIImage imageNamed:@"photo-gallery-share.png"];
    UIBarButtonItem *trashButtonPreset = [[UIBarButtonItem alloc] initWithImage:trashIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleTrashButtonTouch:)];
    [trashButtonPreset setEnabled:NO];
    
    UIBarButtonItem *trashButtonCollect = [[UIBarButtonItem alloc] initWithImage:trashIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleTrashButtonTouch:)];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:shareIcon style:UIBarButtonItemStylePlain target:self action:@selector(handleShareButtonTouch:)];
    NSArray *barItemsPreset = [NSArray arrayWithObjects:trashButtonPreset, shareButton, nil];
    NSArray *barItemsCollect = [NSArray arrayWithObjects:trashButtonCollect, shareButton, nil];
    
	/*
    NSArray *channelList = [[NoneAdultAppDelegate sharedAppDelegate] getChannelList];
    NSDictionary *channelInfo = [channelList objectAtIndex:(indexPath.row - 2)];
    NSString *titleStr = [channelInfo objectForKey:@"title"];
    NSString *keywordStr = [channelInfo objectForKey:@"keyword"];
    */
    NewPathViewController *newPathViewController = [[NewPathViewController alloc] init];
    [newPathViewController setTitleString:titleStr];
    newPathViewController.keyword = keywordStr;
    [self.navigationController pushViewController:newPathViewController animated:YES];
}

@end
