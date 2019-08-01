//
//  XJPlayerManager.m
//  Vidol
//
//  Created by XJIMI on 2019/2/19.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import "XJPlayerManager.h"
#import "XJPlayerAdapter.h"

static void * const kXJPlayerManagerContentOffsetContext = (void*)&kXJPlayerManagerContentOffsetContext;


@interface XJPlayerManager ()

@property (nonatomic, weak) XJPlayerView *playerView;

@property (nonatomic, strong) NSMutableArray *playerAdapters;

@property (nonatomic, strong) XJPlayerAdapter *currentPlayerAdapter;

@end

@implementation XJPlayerManager

+ (instancetype)sharedInstance
{
    static XJPlayerManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[XJPlayerManager alloc] init];
    });
    return _sharedInstance;
}

- (NSMutableArray *)playerAdapters
{
    if (!_playerAdapters) {
        _playerAdapters = [NSMutableArray array];
    }

    return _playerAdapters;
}

/*- (XJPlayerAdapter *)createPlayerAdapterWithScrollView:(UIScrollView * _Nonnull)scrollView
                                             indexPath:(NSIndexPath * _Nonnull)indexPath
                                    rootViewController:(UIViewController * _Nonnull)rootViewController
{

}*/

- (void)playInContainer:(UIView * _Nonnull)container
             playerView:(XJPlayerView * _Nonnull)playerView
     rootViewController:(UIViewController * _Nonnull)rootViewController
{
    self.playerView = playerView;
    self.playerView.playerContainer = container;
    self.playerView.rootViewController = rootViewController;
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
    XJPlayerAdapter *playerAdapter = nil;
    for (XJPlayerAdapter *adapter in self.playerAdapters)
    {
        if (adapter.rootViewController == rootViewController) {
            NSLog(@"isequal rootViewController");
            playerAdapter = adapter;
        }
    }

    if (!playerAdapter)
    {
        playerAdapter = [XJPlayerAdapter
                            initWithRootViewController:rootViewController
                            scrollView:scrollView
                            autoPlay:autoPlay
                            indexPath:indexPath];
        [self.playerAdapters addObject:playerAdapter];
    }

    self.currentPlayerAdapter = playerAdapter;

    if (!autoPlay) [self.currentPlayerAdapter playAtIndexPath:indexPath];
}

- (void)pauseFromViewController:(UIViewController * __nullable)viewController
{
    if (viewController) {
        XJPlayerAdapter *playerAdatper = [self checkIfHasAdapterFromViewController:viewController];
        [playerAdatper pause];
    }

    [self.playerView systemPause];
}

- (void)resumeFromViewController:(UIViewController *)viewController
{
    XJPlayerAdapter *playerAdatper = [self checkIfHasAdapterFromViewController:viewController];
    [playerAdatper resume];
    [self.playerView systemPlay];
}

- (void)removeFromViewController:(UIViewController *)viewController
{
    XJPlayerAdapter *playerAdatper = [self checkIfHasAdapterFromViewController:viewController];
    [playerAdatper remove];
    
    if (playerAdatper == self.currentPlayerAdapter) {
        self.currentPlayerAdapter = nil;
    }
    
    [self.playerAdapters removeObject:playerAdatper];
}

- (void)remove
{
    for (XJPlayerAdapter *adapter in self.playerAdapters) {
        [adapter remove];
    }

    self.currentPlayerAdapter = nil;
    [self.playerAdapters removeAllObjects];
}

- (void)dismissFullScreen
{
    [self dismissFullScreenPlayerWithCompletion:nil];
}

- (void)dismissFullScreenPlayerWithCompletion:(BlockDismiss)completion
{
    /*
    [kStackPlayerViewController dismissPlayerWithCompletion:^{
        XJPlayerView *playerView = [self.currentPlayerAdapter currentFullScreenPlayerView];
        if (playerView) {
            [playerView systemPause];
            [playerView dismissFullScreenWithCompletion:completion];
        } else {
            if (completion) completion();
        }
    }];*/
}

- (XJPlayerAdapter *)checkIfHasAdapterFromViewController:(UIViewController *)viewController
{
    for (XJPlayerAdapter *adapter in self.playerAdapters)
    {
        if (adapter.rootViewController == viewController) {
            return adapter;
        }
    }
    return nil;
}

@end
