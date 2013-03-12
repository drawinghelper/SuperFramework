//
//  NoneAdultSettingViewController.m
//  NeiHanStory
//
//  Created by 王 攀 on 12-6-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NoneAdultSettingViewController.h"

@interface NoneAdultSettingViewController ()

@end

@implementation NoneAdultSettingViewController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"设置", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"setting"];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.shadowColor = [UIColor colorWithRed:70.0f/255 green:70.0f/225 blue:70.0f/255 alpha:1];     
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:235.0f/255 green:235.0f/225 blue:235.0f/255 alpha:1];        
        [label setShadowOffset:CGSizeMake(0, -1.0)];
        
        self.navigationItem.titleView = label;
        label.text = NSLocalizedString(@"设置", @"");
        [label sizeToFit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbarBackground.png"] 
                                                  forBarMetrics:UIBarMetricsDefault];   
    
    // Do any additional setup after loading the view from its nib.
    currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    NSString *versionForReview = [MobClick getConfigParams:@"versionForReview"];

    starCommentVisible = YES;
    if ([currentAppVersion isEqualToString:versionForReview]) {
        starCommentVisible = NO;
    }
    
    if (versionForReview == nil || versionForReview == [NSNull null]  || [versionForReview isEqualToString:@""]) {
        starCommentVisible = NO;
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIColor *veryDarkGray = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1];
    UIColor *veryLightGray = [UIColor colorWithRed:0.9f green:0.9f blue:0.9f alpha:1];
    
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = veryDarkGray;
    headerLabel.shadowColor = veryLightGray;     
    headerLabel.shadowOffset = CGSizeMake(1.0,1.0); 
    headerLabel.textAlignment = UITextAlignmentCenter;
	headerLabel.font = [UIFont systemFontOfSize:16];
    //headerLabel.text = [[NSString alloc]initWithFormat:@"%@ v%@", @"高清热播剧", currentVersionStr];
    NSString *displayNameKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];

    headerLabel.text = [[NSString alloc]initWithFormat:@"%@ v%@", displayNameKey, currentAppVersion];
	
    return headerLabel;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 55;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //cell.backgroundColor = [UIColor clearColor]; 
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    // Configure the cell...
    NSUInteger row = [indexPath row];
    switch (row) {
        case 0:
            cell.text = @"帮我们评分";
            break;
        case 1:
            cell.text = @"用着不爽提意见";
            break;
        case 2:
            cell.text = [NSString stringWithFormat:@"清空缓存: 已占%@",[self getCacheFolderSizeStr]];
            break;
        default:
            break;
    }
    return cell;
}


/*计算APP缓存大小*/
- (unsigned long long int) cacheFolderSize {
    NSFileManager *_manager = [NSFileManager defaultManager];
    NSArray *_cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *_cacheDirectory = [_cachePaths objectAtIndex:0];
    NSLog(@"cacheDirectory: %@", _cacheDirectory);
    NSArray *_cacheFileList;
    NSEnumerator *_cacheEnumerator;
    NSString *_cacheFilePath;
    unsigned long long int _cacheFolderSize = 0;
    
    _cacheFileList = [_manager subpathsAtPath:_cacheDirectory];
    _cacheEnumerator = [_cacheFileList objectEnumerator];
    while (_cacheFilePath = [_cacheEnumerator nextObject]) {
        NSDictionary *_cacheFileAttributes = [_manager fileAttributesAtPath:[_cacheDirectory stringByAppendingPathComponent:_cacheFilePath] traverseLink:YES];
        _cacheFolderSize += [_cacheFileAttributes fileSize];
    }
    
    return _cacheFolderSize;
}

- (NSString *)getCacheFolderSizeStr {
    NSNumber *number = [NSNumber numberWithLongLong:[self cacheFolderSize]];
    const unsigned int bytes = 1024 * 1024;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setPositiveFormat:@"##0.00MB"];
    NSNumber *partial = [NSNumber numberWithFloat:([number floatValue] / bytes)];
    return [formatter stringFromNumber:partial];
}

/*清空APP缓存*/
- (void)clearCache {
    NSArray *_cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *_cacheDirectory = [_cachePaths objectAtIndex:0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *imagesFiles = [fileManager contentsOfDirectoryAtPath:_cacheDirectory error:&error];
    for (NSString *file in imagesFiles) {
        error = nil;
        [fileManager removeItemAtPath:[_cacheDirectory stringByAppendingPathComponent:file] error:&error];
        /* do error handling here */
    }
    [self didFinishClearCache];
}

- (void)didFinishClearCache {
    [self.tableView reloadData];
}
- (void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
    NSLog(@"cache size: %lld", [self cacheFolderSize]); //in byte
}
#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"didSelectRowAtIndexPath...");
	//RootViewController *root = [self.navigationController.viewControllers objectAtIndex:0];
	//UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
	NSUInteger row = [indexPath row];

	if(row == 0){
        NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", [[NoneAdultAppDelegate sharedAppDelegate] getAppStoreId]];  
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    } else if (row == 1) {
        [self umengFeedback];
    } else if (row == 2){
        [self confirmClearCache];
    }
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSLog(@"...didSelectRowAtIndexPath");
    
}
- (void)confirmClearCache {
    UIActionSheet *actionsSheet = [[UIActionSheet alloc] initWithTitle:@"确认清除缓存？"
                                                              delegate:self
                                                     cancelButtonTitle:@"取消"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"确定", nil];
    [actionsSheet showInView:[[NoneAdultAppDelegate sharedAppDelegate] window]];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // Actions
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == actionSheet.firstOtherButtonIndex) {
            [self clearCache];
        }
    }
}
- (void)showLogOut {
    UIAlertView *logOutAlertView = [[UIAlertView alloc] initWithTitle:@"确认退出登录吗？"
                                                                   message:nil
                                                                  delegate:self
                                                         cancelButtonTitle:@"确认"
                                                         otherButtonTitles:@"取消", nil];
    [logOutAlertView show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            NSLog(@"登出");
            [PFUser logOut];
            [self.tableView reloadData];
            break;
        default:
            break;
    }
    
}
#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请将登录信息填写完整!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.tableView reloadData];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请将注册信息填写完整!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.tableView reloadData];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

- (void)showLogin {
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        [logInViewController setFields:PFLogInFieldsUsernameAndPassword | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton];
        
        // Create the sign up view controller
        MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        [signUpViewController setFields:PFSignUpFieldsDefault];

        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController]; 
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
}
- (void)showLianMeng {
    UMTableViewDemoNew *lianMengViewController = [[UMTableViewDemoNew alloc]init];
    lianMengViewController.title = @"精彩应用推荐";
    lianMengViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lianMengViewController animated:YES];
}

- (void)umengFeedback {
    /*UIViewController *authVC = [[AGAuthViewController alloc] init];
    authVC.title = @"授权";
    [self.navigationController pushViewController:authVC animated:YES];
    */
    [UMFeedback showFeedback:self withAppkey:[[NoneAdultAppDelegate sharedAppDelegate] getUmengAppKey]];
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

@end
