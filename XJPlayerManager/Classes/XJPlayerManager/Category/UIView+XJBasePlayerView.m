//
//  UIView+PlayerBaseEvent.m
//  Player
//
//  Created by XJIMI on 2018/1/22.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import "UIView+XJBasePlayerView.h"
#import <objc/runtime.h>

@implementation UIView (XJBasePlayerView)

- (void)setDelegate:(id<XJBasePlayerViewDelegate>)delegate {
    objc_setAssociatedObject(self, @selector(delegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<XJBasePlayerViewDelegate>)delegate {
    return objc_getAssociatedObject(self, _cmd);
}

/* Player操作功能 */

- (void)xj_vip:(BOOL)isVip {}

- (void)xj_setVideoObject:(id)videoObject {}

- (void)xj_play {}

- (void)xj_pause {}

- (void)xj_mute {}

- (void)xj_unMute {}

- (void)xj_seekToTime:(NSTimeInterval)time
    completionHandler:(void (^)(BOOL))completionHandler {}

- (void)xj_resetPlayer {}


- (void)xj_bufferingSomeSecond {}

- (NSTimeInterval)xj_currentTime {
    return 0;
}

- (NSTimeInterval)xj_duration {
    return 0;
}

- (BOOL)xj_isReadyToPlay {
    return NO;
}

- (BOOL)xj_isLikelyToKeepUp {
    return NO;
}

- (BOOL)xj_isValidDuration {
    return NO;
}

- (void)xj_layoutPortrait {
}

- (void)xj_layoutFullScreen {
}

/* Player狀態 */

- (void)xj_playerStatusReadyToPlay {}

- (void)xj_playerStatusBuffering {}

- (void)xj_playerStatusPlaying {}

- (void)xj_playerStatusEnded {}

- (void)xj_playerStatusFailed {}

/* Player更新顯示時間 */

- (void)xj_playerLoadedTimeRangesWithProgress:(CGFloat)progress {}

- (void)xj_playerCurrentTime:(NSTimeInterval)currentTime
                   totalTime:(NSTimeInterval)totalTime {}

- (void)loadVideo {}


@end
