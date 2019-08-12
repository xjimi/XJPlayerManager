//
//  UIView+PlayerBaseEvent.h
//  Player
//
//  Created by XJIMI on 2018/1/22.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "XJBasePlayerViewDelegate.h"

typedef void(^PlayerReadyBlock)(void);

@interface UIView (XJBasePlayerView)

@property (nonatomic, weak) id <XJBasePlayerViewDelegate> delegate;

/* Player操作功能 */

- (void)xj_setVideoObject:(id)videoObject;

- (void)xj_play;

- (void)xj_pause;

- (void)xj_mute;

- (void)xj_unMute;

- (void)xj_seekToTime:(NSTimeInterval)time
    completionHandler:(void (^)(BOOL finished))completionHandler;

- (void)xj_resetPlayer;

- (NSTimeInterval)xj_currentTime;

- (NSTimeInterval)xj_duration;

- (BOOL)xj_isReadyToPlay;

- (BOOL)xj_isLikelyToKeepUp;

- (BOOL)xj_isValidDuration;

- (void)xj_layoutPortrait;

- (void)xj_layoutFullScreen;

- (void)loadVideo;

@end
