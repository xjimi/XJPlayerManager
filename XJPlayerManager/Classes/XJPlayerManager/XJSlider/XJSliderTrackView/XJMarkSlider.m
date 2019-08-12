//
//  XJMarkSlider.m
//  Vidol
//
//  Created by XJIMI on 2018/5/22.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import "XJMarkSlider.h"

@implementation XJMarkSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeRedraw;
    self.markColor = [UIColor colorWithRed:0.9853 green:0.0000 blue:0.0270 alpha:1.0000];
    self.markPositions = @[@1];
    self.markWidth = 2;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGRect innerRect = rect;
    CGFloat verPadding = 1.0f;
    CGFloat markH = CGRectGetHeight(innerRect) - verPadding;
    for (int i = 0; i < [self.markPositions count]; i++)
    {
        float position = [self.markPositions[i] floatValue] * innerRect.size.width / 100.0;
        if (isnan(position)) continue;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, self.markWidth);
        CGContextMoveToPoint(context, position, verPadding);
        CGContextAddLineToPoint(context, position, markH);
        CGContextSetStrokeColorWithColor(context, [self.markColor CGColor]);
        CGContextStrokePath(context);
    }
}

@end
