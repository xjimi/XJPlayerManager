//
//  XJPlayerUtils.h
//  XJPlayerManager_Example
//
//  Created by XJIMI on 2019/8/2.
//  Copyright © 2019 xjimi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define XJP_PortraitW MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)

#define XJP_PortraitH MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)

#define XJP_ISNEATBANG ([[UIScreen mainScreen] bounds].size.height - 812) ? NO : YES



@interface XJPlayerUtils : NSObject



@end

NS_ASSUME_NONNULL_END
