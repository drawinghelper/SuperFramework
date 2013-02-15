//
//  MenuView.m
//  video4iphone
//
//  Created by iTeam on 11-9-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MenuView

- (UIButton *)_getButton:(NSString *)text Tag:(int)t Frame:(CGRect)_frame {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = _frame;
    btn.tag = t;
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:self action:@selector(downButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitleColor:[UIColor colorWithRed:51 / 255.0f green:51 / 255.0f blue:51 / 255.0f alpha:1.0] forState:UIControlStateNormal];

    [btn setBackgroundImage:[UIImage imageNamed:@"VideoRankNormal"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"VideoRankNormal1"] forState:UIControlStateSelected];
    //[btn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.7921 green:0.8078 blue:0.8470 alpha:1.0]] forState:UIControlStateNormal];
    //[btn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.6901 green:0.7058 blue:0.7411 alpha:1.0]] forState:UIControlStateSelected];
    return btn;
}

- (UIButton *)_getButtonTop:(NSString *)text Tag:(int)t Frame:(CGRect)_frame {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = _frame;
    btn.tag = t;
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:self action:@selector(downButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitleColor:[UIColor colorWithRed:51 / 255.0f green:51 / 255.0f blue:51 / 255.0f alpha:1.0] forState:UIControlStateNormal];

    [btn setBackgroundImage:[UIImage imageNamed:@"VideoRankTop"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"VideoRankTop1"] forState:UIControlStateSelected];
    //[btn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.7921 green:0.8078 blue:0.8470 alpha:1.0]] forState:UIControlStateNormal];
    //[btn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.6901 green:0.7058 blue:0.7411 alpha:1.0]] forState:UIControlStateSelected];
    return btn;
}

- (UIButton *)_getButtonBottom:(NSString *)text Tag:(int)t Frame:(CGRect)_frame {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = _frame;
    btn.tag = t;
    btn.backgroundColor = [UIColor clearColor];
    [btn addTarget:self action:@selector(downButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:text forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitleColor:[UIColor colorWithRed:51 / 255.0f green:51 / 255.0f blue:51 / 255.0f alpha:1.0] forState:UIControlStateNormal];

    [btn setBackgroundImage:[UIImage imageNamed:@"VideoRankBottom"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"VideoRankBottom1"] forState:UIControlStateSelected];
    //[btn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.7921 green:0.8078 blue:0.8470 alpha:1.0]] forState:UIControlStateNormal];
    //[btn setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.6901 green:0.7058 blue:0.7411 alpha:1.0]] forState:UIControlStateSelected];
    return btn;
}

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:[self _getButtonTop:@"今日最热" Tag:0 Frame:CGRectMake(-0.5, 10, self.frame.size.width + 0.5, 34.5)]];
        [self addSubview:[self _getButtonBottom:@"本周最热" Tag:1 Frame:CGRectMake(-0.5, 10+34.5, self.frame.size.width + 0.5, 34.5)]];
        [self addSubview:[self _getButtonBottom:@"本月最热" Tag:2 Frame:CGRectMake(-0.5, 10+34.5*2, self.frame.size.width + 0.5, 34.5)]];

        self.alpha = 0.0f;
        self.hidden = YES;
        self.isAppeared = NO;
    }
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}


- (void)addTarget:(id)target action:(SEL)action {
    self.delegate = target;
    self.action = action;
}

- (void)downButtonPressed:(id)sender {
    UIButton *button = (UIButton *) sender;
    for (UIView *subView in [button.superview subviews]) {//遍历这个view的subViews
        if ([subView isKindOfClass:NSClassFromString(@"UIButton")]) {
            UIButton *btn = (UIButton *) subView;
            if (btn.selected) {
                [btn setSelected:NO];
            }

        }
    }
    [button setSelected:YES];

    if (self.delegate && self.action && [self.delegate respondsToSelector:self.action]) {
        [self.delegate performSelectorOnMainThread:self.action withObject:sender waitUntilDone:YES];
    }
}

- (void)appeared {
    NSLog(@"%f", self.alpha);
    if (self.alpha == 1.0f) {
        return;
    }
    self.isAppeared = YES;
    self.hidden = NO;
    self.alpha = 0.0;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.alpha = 1.0f;
    [UIView commitAnimations];
}

- (void)disappeared {
    if (self.alpha == 0.0f) {
        return;
    }
    self.isAppeared = NO;
    self.alpha = 1.0f;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.alpha = 0.0;
    [UIView commitAnimations];
    self.hidden = NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)dealloc {
    [super dealloc];
}


@end
