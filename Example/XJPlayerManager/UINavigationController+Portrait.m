//
//  UINavigationController+Portrait.m
//  Vidol
//
//  Created by XJIMI on 2016/2/12.
//  Copyright © 2016年 XJIMI. All rights reserved.
//

#import "UINavigationController+Portrait.h"

@implementation UINavigationController (Portrait)

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
