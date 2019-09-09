//
//  XJPlayerViewDelegate.h
//  Player
//
//  Created by XJIMI on 2018/1/24.
//  Copyright © 2018年 XJIMI All rights reserved.
//
#import "XJPlayerView.h"

@protocol XJBasePlayerViewDelegate <NSObject>

@optional

- (void)xj_playerView:(UIView *)playerView
           loadStatus:(XJPlayerLoadStatus)loadStatus;

- (void)xj_playerView:(UIView *)playerView
           playStatus:(XJPlayerPlayStatus)playStatus;


- (void)xj_playerView:(UIView *)playerView
          currentTime:(NSTimeInterval)currentTime
            totalTime:(NSTimeInterval)totalTime;

- (void)xj_playerView:(UIView *)playerView loadedTimeRangesWithProgress:(CGFloat)progress;

- (void)xj_playerViewBufferingSomeSecond;

@end
