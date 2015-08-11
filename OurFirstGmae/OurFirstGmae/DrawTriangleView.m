//
//  DrawTriangleView.m
//  OurFirstGmae
//
//  Created by CAI CHENG-HONG on 2015/8/10.
//  Copyright (c) 2015年 CAI CHENG-HONG. All rights reserved.
//

#import "DrawTriangleView.h"

@implementation DrawTriangleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.backgroundColor = [UIColor clearColor];
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(ctx);
    
    CGContextMoveToPoint   (ctx, CGRectGetMaxX(rect)/2,CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect)/3, CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect),CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect),CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect)*2/3,CGRectGetMinY(rect));
    CGContextClosePath(ctx);
    CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);
    CGContextFillPath(ctx);
}


@end
