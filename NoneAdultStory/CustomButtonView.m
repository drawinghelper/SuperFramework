//
//  CustomButtonView.m
//  video4iphone
//
//  Created by iTeam on 11-9-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomButtonView.h"


@implementation CustomButtonView

@synthesize btn = _btn;
@synthesize arrow = _arrow;
@synthesize delegate = _delegate;
@synthesize buttonClick = _buttonClick;
@synthesize selected = _selected;

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        UIFont *font = [UIFont boldSystemFontOfSize:20];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = frame;
        [btn addTarget:self action:@selector(downButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.backgroundColor = [UIColor clearColor];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        //btn.titleLabel.shadowColor = [UIColor colorWithRed:70.0f/255 green:70.0f/225 blue:70.0f/255 alpha:1];
        btn.titleLabel.textAlignment = UITextAlignmentCenter;
        //btn.titleLabel.textColor = [UIColor colorWithRed:235.0f/255 green:235.0f/225 blue:235.0f/255 alpha:1];
        [btn.titleLabel setShadowOffset:CGSizeMake(0, 1.0)];
        
        NSString *buttonTitle = @"今日最热";
        CGSize size1 = [[NSString stringWithString:buttonTitle] sizeWithFont:font];
        NSLog(@"%f", size1.width);

        UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_down"]];
        arrow.frame = CGRectMake(frame.size.width / 2 + size1.width / 2, 10.0f, 10, 10);
        [btn setTitle:buttonTitle forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:235.0f/255 green:235.0f/225 blue:235.0f/255 alpha:1]
                  forState:UIControlStateHighlighted];
        [btn setTitleShadowColor:[UIColor colorWithRed:70.0f/255 green:70.0f/225 blue:70.0f/255 alpha:1]
                        forState:UIControlStateNormal];
        [btn addSubview:arrow];
        self.btn = btn;
        self.arrow = arrow;
        [arrow release];
        self.selected = NO ;
        [self addSubview:btn];
    }
    return self;
}

- (void)setText:(NSString *)text {
    UIFont *font = [UIFont boldSystemFontOfSize:20];
    CGSize size1 = [text sizeWithFont:font];
    [self.btn setTitle:text forState:UIControlStateNormal];
    self.arrow.frame = CGRectMake(self.frame.size.width / 2 + size1.width / 2, 10.0f, 10, 10);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)doArrow {

    if (!self.selected) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationRepeatCount:1];
        self.arrow.transform = CGAffineTransformMakeRotation(M_PI);
        [UIView commitAnimations];
        self.selected = YES;
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationRepeatCount:1];
        self.arrow.transform = CGAffineTransformMakeRotation(2 * M_PI);
        [UIView commitAnimations];
        self.selected = NO;
    }
}

- (void)downButtonPressed:(id)sender {
    if (!self.selected) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationRepeatCount:1];
        self.arrow.transform = CGAffineTransformMakeRotation(M_PI);
        [UIView commitAnimations];
        self.selected = YES;
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationRepeatCount:1];
        self.arrow.transform = CGAffineTransformMakeRotation(2 * M_PI);
        [UIView commitAnimations];
        self.selected = NO;
    }

    UIButton *button = (UIButton *) sender;
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];

    if (self.delegate && self.buttonClick && [self.delegate respondsToSelector:self.buttonClick]) {
        [self.delegate performSelectorOnMainThread:self.buttonClick withObject:button waitUntilDone:YES];
    }
}

- (void)dealloc {
    [super dealloc];
}


@end
