//
//  XJPlayerAdapter.m
//  Vidol
//
//  Created by XJIMI on 2019/3/5.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import "XJPlayerAdapter.h"
#import "YTPlayerView.h"
#import "AVPlayerView.h"
#import "XJPlayerManager.h"

@interface XJPlayerAdapter ()


@property (nonatomic, assign) UIScrollView *scrollView;

@property (nonatomic, assign, getter=isAutoPlay) BOOL autoPlay;

@property (nonatomic, assign, getter=isObserver) BOOL observer;

@property (nonatomic, assign, getter=isSystemPause) BOOL systemPause;

@end

@implementation XJPlayerAdapter

+ (instancetype)initWithRootViewController:(UIViewController *)rootViewController
                                scrollView:(UIScrollView *)scrollView
                                  autoPlay:(BOOL)autoPlay
                                 indexPath:(NSIndexPath *)indexPath
{
    XJPlayerAdapter *playerAdapter = [[XJPlayerAdapter alloc] init];
    playerAdapter.autoPlay = autoPlay;
    playerAdapter.scrollView = scrollView;
    playerAdapter.rootViewController = rootViewController;
    playerAdapter.players = [NSMutableDictionary dictionary];

    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
    [playerAdapter.scrollView addObserver:playerAdapter forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:options context:nil];
    playerAdapter.observer = YES;

    return playerAdapter;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        if (!self.isSystemPause) [self scrollViewDidScroll];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)scrollViewDidScroll
{
    NSArray *visibleCells;
    
    if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.scrollView;
        visibleCells = [[collectionView indexPathsForVisibleItems] sortedArrayUsingSelector:@selector(compare:)];
    } else if ([self.scrollView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.scrollView;
        visibleCells = [tableView indexPathsForVisibleRows];
    }
    
    if (!self.autoPlay)
    {
        for (NSString *key in self.players.allKeys)
        {
            XJPlayerView *pv = [self.players objectForKey:key];
            
            if (pv.isFullScreening) return;
            
            pv.alpha = 0.0f;
            if (pv.isPlayable)
            {
                NSArray *obj =  [key componentsSeparatedByString:@"_"];
                NSInteger section = [obj[0] integerValue];
                NSInteger row = [obj[1] integerValue];
                
                for (NSIndexPath *indexPath in visibleCells)
                {
                    if (indexPath.section == section && indexPath.row == row)
                    {
                        pv.alpha = 1.0f;
                        UIView *playerContainer = [self playerContainerAtIndexPath:indexPath];
                        CGRect targetRect = [playerContainer convertRect:playerContainer.bounds toView:self.rootViewController.view];
                        CGFloat rnageH = targetRect.size.height * .5;

                        if (![playerContainer.subviews containsObject:pv])
                        {
                            pv.playerContainer = playerContainer;
                            pv.frame = playerContainer.bounds;
                            NSLog(@"add playerContainer : %@", pv);
                            //[playerContainer addSubview:pv];
                        }
                        
                        if (targetRect.origin.y <= -rnageH ||
                            targetRect.origin.y + rnageH >= self.scrollView.frame.size.height)
                        {
                            NSLog(@"- 關 %ld", (long)indexPath.row);
                            [pv systemPause];
                            /*[UIView animateWithDuration:.15 animations:^{
                             pv.alpha = 0.0f;
                             }];*/
                            return;
                        }

                        if (pv.isPauseBySystem) {
                            NSLog(@"[playerView:: systemPlay ==== ]");
                            [pv systemPlay];
                        }
                        return;
                    }
                }
            }
        }
        
        return;
    }
    
    NSIndexPath *playableIndexPath = nil;
    NSIndexPath *closeIndexPath = nil;
    for (NSIndexPath *indexPath in visibleCells)
    {
        UIView *playerContainer = [self playerContainerAtIndexPath:indexPath];
        if (playerContainer)
        {
            if (playerContainer)
            {
                CGRect targetRect = [playerContainer convertRect:playerContainer.bounds toView:self.rootViewController.view];
                CGFloat rnageH = targetRect.size.height * .5;
                if (targetRect.origin.y <= -rnageH)
                {
                    closeIndexPath = indexPath;
                    //playerView.hidden = NO;
                    //NSLog(@"tg %ld : %f : %@", [tableView indexPathForCell:videoCell].row, maxH, NSStringFromCGRect(targetRect));
                    NSLog(@"- 關 %ld", closeIndexPath.row);
                }
                else if (targetRect.origin.y + rnageH <= self.scrollView.frame.size.height)
                {
                    if (!playableIndexPath) {
                        playableIndexPath = indexPath;
                    }
                }
            }
        }
    }
    
    if (!playableIndexPath) return;
    
    NSString *identifier = [NSString stringWithFormat:@"%ld_%ld", (long)playableIndexPath.section, (long)playableIndexPath.row];
    
    XJPlayerView *playerView = [self.players objectForKey:identifier];
    UIView *playerContainer = [self playerContainerAtIndexPath:playableIndexPath];
    XJPlayerModel *playerData = [self playerDataAtIndexPath:playableIndexPath];
    if (!playerData) return;
    
    if (self.isAutoPlay)
    {
        for (NSString *key in self.players.allKeys)
        {
            if (![key isEqualToString:identifier])
            {
                XJPlayerView *pv = [self.players objectForKey:key];
                if (pv.isPlayable)
                {
                    NSLog(@"remove playerView:: --");
                    [pv systemPause];
                    [UIView animateWithDuration:.15 animations:^{
                        pv.alpha = 0.0f;
                    }];
                }
                pv.playable = NO;
            }
        }
        
        if (!playerView)
        {
            NSLog(@"create playerView:: +");
            UIView *playerContainer = [self playerContainerAtIndexPath:playableIndexPath];
            playerView = [self playerViewWithPlayerModel:playerData
                                         playerContainer:playerContainer
                                      rootViewController:self.rootViewController];
            [self.players setObject:playerView forKey:identifier];
        }
    }
    else
    {
        for (NSString *key in self.players.allKeys)
        {
            XJPlayerView *pv = [self.players objectForKey:key];
            if ([key isEqualToString:identifier] && pv.isPlayable)
            {
                playerView = pv;
            }
            else
            {
                [pv systemPause];
                [UIView animateWithDuration:.15 animations:^{
                    pv.alpha = 0.0f;
                }];
            }
        }
    }
    
    if (!playerView) return;
    
    if (playerView.isFullScreening) return;
    
    if (![playerContainer.subviews containsObject:playerView])
    {
        NSLog(@"add playerView:: ++ ");
        [playerContainer addSubview:playerView];
    }
    
    if (!playerView.alpha)
    {
        [UIView animateWithDuration:.15 animations:^{
            playerView.alpha = 1.0f;
        }];
    }
    
    playerView.playable = YES;
    if (playerView.isPauseBySystem) {
        NSLog(@"[playerView:: systemPlay ==== ]");
        [playerView systemPlay];
    }
}

