//
//  XJAppDelegate.m
//  XJPlayerManager
//
//  Created by xjimi on 07/24/2019.
//  Copyright (c) 2019 xjimi. All rights reserved.
//

#import "XJAppDelegate.h"
#import "DramasViewController.h"
#import <XJUtil/UIWindow+XJVisible.h>
#import "XJPlayerFullScreenViewController.h"
#import "DramasViewController.h"
#import "Albums/AlbumsViewController.h"

@implementation XJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    for (NSInteger i = 0; i < 10; i ++) {
        for (NSInteger j = 0; j < 10; j ++) {
            if (j == 3) break;
            NSLog(@"j : %ld", j);
        }

        NSLog(@"i : %ld", i);

    }

    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [[DramasViewController alloc] init];
    [window makeKeyAndVisible];
    self.window = window;
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    UIViewController *topViewController = [UIWindow xj_visibleViewController];
    if ([topViewController isKindOfClass:[XJPlayerFullScreenViewController class]])
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }

    return UIInterfaceOrientationMaskPortrait;
}


@end
