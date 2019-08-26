//
//  XJPlayerBundleResource.m
//  XJPlayerManager_Example
//
//  Created by XJIMI on 2019/8/12.
//  Copyright © 2019 xjimi. All rights reserved.
//

#import "XJPlayerBundleResource.h"

@implementation XJPlayerBundleResource

+ (UIImage *)imageNamed:(NSString *)name {
    return [XJBundleResource imageNamed:name class:[self class] resource:@"XJPlayerManager_resource_image"];
}

+ (UIView *)nibViewWithNamed:(NSString *)name
{
    NSBundle *bundle = [XJBundleResource bundleForClass:NSClassFromString(name) resource:@"XJPlayerManager_resource_xib"];
    UIView *nibView = [[bundle loadNibNamed:name owner:nil options:nil] firstObject];
    return nibView;
}

@end
