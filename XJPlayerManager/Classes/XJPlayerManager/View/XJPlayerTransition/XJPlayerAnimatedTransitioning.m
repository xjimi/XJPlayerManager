//
//  XJPlayerAnimatedTransitioning.m
//  XJPlayerTransition
//
//  Created by XJIMI on 2019/1/22.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import "XJPlayerAnimatedTransitioning.h"
#import "YoutubePlayerView.h"
#import "XJPlayerUtils.h"

@interface XJPlayerAnimatedTransitioning ()

@property (nonatomic, assign) XJPlayerTransitionType transitionType;

@end

@implementation XJPlayerAnimatedTransitioning

+ (instancetype)initWithPlayerTransitionType:(XJPlayerTransitionType)transitionType
{
    XJPlayerAnimatedTransitioning *transitioning = [[XJPlayerAnimatedTransitioning alloc] init];
    transitioning.transitionType = transitionType;
    return transitioning;
}

- (void)presentAnimationWithContextTransitioning:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    if (!(fromView || toView || self.sourceView || self.targetView)) return;

    [fromView layoutIfNeeded];
    [toView layoutIfNeeded];

    UIView *containerView = [transitionContext containerView];
    CGPoint sourceCenter = [self.sourceView.superview convertPoint:self.sourceView.center toView:containerView];

    toView.clipsToBounds = YES;
    toView.bounds = self.sourceView.bounds;
    toView.center = sourceCenter;
    [containerView addSubview:toView];
    [toView setNeedsLayout];
    [toView layoutIfNeeded];

    [toView addSubview:self.playerView];


    CGAffineTransform transform = toView.transform;
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    UIDeviceOrientation deviceOrientationLandscape = UIDeviceOrientationIsLandscape(deviceOrientation) ? deviceOrientation : UIDeviceOrientationLandscapeLeft;
    switch (deviceOrientationLandscape) {
        case UIDeviceOrientationLandscapeLeft:
            toView.transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;

        case UIDeviceOrientationLandscapeRight:
            toView.transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        default:
            break;
    }

    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
    {

        toView.transform = CGAffineTransformIdentity;
        toView.bounds = containerView.bounds;
        toView.center = containerView.center;
        self.playerView.frame = containerView.bounds;
        [toView layoutIfNeeded];

    } completion:^(BOOL finished) {

        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];

    }];
}

- (void)dismissAnimationWithContextTransitioning:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toViewController.view;
    if (!(fromView || toView || self.sourceView || self.targetView)) return;

    UIView *containerView = [transitionContext containerView];
    [containerView insertSubview:toView belowSubview:fromView];

    toView.transform = CGAffineTransformIdentity;
    toView.center = containerView.center;
    toView.frame = containerView.bounds;
    [fromView layoutIfNeeded];
    [toView layoutIfNeeded];
    
    CGRect targetRect = [self.targetView convertRect:self.targetView.bounds toView:toView];
    CGRect targetBounds = CGRectMake(0, 0, targetRect.size.width, targetRect.size.height);

    BOOL isYoutuePlayer = NO;
    UIView *bgView = nil;
    if ([self.playerView.player isKindOfClass:[YoutubePlayerView class]])
    {
        isYoutuePlayer = YES;
        bgView = [[UIView alloc] initWithFrame:self.playerView.bounds];
        bgView.backgroundColor = [UIColor blackColor];
        [self.playerView insertSubview:bgView atIndex:1];
        bgView.alpha = 0.0f;
    }

    NSTimeInterval duration = [self transitionDuration:transitionContext] - 0.3f;
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         fromView.transform = CGAffineTransformIdentity;
         fromView.frame = targetRect;
         [fromView layoutIfNeeded];
         bgView.alpha = 1.0f;
         [self.playerView refreshPlayerFrame:targetBounds];

         if (!isYoutuePlayer) {
         }


     } completion:^(BOOL finished) {

         [self.targetView addSubview:self.playerView];
         self.playerView.frame = targetBounds;
         [toView layoutIfNeeded];
         [fromView removeFromSuperview];

         if (isYoutuePlayer)
         {
             [UIView animateWithDuration:0.3f
                                   delay:0
                                 options:UIViewAnimationOptionCurveEaseInOut
                              animations:^
              {
                  bgView.alpha = 0.0f;

              } completion:^(BOOL finished) {

                  [bgView removeFromSuperview];
                  [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
              }];
         }
         else
         {
             [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
         }

     }];
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext
{
    switch (self.transitionType) {
        case XJPlayerTransitionTypePresent:
            [self presentAnimationWithContextTransitioning:transitionContext];
            break;
        case XJPlayerTransitionTypeDismiss:
            [self dismissAnimationWithContextTransitioning:transitionContext];
            break;
    }
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

@end