- (XJPlayerView *)currentFullScreenPlayerView
{
    __block XJPlayerView *fullscreenView;
    
    [self.players enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, XJPlayerView * playerView, BOOL * _Nonnull stop) {
        if (playerView.isFullScreening) {
            fullscreenView = playerView;
            *stop = YES;
            return;
        }
    }];
    
    return fullscreenView;
}

- (void)pause
{
    self.systemPause = YES;
    for (XJPlayerView *player in self.players.allValues) {
        if (player.playable && !player.isFullScreening) {
            [player systemPause];
        }
    }
}

- (void)resume
{
    self.systemPause = NO;
    [self scrollViewDidScroll];
}

- (void)remove
{
    if (!self.scrollView)
    {
        self.rootViewController = nil;
        return;
    }

    if (self.isObserver)
    {
        [self.scrollView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) context:nil];
        self.observer = NO;
    }

    for (NSString *key in self.players.allKeys)
    {
        XJPlayerView *player = [self.players objectForKey:key];
        [player removeFromSuperview];
        player = nil;
    }
    [self.players removeAllObjects];
    self.scrollView = nil;
}


- (void)playAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) return;
    NSString *identifier = [NSString stringWithFormat:@"%ld_%ld", (long)indexPath.section, (long)indexPath.row];
    XJPlayerView *playerView = [self.players objectForKey:identifier];

    UIView *playerContainer = nil;
    XJPlayerModel *playerData = nil;
    
    playerContainer = [self playerContainerAtIndexPath:indexPath];
    playerData = [self playerDataAtIndexPath:indexPath];
    
    for (NSString *key in self.players.allKeys)
    {
        if (![key isEqualToString:identifier])
        {
            XJPlayerView *pv = [self.players objectForKey:key];
            if (pv.isPlayable)
            {
                NSLog(@"remove playerView:: --");
                [pv systemPause];
                [UIView animateWithDuration:.15 animations:^{
                    pv.alpha = 0.0f;
                }];
            }
            pv.playable = NO;
        }
    }

    if (!playerView)
    {
        NSLog(@"playerData.videoUrl : %@", playerData.videoUrl);
        playerView = [self playerViewWithPlayerModel:playerData
                                     playerContainer:playerContainer
                                  rootViewController:self.rootViewController];
        [self.players setObject:playerView forKey:identifier];
    }

    if (![playerContainer.subviews containsObject:playerView])
    {
        NSLog(@"add playerView:: ++ ");
        [playerContainer addSubview:playerView];
    }

    if (!playerView.alpha)
    {
        [UIView animateWithDuration:.15 animations:^{
            playerView.alpha = 1.0f;
        }];
    }

    playerView.playable = YES;
    [playerView play];
}


