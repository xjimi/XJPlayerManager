//
//  XJPlayerTransition.m
//  XJPlayerTransition
//
//  Created by XJIMI on 2019/1/22.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import "XJPlayerTransitioningDelegate.h"
#import "XJPlayerAnimatedTransitioning.h"

@interface XJPlayerTransitioningDelegate ()

@end

@implementation XJPlayerTransitioningDelegate

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    XJPlayerAnimatedTransitioning *transitioning = [XJPlayerAnimatedTransitioning initWithPlayerTransitionType:XJPlayerTransitionTypePresent];
    transitioning.sourceView = self.sourceView;
    transitioning.targetView = self.targetView;
    transitioning.playerView = self.playerView;
    transitioning.duration = self.presentDuration;
    return transitioning;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    XJPlayerAnimatedTransitioning *transitioning = [XJPlayerAnimatedTransitioning initWithPlayerTransitionType:XJPlayerTransitionTypeDismiss];
    transitioning.sourceView = self.targetView;
    transitioning.targetView = self.sourceView;
    transitioning.playerView = self.playerView;
    transitioning.duration = self.dismissDuration;
    return transitioning;
}

- (NSTimeInterval)presentDuration {
    return .3f;
}

- (NSTimeInterval)dismissDuration {
    return .3f;
}

@end
