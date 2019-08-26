//
//  XJPlayerManager.m
//  Vidol
//
//  Created by XJIMI on 2019/2/19.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import "XJPlayerManager.h"
#import "XJPlayerAdapter.h"
#import "XJPlayerFullScreenViewController.h"
#import <XJUtil/UIWindow+XJVisible.h>

@interface XJPlayerManager ()

@property (nonatomic, strong) XJPlayerAdapter *currentPlayerAdapter;

@end

@implementation XJPlayerManager

- (void)dealloc {
    NSLog(@"%s", __func__);
}

+ (instancetype)shared
{
    static XJPlayerManager *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[XJPlayerManager alloc] init];
        _shared.muted = YES;

    });
    return _shared;
}

- (void)setMuted:(BOOL)muted
{
    _muted = muted;
    [self.currentPlayerAdapter muted:muted];
}

- (void)playInScrollView:(UIScrollView *)scrollView
               indexPath:(NSIndexPath *)indexPath
      rootViewController:(UIViewController *)rootViewController
{
    [self playInScrollView:scrollView
                indexPath:indexPath
                 autoPlay:NO
       rootViewController:rootViewController];
}

- (void)autoPlayInScrollView:(UIScrollView *)scrollView
          rootViewController:(UIViewController *)rootViewController
{
    [self playInScrollView:scrollView
                 indexPath:nil
                  autoPlay:YES
        rootViewController:rootViewController];
}

- (void)playInScrollView:(UIScrollView *)scrollView
               indexPath:(NSIndexPath *)indexPath
                autoPlay:(BOOL)autoPlay
      rootViewController:(UIViewController *)rootViewController
{
    if (!self.currentPlayerAdapter)
    {
        self.currentPlayerAdapter = [XJPlayerAdapter initWithRootViewController:rootViewController
                                                                     scrollView:scrollView
                                                                       autoPlay:autoPlay
                                                                      indexPath:indexPath];
    }

    if (!autoPlay) [self.currentPlayerAdapter playAtIndexPath:indexPath];
}

- (void)systemPause {
    [self.currentPlayerAdapter systemPause];
}

- (void)systemPlay {
    [self.currentPlayerAdapter systemPlay];
}

- (void)remove
{
    if ([[UIWindow xj_visibleViewController] isKindOfClass:[XJPlayerFullScreenViewController class]]) {
        return;
    }

    [self.currentPlayerAdapter remove];
    self.currentPlayerAdapter = nil;
}

@end
