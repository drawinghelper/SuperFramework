//
//  NetWorkManager.m
//  Constellation
//
//  Created by jeffrey on 10-12-5.
//  Copyright 2010 AppUFO. All rights reserved.
//

#import "NetWorkManager.h"

@implementation NetWorkManager

@synthesize _netWorkIsEnabled;
@synthesize _witchNetWorkerEnabled;
@synthesize delegate;

static NetWorkManager* defaultManager = nil;

+ (NetWorkManager*) sharedManager
{
	if (!defaultManager)
	{
		defaultManager = [[self alloc] init];
	}
	return defaultManager;
}

+ (id) allocWithZone:(NSZone *)zone
{
	@synchronized(self)
	{
		if (defaultManager == nil)
		{ 
			defaultManager = [super allocWithZone:zone];
			return defaultManager;
		}
	}
	return nil;
}

- (NetworkStatus) checkNowNetWorkStatus
{
	Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
	return [r currentReachabilityStatus];
}

- (Boolean) startNetWorkeWatch
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reachabilityChanged:)
												 name: kReachabilityChangedNotification
											   object: nil];
	rech = [[Reachability reachabilityWithHostName:@"www.baidu.com"] retain];
	Boolean finish = [rech startNotifier];
	return finish;
}

- (void) stopNetWorkWatch
{
	[rech stopNotifier];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[defaultManager release];
	defaultManager = nil;
}

- (void)reachabilityChanged:(NSNotification *)note 
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	NetworkStatus status = [curReach currentReachabilityStatus];
    
	//调用代理方法,此方法为必须实现
	[delegate netWorkStatusWillChange:status];
	
	//代理的可选方法
	switch (status)
	{
		case NotReachable:
		{
			//网络不可达
			_netWorkIsEnabled = NO;
			_witchNetWorkerEnabled = NotReachable;
			
			if ([(NSObject*)delegate respondsToSelector:@selector(netWorkStatusWillDisconnection)])
			{
				[delegate netWorkStatusWillDisconnection];
			}
		}
		break;
		case ReachableViaWiFi:
		{
			//网络可达
			_netWorkIsEnabled = YES;
			_witchNetWorkerEnabled = ReachableViaWiFi;
			
			if ([(NSObject*)delegate respondsToSelector:@selector(netWorkStatusWillEnabledViaWifi)])
			{
				[delegate netWorkStatusWillEnabledViaWifi];
			}
		}
		break;
		case ReachableViaWWAN:
		{
			//网络可达
			_netWorkIsEnabled = YES;
			_witchNetWorkerEnabled = ReachableViaWWAN;
			
			if ([(NSObject*)delegate respondsToSelector:@selector(netWorkStatusWillEnabledViaWWAN)])
			{
				[delegate netWorkStatusWillEnabledViaWWAN];
			}
		}
		break;
		default:
			break;
	}
}

- (void) dealloc
{
	if (defaultManager)
	{
		[defaultManager release];
	}
	if (delegate)
	{
		[(NSObject*)delegate release];
	}
	[super dealloc];
}
@end
