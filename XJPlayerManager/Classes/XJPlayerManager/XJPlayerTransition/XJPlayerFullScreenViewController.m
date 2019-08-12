//
//  XJPlayerFullScreenViewController.m
//  Player
//
//  Created by XJIMI on 2018/1/24.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import "XJPlayerFullScreenViewController.h"
#import "XJPlayerView.h"
#import <Masonry/Masonry.h>

//#import "UIViewController+XJPreferredStatusBar.h"

@interface XJPlayerFullScreenViewController ()

@property (nonatomic, weak) UIView *playerContainer;

@property (nonatomic, weak) UIView *playerView;

@end

@implementation XJPlayerFullScreenViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

+ (instancetype)initWithPlayerContainer:(UIView *)playerContainer
                             playerView:(UIView *)playerView
{
    XJPlayerFullScreenViewController *vc = [[XJPlayerFullScreenViewController alloc] init];
    vc.playerContainer = playerContainer;
    vc.playerView = playerView;
    [vc setupTransition];
    return vc;
}

- (void)setupTransition
{
    XJPlayerTransitioningDelegate *transition = self.transition;
    transition.sourceView = self.playerContainer;
    transition.playerView = self.playerView;
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    self.transitioningDelegate = transition;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (XJPlayerTransitioningDelegate *)transition
{
    if (!_transition)
    {
        _transition = [[XJPlayerTransitioningDelegate alloc] init];
        _transition.targetView = self.view;
    }

    return _transition;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    UIInterfaceOrientation orientation = UIInterfaceOrientationLandscapeRight;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation)
    {
        case UIDeviceOrientationLandscapeLeft :
            orientation = UIInterfaceOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = UIInterfaceOrientationLandscapeLeft;
            break;
        default:
            break;
    }
    
    return orientation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

@end
