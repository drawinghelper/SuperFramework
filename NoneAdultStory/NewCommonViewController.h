//
//  NewCommonViewController.h
//  NoneAdultStory
//
//  Created by 王 攀 on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSNSStringJson.h"
#import "NoneAdultAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import "AdSageDelegate.h" 
#import "AdSageView.h"
#import "NoneAdultDetailViewController.h"
#import "NSString+HTML.h"
#import "FGalleryViewController.h"
#import "UMTableViewDemo.h"
#import "SVWebViewController.h"
#import "WaterflowView.h"
#import "AsyncImageView.h"
#import <ShareSDK/ShareSDK.h>

#define NUMBER_OF_COLUMNS 3
//#define NUMBER_OF_ROWS 20
#define NUMBER_OF_PAGESIZE 60
#define NUMBER_OF_HISTORY_PAGESIZE 120

#define FONT_SIZE 14.0f
#define TOP_SECTION_HEIGHT 52.0f
#define BOTTOM_SECTION_HEIGHT 34.0f
#define HORIZONTAL_PADDING 16.0f
#define PLAYBUTTON_WIDTH 30.0f

@interface NewCommonViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UMSNSDataSendDelegate, MBProgressHUDDelegate, FGalleryViewControllerDelegate, WaterflowViewDelegate,WaterflowViewDatasource, AdSageDelegate> {
    AdSageView *adView;

    MBProgressHUD *HUD;
    UIImage *currentImage;

    IBOutlet UITableView *tableView;

    NSMutableData *responseData;   
    NSString *url;
    NSMutableArray *searchDuanZiList;
    NSMutableDictionary *currentDuanZi;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    UIActivityIndicatorView *activityIndicator;
    
    //  Reloading var should really be your tableviews datasource
    //  Putting it here for demo purposes
    NSDictionary *tempPropertyDic;
    NSMutableDictionary *collectedIdsDic;
    NSMutableDictionary *dingIdsDic;
    
    NSDictionary *pullmessageInfo;
    NSString *currentCid;
    
    //0 - 最新； 1 - 最热； 2 - 分类； 3 - 收藏
    int viewType;
    int category; // 非负整数表示类别编号，-1表示拼url时无需此字段
    
    //是否可以分页加载老记录和新记录
    BOOL canLoadOld;
    BOOL canLoadNew;
    BOOL shouldExpandContract;
    BOOL shouldScore;
    int numOfPagesize;
    
    //BOOL loadOld;
    BOOL _reloading;
    NSString *keyword;
    
    //初次查询的基准时间
    long long baseTime;
    //总记录数
    int total;
    //当前页码
    int currentPage;
    
    WaterflowView *flowView;
}
@property(nonatomic, retain) UITableView *tableView;
//@property (nonatomic, retain) AdMoGoView *adView;
@property (nonatomic, retain) NSString *keyword;
@property (retain, nonatomic) WaterflowView *flowView;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
- (void)goShare:(id)sender;
- (void)goCollect:(id)sender;
- (void)performRefresh;
- (CGRect)getImageDisplayRect:(NSDictionary *)duanZi;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTitle:(NSString *)title withCategory:(int)pCategory withKeyword:(NSString *)pKeyword withViewType:(int)pViewType;
@end
