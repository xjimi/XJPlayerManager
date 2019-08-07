//
//  UIButton+CenterSpace.m
//  Vidol
//
//  Created by XJIMI on 2018/5/23.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import "UIButton+CenterSpace.h"

@implementation UIButton (CenterSpace)

- (void)centerImageWithTitleGap:(CGFloat)gap imageOnTop:(BOOL)imageOnTop
{
    NSInteger sign = imageOnTop ? 1 : -1;

    CGSize imageSize = self.imageView.frame.size;
    self.titleEdgeInsets = UIEdgeInsetsMake((imageSize.height+gap)*sign, -imageSize.width, 0, 0);

    CGSize titleSize = self.titleLabel.bounds.size;
    self.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height+gap)*sign, 0, 0, -titleSize.width);
}

@end
