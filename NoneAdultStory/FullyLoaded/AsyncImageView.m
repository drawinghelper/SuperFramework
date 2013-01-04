//
//  AsyncImageView.m
//  AirMedia
//
//  Created by Xingzhi Cheng on 7/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"
#import "FullyLoaded.h"

@interface AsyncImageView ()
- (void) downloadImage:(NSString*)imageURL;
@end

@implementation AsyncImageView
@synthesize request = _request;

- (void) dealloc {
	self.request.delegate = nil;
    [self cancelDownload];
    [super dealloc];
}

- (void) loadImage:(NSString*)imageURL {
    [self loadImage:imageURL withPlaceholdImage:nil];
}

- (void) loadImage:(NSString*)imageURL withPlaceholdImage:(UIImage *)placeholdImage {
    self.image = placeholdImage;
    
    /*
    UIImage *image = [[FullyLoaded sharedFullyLoaded] imageForURL:imageURL];
    if (image) 
        self.image = image;
    else
        [self downloadImage:imageURL];
     */

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        UIImage *image = [[FullyLoaded sharedFullyLoaded] imageForURL:imageURL];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (image) {
                self.image = image;
                [self fadeInLayer:self.layer];
            } else {
                [self downloadImage:imageURL];
            }
        });
    });

}

- (void) cancelDownload {
    [self.request cancel];
    self.request = nil;
}

#pragma mark - 
#pragma mark private downloads

- (void) downloadImage:(NSString *)imageURL {
    [self cancelDownload];
	NSString * newImageURL = [imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:newImageURL]];
    [self.request setDownloadDestinationPath:[[FullyLoaded sharedFullyLoaded] pathForImageURL:imageURL]];
    [self.request setDelegate:self];
    /*增加referer防止百度封禁*/
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@"http://image.baidu.com" forKey:@"Referer"];
    [self.request setRequestHeaders:param];
    
    [self.request setCompletionBlock:^(void){
         self.request.delegate = nil;
         
         NSLog(@"async image download done");
         
         NSString * imageURL = [[self.request.originalURL absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        self.request = nil;
         
         dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
         dispatch_async(queue, ^{
            UIImage *image = [[FullyLoaded sharedFullyLoaded] imageForURL:imageURL];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.image = image;
                [self fadeInLayer:self.layer];
            });
    });}];
    [self.request setFailedBlock:^(void){
        [self.request cancel];
        self.request.delegate = nil;
        self.request = nil;
        
        NSLog(@"async image download failed");
     }];
    [self.request startAsynchronous];
//	NSLog(@"download Image %@", imageURL);
}

- (void)fadeInLayer:(CALayer *)l
{
    CABasicAnimation *fadeInAnimate   = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimate.duration            = 0.5;
    fadeInAnimate.repeatCount         = 1;
    fadeInAnimate.autoreverses        = NO;
    fadeInAnimate.fromValue           = [NSNumber numberWithFloat:0.0];
    fadeInAnimate.toValue             = [NSNumber numberWithFloat:1.0];
    fadeInAnimate.removedOnCompletion = YES;
    [l addAnimation:fadeInAnimate forKey:@"animateOpacity"];
    return;
}
@end
