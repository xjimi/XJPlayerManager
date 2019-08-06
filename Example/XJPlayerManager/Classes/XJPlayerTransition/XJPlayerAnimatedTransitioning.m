//
//  XJPlayerAnimatedTransitioning.m
//  XJPlayerTransition
//
//  Created by XJIMI on 2019/1/22.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import "XJPlayerAnimatedTransitioning.h"
#import <Masonry/Masonry.h>

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
    //[self fitParentViewWithSubView:self.playerView];
    //self.playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

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
        self.playerView.frame = containerView.bounds;
        [toView layoutIfNeeded];

    } completion:^(BOOL finished) {

//        toView.transform = CGAffineTransformIdentity;
//        toView.bounds = containerView.bounds;
//        toView.center = containerView.center;
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];

    }];
}

- (void)dismissAnimationWithContextTransitioning:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toViewController.view;
    if (!(fromView || toView || self.sourceView || self.targetView)) return;


    CGRect playerFrame = self.playerView.frame;
    self.playerView.frame = CGRectMake(playerFrame.origin.x-10, playerFrame.origin.y-20, playerFrame.size.width + 20, playerFrame.size.height+20);

    /*CGRect fromViewFrame = fromView.frame;
    fromView.frame = CGRectMake(fromViewFrame.origin.x, fromViewFrame.origin.y-10, fromViewFrame.size.width+20, fromViewFrame.size.height+20);*/

    [fromView layoutIfNeeded];
    [toView layoutIfNeeded];

    UIView *containerView = [transitionContext containerView];
    [containerView insertSubview:toView belowSubview:fromView];
    toView.center = containerView.center;

    CGRect targetRect = [self.targetView convertRect:self.targetView.bounds toView:toView];
    if ([UIApplication sharedApplication].statusBarFrame.size.height == 40) {
        targetRect.origin.y += 10.0f;
    }

    /*
    UIGraphicsBeginImageContextWithOptions(fromView.bounds.size, NO, 0);
    [fromView drawViewHierarchyInRect:self.playerView.bounds afterScreenUpdates:NO];
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIImageView *imageView = [[UIImageView alloc] initWithImage:screenImage];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //imageView.contentMode = UIViewContentModeScaleAspectFit;

    imageView.backgroundColor = [UIColor blackColor];
    //imageView.alpha = .5;
    CGRect imageFrame = fromView.bounds;
    CGFloat posX = 17.0f;
    CGFloat posY = 20.0f;
    //imageFrame.origin.x = posX;
    imageFrame.origin.y = -posY;
    imageFrame.size.width += 20;
    imageFrame.size.height += (posY*2);
    imageView.frame = imageFrame;
    [fromView addSubview:imageView];*/

    playerFrame = self.playerView.frame;
    CGRect fromFrame = fromView.bounds;
    NSTimeInterval duration = [self transitionDuration:transitionContext] -1.3f;
    [UIView animateWithDuration:duration
                          delay:0
                        options:0
                     animations:^
     {
         //fromView.transform = CGAffineTransformIdentity;
         //fromView.transform = CGAffineTransformFromRectToRect(CGRectMake(fromView.frame.origin.y, fromView.frame.origin.x, fromView.frame.size.width, fromView.frame.size.height), targetRect);
         //fromView.frame = targetRect;
         [fromView layoutIfNeeded];
         //self.playerView.frame = playerFrame;
         //CGRectMake(0, 0, playerFrame.size.width, playerFrame.size.height)
         fromView.transform = CGAffineTransformFromRectToRectKeepAspectRatio(fromFrame, CGRectMake(0, 0, targetRect.size.width, targetRect.size.height));
         NSLog(@"self.playerView.transform %@ \n %@\n %@", NSStringFromCGRect(fromFrame), fromView, NSStringFromCGRect(targetRect));

     } completion:^(BOOL finished) {


         self.playerView.transform = CGAffineTransformIdentity;
         [self.targetView addSubview:self.playerView];
         [fromView removeFromSuperview];
         [transitionContext completeTransition:!transitionContext.transitionWasCancelled];

         /*
         [UIView animateWithDuration:.3 animations:^{

             //self.playerView.transform = CGAffineTransformFromRectToRect(CGRectMake(0, 0, fromFrame.size.width, fromFrame.size.height), CGRectMake(targetRect.origin.x, targetRect.origin.y, targetRect.size.width, targetRect.size.height) );

         } completion:^(BOOL finished) {


         }];*/
         //self.playerView.frame = CGRectMake(0, 0, targetRect.size.width, targetRect.size.height);
         /*
         [UIView animateWithDuration:1.3 animations:^{

         } completion:^(BOOL finished) {
             [fromView removeFromSuperview];
             [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
         }];*/

     }];
}

