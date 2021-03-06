//
//  XJPlayerAnimatedTransitioning.h
//  XJPlayerTransition
//
//  Created by XJIMI on 2019/1/22.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XJPlayerView.h"

typedef NS_ENUM(NSUInteger, XJPlayerTransitionType) {
    XJPlayerTransitionTypePresent,
    XJPlayerTransitionTypeDismiss,
};

NS_ASSUME_NONNULL_BEGIN

@interface XJPlayerAnimatedTransitioning : NSObject < UIViewControllerAnimatedTransitioning >

@property (nonatomic, weak, nullable) UIView *sourceView;
@property (nonatomic, weak, nullable) UIView *targetView;
@property (nonatomic, weak, nullable) XJPlayerView *playerView;

@property (nonatomic, assign) NSTimeInterval duration;

+ (instancetype)initWithPlayerTransitionType:(XJPlayerTransitionType)transitionType;

@end

NS_ASSUME_NONNULL_END