- (XJPlayerView *)playerViewWithPlayerModel:(XJPlayerModel *)playerModel
                            playerContainer:(UIView *)playerContainer
                         rootViewController:(UIViewController *)rootViewController
{
    UIView *player;
    switch (playerModel.playerType) {
        case XJPlayerTypeYoutube:
            player = [[YTBPlayerView alloc] init];
            break;
        case XJPlayerTypeBC:
            player = [[BCPlayerView alloc] init];
            break;
        case XJPlayerTypeNormal:
            player = [[AVPlayerView alloc] init];
            break;
        default:
            player = [[AVPlayerView alloc] init];
            break;
    }

    XJPlayerView *playerView = [[XJPlayerView alloc] init];
    //playerView.delegate = self;
    [playerView setPlayerView:player controlView:nil playerModel:playerModel];
    NSLog(@"vCell.cover2 : %@", playerContainer);
    playerView.playerContainer = playerContainer;
    playerView.rootViewController = rootViewController;
    return playerView;
}

#pragma mark XJPlayerManagerProtocol

- (UIView *)findPlayerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *cell = nil;
    if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.scrollView;
        cell = [collectionView cellForItemAtIndexPath:indexPath];
    } else if ([self.scrollView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.scrollView;
        cell = [tableView cellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}

- (UIView *)playerContainerAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *cell = [self findPlayerCellAtIndexPath:indexPath];
    return [self playerManagerProtocolWithView:cell selector:@selector(playerContainer)];
}

- (XJPlayerModel *)playerDataAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *cell = [self findPlayerCellAtIndexPath:indexPath];
    if (![[cell class] conformsToProtocol:@protocol(XJPlayerManagerProtocol)]) return nil;
    
    UIView <XJPlayerManagerProtocol> *viewProtocol = (UIView <XJPlayerManagerProtocol> *)cell;
    return viewProtocol.playerData;
}

- (id)playerManagerProtocolWithView:(UIView *)view selector:(SEL)selector
{
    if (![[view class] conformsToProtocol:@protocol(XJPlayerManagerProtocol)]) return nil;

    UIView <XJPlayerManagerProtocol> *viewProtocol = (UIView <XJPlayerManagerProtocol> *)view;
    if ([viewProtocol respondsToSelector:selector]) {

        IMP imp = [view methodForSelector:selector];
        id (*func)(id, SEL) = (void *)imp;
        return view ? func(view, selector) : nil;
    }

    return nil;
}

@end