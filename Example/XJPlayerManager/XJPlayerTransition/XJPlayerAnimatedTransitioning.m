//
//  XJPlayerAnimatedTransitioning.m
//  XJPlayerTransition
//
//  Created by XJIMI on 2019/1/22.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import "XJPlayerAnimatedTransitioning.h"

@interface XJPlayerAnimatedTransitioning ()

@property (nonatomic, assign) XJPlayerTransitionType transitionType;

@property (nonatomic, weak) AVPlayerLayer *playerLayer;

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
    [toView setNeedsLayout];
    [toView layoutIfNeeded];
    [containerView addSubview:toView];

    [toView addSubview:self.playerView];
    [self fitParentViewWithSubView:self.playerView];

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
                        options:0
                     animations:^
    {

        toView.transform = CGAffineTransformIdentity;
        toView.bounds = containerView.bounds;
        toView.center = containerView.center;
        [toView layoutIfNeeded];

    } completion:^(BOOL finished) {

        /*toView.transform = CGAffineTransformIdentity;
        toView.bounds = containerView.bounds;
        toView.center = containerView.center;*/
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];

    }];
}

- (void)dismissAnimationWithContextTransitioning:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toViewController.view;
    if (!(fromView || toView || self.sourceView || self.targetView)) return;

    [fromView layoutIfNeeded];
    [toView layoutIfNeeded];

    UIView *containerView = [transitionContext containerView];
    [containerView insertSubview:toView belowSubview:fromView];
    toView.center = containerView.center;

    CGRect targetRect = [self.targetView convertRect:self.targetView.bounds toView:toView];
    if ([UIApplication sharedApplication].statusBarFrame.size.height == 40) {
        targetRect.origin.y += 10.0f;
    }

    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^
     {

         fromView.transform = CGAffineTransformIdentity;
         fromView.frame = targetRect;
         [fromView layoutIfNeeded];

     } completion:^(BOOL finished) {

         [self.targetView addSubview:self.playerView];
         self.playerView.translatesAutoresizingMaskIntoConstraints = YES;

         [fromView removeFromSuperview];
         [transitionContext completeTransition:!transitionContext.transitionWasCancelled];

     }];
}

- (void)fitParentViewWithSubView:(UIView *)subview
{
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *viewTop = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:subview.superview attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *viewLeft = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:subview.superview attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *viewRight = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:subview.superview attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *viewBottom = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:subview.superview attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [subview.superview addConstraints:@[viewTop, viewLeft, viewRight, viewBottom]];
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

