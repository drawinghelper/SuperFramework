//
//  NoneAdultSettingViewController.m
//  NeiHanStory
//
//  Created by 王 攀 on 12-6-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NoneAdultSettingViewController.h"
#import "UIViewController+CMTabBarController.h"

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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] 
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
    return starCommentVisible ? 4 : 2;
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
    PFUser *user = [PFUser currentUser];

    switch (row) {
        case 0:
            cell.text = starCommentVisible ? @"评五星鼓励我" : @"用着不爽提意见";
            break;
        case 1:
            if (starCommentVisible) {
                cell.text = @"用着不爽提意见";
            } else {
                if (user) {
                    cell.text = [NSString stringWithFormat:@"%@ 已登录", user.username];
                } else {
                    cell.text = @"登录";
                }
            }
            break;
        case 2:
            cell.text = @"精彩应用推荐";
            break;
        case 3:
            if (user) {
                cell.text = [NSString stringWithFormat:@"%@ 已登入", user.username];
            } else {
                cell.text = @"登录";
            }
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"didSelectRowAtIndexPath...");
	//RootViewController *root = [self.navigationController.viewControllers objectAtIndex:0];
	//UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
	NSUInteger row = [indexPath row];
    PFUser *user = [PFUser currentUser];

	if(row == 0){
        if (starCommentVisible) {
            NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", [[NoneAdultAppDelegate sharedAppDelegate] getAppStoreId]];  
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        } else {
            [self umengFeedback];
        }
    } else if (row == 1) {
        if (starCommentVisible) {
            [self umengFeedback];
        } else {
            if (user) {
                [self showLogOut];
            } else {
                [self showLogin];
            }
        }
    } else if (row == 2){
        [self showLianMeng];
    } else {
        if (user) {
            [self showLogOut];
        } else {
            [self showLogin];
        }    
    }
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSLog(@"...didSelectRowAtIndexPath");
    
}

- (void)viewWillDisappear:(BOOL)animated {
    self.customTbBarController.tabBar.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.customTbBarController.tabBar.tabBarStyle = CMTabBarStyleTranslucent;
    self.customTbBarController.tabBar.hidden = NO;
    
    NSLog(@"%@ - viewWillAppear", self.title);
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
    UMTableViewDemo *lianMengViewController = [[UMTableViewDemo alloc]init];   
    lianMengViewController.title = @"精彩应用推荐";
    lianMengViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lianMengViewController animated:YES];
}

- (void)umengFeedback {
    //    [MobClick event:@"feedback_click" label:@"列表页"];
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
