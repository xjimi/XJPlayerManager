//
//  YTBPlayerView.m
//  Vidol
//
//  Created by XJIMI on 2018/5/15.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import "YTPlayerView.h"
#import "UIView+XJBasePlayerView.h"
#import <YoutubePlayer_in_WKWebView/WKYTPlayerView.h>
#import <Masonry/Masonry.h>
#import <XJScrollViewStateManager/XJNetworkStatusMonitor.h>
#import "XJPlayerUtils.h"

typedef void(^SeekCompletionHandler)(BOOL);

@interface YTPlayerView () < WKYTPlayerViewDelegate >

@property (nonatomic, strong) WKYTPlayerView *player;

@property (nonatomic, copy) NSString *videoId;

@property (nonatomic, assign, getter=isReadyToPlay) BOOL readyToPlay;

@property (nonatomic, copy) SeekCompletionHandler seekCompletionHandler;

@property (nonatomic, strong) XJNetworkStatusMonitor *networkStatusMonitor;

@property (nonatomic, assign) NSTimeInterval timeLastPlayed;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, assign) WKYTPlayerState playerState;

@end

@implementation YTPlayerView

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor blackColor];
}

- (void)addNetworkMonitor
{
    if (_networkStatusMonitor) return;
    __weak typeof(self)weakSelf = self;
    _networkStatusMonitor =
    [XJNetworkStatusMonitor
     monitorWithNetworkStatusChange:^(NetworkStatus netStatus)
     {
         if (netStatus != NotReachable)
         {
             // hide error

             if (weakSelf.videoId)
             {
                 NSDictionary *playerVars = @{@"origin" :@"http://www.youtube.com",
                                              @"controls"       : @0,
                                              @"playsinline"    : @1,
                                              @"autohide"       : @1,
                                              @"autoplay"       : @1,
                                              @"showinfo"       : @0,
                                              @"modestbranding" : @1,
                                              @"fs"             : @0,
                                              @"html5"          : @1,
                                              @"rel"            : @0,
                                              };
                 [weakSelf.player loadWithVideoId:weakSelf.videoId playerVars:playerVars];
             }
         }
         else
         {
         }
     }];
}

- (void)xj_setVideoObject:(id)videoObject
{
    _videoId = (NSString *)videoObject;
    [self removePlayer];
    [self initPlayer];
    [self addNetworkMonitor];
}

- (void)removePlayer
{
    [self xj_pause];
    [self.player removeFromSuperview];
    self.player.delegate = nil;
    self.player = nil;
}

- (void)initPlayer
{
    self.player = [[WKYTPlayerView alloc] init];
    
    self.player.delegate = self;
    [self addSubview:self.player];

    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {

        if (XJP_ISNEATBANG)
        {
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.centerX.equalTo(self);
            make.width.mas_equalTo(XJP_PortraitW);
        }
        else {
            make.edges.equalTo(self);
        }

    }];
}

- (void)xj_play {
    [self.player playVideo];
}

- (void)xj_pause {
    [self.player pauseVideo];
}

- (void)xj_seekToTime:(NSTimeInterval)time
    completionHandler:(void (^)(BOOL))completionHandler
{
    if (time >= self.duration) {
        // 減1，避免seek到最後一秒會自動重播的問題
        time = self.duration - 1;
    }
    
    if ([self xj_isValidDuration]) {
        self.timeLastPlayed = time;
        [self.player seekToSeconds:time allowSeekAhead:YES];
    } else {
        [self xj_play];
    }

    if (completionHandler) completionHandler(YES);
}

- (NSTimeInterval)xj_duration {
    return self.duration;
}

- (NSTimeInterval)xj_currentTime {
//    [self.player getCurrentTime:^(float currentTime, NSError * _Nullable error) {
//        return currentTime;
//    }];
//    return self.player.currentTime;
    
    return self.currentTime;
}

- (BOOL)xj_isReadyToPlay {
    return self.isReadyToPlay;
}

- (BOOL)xj_isLikelyToKeepUp
{
    return YES; //(self.playerState == kWKYTPlayerStatePlaying);
}

- (BOOL)xj_isValidDuration
{
    NSTimeInterval duration = [self xj_duration];
    return !(isnan(duration) || !isfinite(duration) || !duration);
}

- (void)xj_layoutPortrait
{
    if (XJP_ISNEATBANG)
    {
        [self.player mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).offset(0);
            make.width.mas_equalTo(XJP_PortraitW);
        }];
        [UIView animateWithDuration:.3 animations:^{
            [self layoutIfNeeded];
        }];
    }
}

- (void)xj_layoutFullScreen
{
    if (XJP_ISNEATBANG)
    {
        CGFloat height = XJP_PortraitW;
        CGFloat mw = roundf(height * (16.0 / 9.0));
        [self.player mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(21);
            make.width.mas_equalTo(mw);
        }];
        [UIView animateWithDuration:.3 animations:^{
            [self layoutIfNeeded];
        }];
    }
}

- (void)playerViewChangedStatus:(XJPlayerStatus)status
{
    if ([self.delegate respondsToSelector:@selector(xj_playerView:status:)]) {
        [self.delegate xj_playerView:self status:status];
    }
}

#pragma mark YTPlayerView delegate

- (void)playerViewDidBecomeReady:(WKYTPlayerView *)playerView
{
    /*
        被下架的影片也會進入此 method
        不會拋出任何 Error
     */

    NSLog(@"playerView - DidBecomeReady");
    __weak typeof(self)weakSelf = self;
    [self.player getDuration:^(NSTimeInterval duration, NSError * _Nullable error) {

        weakSelf.readyToPlay = YES;
        weakSelf.duration = duration;
        [weakSelf playerViewChangedStatus:XJPlayerStatusReadyToPlay];

        if (weakSelf.timeLastPlayed) {
            [weakSelf xj_seekToTime:weakSelf.timeLastPlayed completionHandler:nil];
        }

    }];
}

- (void)playerView:(WKYTPlayerView *)playerView didChangeToState:(WKYTPlayerState)state
{
    NSLog(@"WKYTPlayerState : %ld", state);
    switch (state)
    {
        case kWKYTPlayerStateBuffering:
            //[self playerViewChangedStatus:XJPlayerStatusBuffering];
            break;
        case kWKYTPlayerStatePlaying:
            [self playerViewChangedStatus:XJPlayerStatusPlaying];
            break;
        case kWKYTPlayerStatePaused:
            [self playerViewChangedStatus:XJPlayerStatusPause];
            break;
        case kWKYTPlayerStateEnded:
            NSLog(@"kYTPlayerStateEnded -----");
            [self playerViewChangedStatus:XJPlayerStatusEnded];
            break;
        case kWKYTPlayerStateUnknown:
            NSLog(@"kYTPlayerStateUnknown -----");
            [self playerViewChangedStatus:XJPlayerStatusFailed];
            break;
        default:
            break;
    }
}

- (UIColor *)playerViewPreferredWebViewBackgroundColor:(WKYTPlayerView *)playerView {
    return [UIColor blackColor];
}

- (void)playerView:(WKYTPlayerView *)playerView didPlayTime:(float)playTime
{
    self.currentTime = playTime;
    
    if (!self.duration) {
        return;
    }
    
    self.timeLastPlayed = playTime;
    if ([self.delegate respondsToSelector:@selector(xj_playerView:currentTime:totalTime:)]) {
        [self.delegate xj_playerView:self currentTime:playTime totalTime:self.duration];
    }
}

@end
