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

@end
