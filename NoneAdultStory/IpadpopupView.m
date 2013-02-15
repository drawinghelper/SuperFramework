//
//  IpadpopupView.m
//  CustomSearchBox
//
//  Created by iTeam on 11-8-17.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IpadpopupView.h"


@implementation IpadpopupView

@synthesize yShadowOffset = _yShadowOffset;

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        self.backgroundColor = [UIColor clearColor];

    }
    return self;
}


- (CGFloat)relativeParentXPosition {
    return self.frame.size.width / 2;
}

- (CGFloat)yShadowOffset {
    if (!_yShadowOffset) {
        float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (osVersion >= 3.2) {
            _yShadowOffset = 2;
        } else {
            _yShadowOffset = -2;
        }

    }
    return _yShadowOffset;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGFloat stroke = 1.0;
    CGFloat radius = 3.0; // 边框棱角
    CGMutablePathRef path = CGPathCreateMutable();
    UIColor *color;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();


    CGFloat parentX = [self relativeParentXPosition];

    //Determine Size
    rect = self.bounds;
    rect.size.width -= stroke;
    rect.size.height -= stroke + 15;
    //rect.size.height -= 20;
    rect.origin.x += stroke / 2.0;
    rect.origin.y += stroke / 2.0 + 10;

    CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + radius);
    CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1);

    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);

    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);

    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);

    CGPathAddLineToPoint(path, NULL, parentX + 10,
            rect.origin.y);
    CGPathAddLineToPoint(path, NULL, parentX,
            rect.origin.y - 10);
    CGPathAddLineToPoint(path, NULL, parentX - 10,
            rect.origin.y);

    CGPathAddLineToPoint(path, NULL, rect.origin.x + radius, rect.origin.y);
    CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);

    CGPathCloseSubpath(path);

    //Fill Callout Bubble & Add Shadow
    color = [UIColor colorWithRed:239 / 255.0 green:240 / 255.0 blue:243 / 255.0 alpha:1.0];
    //color = [UIColor redColor];

    //color = [[UIColor blackColor] colorWithAlphaComponent:0.8];

    [color setFill];
    CGContextAddPath(context, path);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(self.yShadowOffset, self.yShadowOffset), 6, [UIColor colorWithWhite:0 alpha:.5].CGColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);

    //Stroke Callout Bubble
    //color = [[UIColor darkGrayColor] colorWithAlphaComponent:.9];
    color = [UIColor colorWithRed:204 / 255.0 green:202 / 255.0 blue:202 / 255.0 alpha:1.0];

    [color setStroke];
    CGContextSetLineWidth(context, stroke);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    /*
     //	return ;
     //Determine Size for Gloss
     CGFloat glossTopRadius = radius - stroke / 2;
     CGFloat glossBottomRadius = radius / 1.5;

     //Create Path For Gloss
     CGMutablePathRef glossPath = CGPathCreateMutable();
     CGPathMoveToPoint(glossPath, NULL, glossRect.origin.x, glossRect.origin.y + glossTopRadius);
     CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x, glossRect.origin.y + glossRect.size.height - glossBottomRadius);
     CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossBottomRadius, glossRect.origin.y + glossRect.size.height - glossBottomRadius,
                  glossBottomRadius, M_PI, M_PI / 2, 1);
     CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossBottomRadius,
                          glossRect.origin.y + glossRect.size.height);
     CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossBottomRadius,
                  glossRect.origin.y + glossRect.size.height - glossBottomRadius, glossBottomRadius, M_PI / 2, 0.0f, 1);
     CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossRect.size.width, glossRect.origin.y + glossTopRadius);
     CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossTopRadius, glossRect.origin.y + glossTopRadius,
                  glossTopRadius, 0.0f, -M_PI / 2, 1);
     CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossTopRadius, glossRect.origin.y);
     CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossTopRadius, glossRect.origin.y + glossTopRadius, glossTopRadius,
                  -M_PI / 2, M_PI, 1);
     CGPathCloseSubpath(glossPath);

     //Fill Gloss Path
     CGContextAddPath(context, glossPath);
     CGContextClip(context);
     CGFloat colors[] =
     {
         1, 1, 1, .3,
         1, 1, 1, .1,
     };
     CGFloat locations[] = { 0, 1.0 };
     CGGradientRef gradient = CGGradientCreateWithColorComponents(space, colors, locations, 2);
     CGPoint startPoint = glossRect.origin;
     CGPoint endPoint = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height);
     CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);

     //Gradient Stroke Gloss Path
     CGContextAddPath(context, glossPath);
     CGContextSetLineWidth(context, 2);
     CGContextReplacePathWithStrokedPath(context);
     CGContextClip(context);
     CGFloat colors2[] =
     {
         1, 1, 1, .3,
         1, 1, 1, .1,
         1, 1, 1, .0,
     };
     CGFloat locations2[] = { 0, .1, 1.0 };
     CGGradientRef gradient2 = CGGradientCreateWithColorComponents(space, colors2, locations2, 3);
     CGPoint startPoint2 = glossRect.origin;
     CGPoint endPoint2 = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height);
     CGContextDrawLinearGradient(context, gradient2, startPoint2, endPoint2, 0);
     */
    //Cleanup
    CGPathRelease(path);
    //CGPathRelease(glossPath);
    CGColorSpaceRelease(space);
    //CGGradientRelease(gradient);
    //CGGradientRelease(gradient2);
}


- (void)dealloc {
    [super dealloc];
}


@end
