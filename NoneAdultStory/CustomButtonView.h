//
//  CustomButtonView.h
//  video4iphone
//
//  Created by iTeam on 11-9-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomButtonView : UIView {
}
@property(nonatomic, assign) id delegate;
@property(nonatomic, assign) SEL buttonClick;
@property BOOL selected;
@property(nonatomic, assign) UIButton *btn;

@property(nonatomic, assign) UIImageView *arrow;

- (void)doArrow;

- (void)setText:(NSString *)text;

@end