- (CGAffineTransform)translatedAndScaledTransformUsingViewRect:(CGRect)viewRect fromRect:(CGRect)fromRect {

    CGSize scales = CGSizeMake(viewRect.size.width/fromRect.size.width, viewRect.size.height/fromRect.size.height);
    CGPoint offset = CGPointMake(CGRectGetMidX(viewRect) - CGRectGetMidX(fromRect), CGRectGetMidY(viewRect) - CGRectGetMidY(fromRect));
    return CGAffineTransformMake(scales.width, 0, 0, scales.height, offset.x, offset.y);

}

/*
CGAffineTransform CGAffineTransformFromRectToRect(CGRect fromRect, CGRect toRect)
{
    CGAffineTransform trans1 = CGAffineTransformMakeTranslation(-fromRect.origin.x, -fromRect.origin.y);
    CGAffineTransform scale = CGAffineTransformMakeScale(toRect.size.width/fromRect.size.width, toRect.size.height/fromRect.size.height);

    CGFloat heightDiff = fromRect.size.height - toRect.size.height;
    CGFloat widthDiff = fromRect.size.width - toRect.size.width;

    CGAffineTransform trans2 = CGAffineTransformMakeTranslation(toRect.origin.x - (widthDiff / 2), toRect.origin.y - (heightDiff / 2));
    return CGAffineTransformConcat(CGAffineTransformConcat(trans1, scale), trans2);
}*/


CGAffineTransform CGAffineTransformFromRectToRectKeepAspectRatio( CGRect fromRect, CGRect toRect )
{
    float aspectRatio = fromRect.size.width / fromRect.size.height;

    if( aspectRatio > ( toRect.size.width / toRect.size.height ))
    {
        toRect = CGRectInset( toRect, 0, ( toRect.size.height - toRect.size.width / aspectRatio ) / 2.0f );
    }
    else
    {
        toRect = CGRectInset( toRect, ( toRect.size.width - toRect.size.height * aspectRatio ) / 2.0f, 0 );
    }

    return CGAffineTransformFromRectToRect( fromRect, toRect );
}

CGAffineTransform CGAffineTransformFromRectToRect(CGRect fromRect, CGRect toRect)
{
    CGAffineTransform trans1 = CGAffineTransformMakeTranslation(-fromRect.origin.x, -fromRect.origin.y);
    CGAffineTransform scale = CGAffineTransformMakeScale(toRect.size.width/fromRect.size.width, toRect.size.height/fromRect.size.height);
    CGAffineTransform trans2 = CGAffineTransformMakeTranslation(toRect.origin.x, toRect.origin.y);
    return CGAffineTransformConcat(CGAffineTransformConcat(trans1, scale), trans2);
}


/*
CGAffineTransform CGAffineTransformFromRectToRect(CGRect fromRect, CGRect toRect)
{
    CGAffineTransform trans1 = CGAffineTransformMakeTranslation(-fromRect.origin.x, -fromRect.origin.y);
    CGAffineTransform scale = CGAffineTransformMakeScale(toRect.size.width/fromRect.size.width, toRect.size.height/fromRect.size.height);
    CGAffineTransform trans2 = CGAffineTransformMakeTranslation(toRect.origin.x, toRect.origin.y);
    return CGAffineTransformConcat(CGAffineTransformConcat(trans1, scale), trans2);
}*/


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

