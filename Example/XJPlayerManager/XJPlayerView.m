//
//  XJPlayerView.m
//  Player
//
//  Created by XJIMI on 2018/1/22.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import "XJPlayerView.h"
#import "UIView+XJBasePlayerView.h"
#import "UIView+PlayerControlsView.h"
#import "AVPlayerView.h"
#import "XJPlayerControlsView.h"
#import "XJBasePlayerViewDelegate.h"
#import "XJPlayerControlsViewDelegate.h"
#import "XJPlayerGestureDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "XJPlayerFullScreenViewController.h"
#import "XJPlayerGesture.h"
#import <XJScrollViewStateManager/XJNetworkStatusMonitor.h>
#import <Masonry/Masonry.h>

@interface XJPlayerView () < XJBasePlayerViewDelegate, XJPlayerControlsViewDelegate, XJPlayerGestureDelegate >

@property (nonatomic, strong) UIView                 *player;

@property (nonatomic, strong) UIView                 *controlView;

@property (nonatomic, strong) XJPlayerModel          *playerModel;

@property (nonatomic, assign) XJPlayerStatus         status;

@property (nonatomic, assign) BOOL                   isStatusFailed;

@property (nonatomic, assign) NSInteger              seekTime;

@property (nonatomic, assign, getter=isDragged) BOOL dragged;

@property (nonatomic, assign) BOOL                   didEnterBackground;

@property (nonatomic, assign) CGFloat                sliderLastValue;

@property (nonatomic, assign, getter=isFullScreen) BOOL fullScreen;

@property (nonatomic, assign, getter=isFullScreenRotating) BOOL fullScreenRotating;

@property (nonatomic, assign) UIDeviceOrientation deviceOrientationLandscape;

@property (nonatomic, assign) CGFloat fullScreenOriginPosY;

@property (nonatomic, strong) XJPlayerGesture *playerGesture;

@property (nonatomic, assign, getter=isBuffering) BOOL buffering;

@property (nonatomic, assign, getter=isPauseByUser) BOOL pauseByUser;

/**
    系統暫停為最高操作權限，但不影響 pauseByUser 行為
 */
@property (nonatomic, assign, getter=isPauseBySystem) BOOL pauseBySystem;

@property (nonatomic, assign, getter=isPauseInBackground) BOOL pauseInBackground;

@property (nonatomic, assign, getter=isPlaying) BOOL playing;

@property (nonatomic, strong) XJNetworkStatusMonitor *networkStatusMonitor;

@end

@implementation XJPlayerView

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.controlView xj_controlsCancelAutoFadeOutControlsView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    [self addNetworkStatusMonitor];
}

- (void)remove
{
    [self pause];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    if (self.isFullScreen) [self.rootViewController dismissViewControllerAnimated:NO completion:nil];
    [self removeFromSuperview];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.playerContainer && !self.isFullScreening) {
        self.frame = self.playerContainer.bounds;
    }
}

/*
- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (self.playerContainer && !self.isFullScreening) {
        self.frame = self.playerContainer.bounds;
    }
}*/

- (void)playerModel:(XJPlayerModel *)playerModel
{
    [self setPlayerView:nil controlView:nil playerModel:playerModel];
}

- (void)setPlayerView:(UIView *)playerView
          controlView:(UIView *)controlView
          playerModel:(XJPlayerModel *)playerModel
{
    self.player = playerView ? : [[AVPlayerView alloc] init];
    self.controlView = controlView ? : [[XJPlayerControlsView alloc] init];
    self.playerModel = playerModel;

    [self configurePlayer];
    
    // play ad first
    [self playPreloadAD];
}

- (void)setPlayer:(UIView *)player
{
    if (_player) return;
    _player = player;
    _player.delegate = self;
    [self addSubview:_player];
    [_player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)setControlView:(UIView *)controlView
{
    if (_controlView) return;
    _controlView = controlView;
    _controlView.delegate = self;
    [self addSubview:_controlView];
    [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)setPlayerModel:(XJPlayerModel *)playerModel
{
    _playerModel = playerModel;
    [self.controlView xj_controlsSetTitle:playerModel.title];
    [self.controlView xj_controlsShowCoverImageWithUrl:playerModel.coverImageUrl];
    self.seekTime = playerModel.seekTime ? : 0;
}

- (void)setPlayerContainer:(UIView *)playerContainer {
    [self addPlayerToContainer:playerContainer];
}

- (void)addPlayerToContainer:(UIView *)container
{
    // 这里应该添加判断，因为view有可能为空，当view为空时[view addSubview:self]会crash
    if (container)
    {
        //if ([_playerContainer isEqual:container]) return;
        _playerContainer = container;
        NSLog(@"addPlayerToContainer %@", container);
        //[self removeFromSuperview];
        self.frame = container.bounds;
        [container addSubview:self];
    }
}

- (void)configurePlayer
{
    if (!self.playerModel.videoUrl.length ||
        self.networkStatusMonitor.netStatus == NotReachable) {
        self.status = XJPlayerStatusFailed;
        return;
    }

    self.controlView.userInteractionEnabled = NO;
    self.status = XJPlayerStatusBuffering;
    id videoObj = self.playerModel.videoUrl;
    self.seekTime = self.seekTime ? : [self.player xj_currentTime];
    if ([self.playerModel isKindOfClass:[BCPlayerModel class]])
    {
        BCPlayerModel *playerModel = ((BCPlayerModel *)self.playerModel);
        videoObj = playerModel.video;
    }
    [self.player xj_vip:self.playerModel.is_buyer];
    [self.player xj_setVideoObject:videoObj];

    if (!self.overlayAdManager)
    {
        self.overlayAdManager = [OverlayAdManager initWithAdContainer:self.controlView
                                                     adViewController:self.rootViewController
                                                            episodeId:self.playerModel.episodeId
                                                          programmeId:self.playerModel.programmeId];
        self.overlayAdManager.delegate = self;
    }
}


- (void)resetPlayer
{
    self.status = XJPlayerStatusNone;
    self.didEnterBackground = NO;
    self.seekTime = 0;
    [self pause];
    [self.player xj_resetPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.player = nil;
    self.controlView = nil;
}

- (void)safePlay
{
    if (self.status == XJPlayerStatusEnded) return;
    if (self.isPauseByUser) [self pause];
    else [self play];
}

- (void)systemPlay
{
    self.pauseBySystem = NO;
    [self safePlay];
}

- (void)systemPause
{
    self.pauseBySystem = YES;
    [self actionPlay:NO];
}

- (void)play
{
    [self disablePauseByProperty];
    [self actionPlay:YES];
    //[self sendTrackEventWithAction:@"play" name:nil number:nil];
}

- (void)pause
{
    self.pauseByUser = YES;
    [self actionPlay:NO];
    //[self sendTrackEventWithAction:@"pause" name:nil number:nil];
}

- (void)actionPlay:(BOOL)isPlay
{
    //不改變任何播放變數，單純控制UI與播放影片
    if (isPlay)
    {
        if (self.status == XJPlayerStatusPause) {
            self.status = XJPlayerStatusPlaying;
        }

        [self.player xj_play];
    }
    else
    {
        if (self.status == XJPlayerStatusPlaying) {
            self.status = XJPlayerStatusPause;
        }

        [self.player xj_pause];
    }
    
    [self.controlView xj_controlsPlayBtnState:isPlay];
}

- (void)disablePauseByProperty
{
    self.pauseByUser = NO;
    self.pauseBySystem = NO;
    self.pauseInBackground = NO;
}

- (void)addNetworkStatusMonitor
{
    if (_networkStatusMonitor) return;
    __weak typeof(self)weakSelf = self;
    _networkStatusMonitor =
    [XJNetworkStatusMonitor
     monitorWithNetworkStatusChange:^(NetworkStatus netStatus)
    {
        NSLog(@"monitorWithNetworkStatusChange");
        if (netStatus != NotReachable)
        {
            if (weakSelf.isStatusFailed) {
                NSLog(@"monitorWithNetworkStatusChange - configurePlayer");
                [weakSelf configurePlayer];
            }
        }
    }];
}

- (void)sendTrackEventWithAction:(NSString *)action name:(NSString *)name number:(NSNumber *)num
{
    if (self.playerModel.webUrl)
    {
        NSURL *url = [NSURL URLWithString:self.playerModel.webUrl];
        [MatomoTRACKER trackWithEventWithCategory:@"player" action:action name:name number:num url:url];
    }
}

#pragma mark - BasePlayerViewDelegate

- (void)xj_playerView:(UIView *)playerView status:(XJPlayerStatus)status {
    self.status = status;
}

- (void)xj_playerViewBufferingSomeSecond {
    [self bufferingSomeSecond];
}

- (void)xj_playerView:(UIView *)playerView loadedTimeRangesWithProgress:(CGFloat)progress
{
    //計算Buffer進度
    //[self.controlView zf_playerSetProgress:progress];
}

- (void)xj_playerView:(UIView *)playerView
          currentTime:(NSTimeInterval)currentTime
            totalTime:(NSTimeInterval)totalTime
{
    CGFloat value = currentTime / totalTime;
    [self.overlayAdManager requestAdWithPlayTime:currentTime];
    [self.controlView xj_controlsCurrentTime:currentTime totalTime:totalTime sliderValue:value];
    if ([self.delegate respondsToSelector:@selector(xj_playerView:didPlayTime:)]) {
        [self.delegate xj_playerView:self didPlayTime:currentTime];
    }
}

- (void)setStatus:(XJPlayerStatus)status
{
    _status = status;
    [self.controlView xj_controlsBuffering:status == XJPlayerStatusBuffering];
    
    switch (_status)
    {
        case XJPlayerStatusReadyToPlay:
        {
            [self setNeedsLayout];
            [self layoutIfNeeded];
            [self.controlView xj_controlsIsLiveMode:self.playerModel.isLive];
            __weak typeof(self)weakSelf = self;
            [self.controlView xj_controlsHideCoverImageWithCompletion:^{
                [weakSelf processReadyToPlay];
            }];
            break;
        }
        case XJPlayerStatusPlaying:
        {
            break;
        }
        case XJPlayerStatusEnded:
        {
            if (!self.isDragged)
            {
                // 如果不是拖拽中，直接结束播放
                [self.controlView xj_controlsPlayEnded];
            }
            [self sendTrackEventWithAction:@"finish" name:nil number:nil];
            break;
        }
        case XJPlayerStatusFailed:
        case XJPlayerStatusFailedToPlayToEndTime:
        {
            [self.controlView xj_controlsPlayFailed];
            break;
        }
        case XJPlayerStatusAccessDenied:
        {
            //影片token過期 需重新findReferenceId
            if ([self.delegate respondsToSelector:@selector(xj_playerViewAccessDenied:)]) {
                [self.delegate xj_playerViewAccessDenied:self];
            }
            break;
        }
        case XJPlayerStatusNone:
        case XJPlayerStatusBuffering:
        case XJPlayerStatusPause:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(xj_playerView:didChangeStatus:)]) {
        [self.delegate xj_playerView:self didChangeStatus:_status];
    }
}

- (BOOL)isStatusFailed
{
    return (self.status == XJPlayerStatusFailed ||
            self.status == XJPlayerStatusFailedToPlayToEndTime);
}

- (void)processReadyToPlay
{
    NSTimeInterval duration = [self.player xj_duration];
    NSLog(@" +++ Ready To Play +++ duration : %f", duration);
    if (duration)
    {
        if (self.playerModel.cuePoints.count)
        {
            NSMutableArray *cps = [NSMutableArray arrayWithCapacity:self.playerModel.cuePoints.count];
            for (id obj in self.playerModel.cuePoints)
            {
                NSTimeInterval time = [obj floatValue];
                
                //片尾廣告不畫在bar上面
                if (time == EndCuePointTime) continue;
                
                NSTimeInterval percent = (time / duration) * 100;
                [cps addObject:[NSNumber numberWithFloat:percent]];
            }
            [self.controlView xj_controlsSetMarkPositions:cps];
        }
    }

    if (!self.playerGesture)
    {
        self.playerGesture = [XJPlayerGesture initWithView:self];
        self.playerGesture.delegate = self;
        [self.playerGesture addTapGesture];
    }

    [self.controlView xj_controlsReadyToPlay];

    if ([self.player xj_isValidDuration]) {
        [self.controlView xj_controlsSliderPorgressEnabled:YES];
    }

    if ([self.delegate respondsToSelector:@selector(xj_playerViewReadyToPlay:)]) {
        [self.delegate xj_playerViewReadyToPlay:self];
    }

    //[self.controlView xj_controlsAirPlayEnabled:self.playerModel.is_buyer];
    self.fullScreenEnabled = YES;
    [self addNotifications];
    [self dispatchDelegateSliderDraggedTime:0];

    if (self.isPauseBySystem)
    {
        return;
//        [self systemPause];
    }
    else if (self.isPauseInBackground)
    {
        [self actionPlay:NO];
    }
    else
    {
        [self safePlay];
        if (self.seekTime) [self seekToTime:self.seekTime];
    }
}

- (void)seekToTime:(NSTimeInterval)time
{
    [self.controlView xj_controlsBuffering:YES];
    [self.player xj_pause];
    [self sendTrackEventWithAction:@"seek" name:@"time" number:@(time)];

    if ([self.player xj_isValidDuration])
    {
        NSTimeInterval duration = [self.player xj_duration];
        CGFloat progress = time / duration;
        progress = isnan(progress) ? 0 : progress;
        [self.controlView xj_controlsSetProgress:progress];
    }
    __weak typeof(self)weakSelf = self;
    [self.player xj_seekToTime:time
             completionHandler:^(BOOL finished)
    {
        NSLog(@"seek completed");
        [weakSelf.controlView xj_controlsBuffering:NO];
        weakSelf.seekTime = 0;
        weakSelf.dragged = NO;

        if (![weakSelf.player xj_isLikelyToKeepUp]) {
            weakSelf.status = XJPlayerStatusBuffering;
        }

        if (weakSelf.pauseInBackground ||
            weakSelf.isPauseBySystem ||
            weakSelf.isAdPlaying) {
            return;
        }

        [weakSelf safePlay];

    }];
}

- (NSTimeInterval)getCurrentPlayedTime
{
    NSTimeInterval timeInterval = [self.player xj_currentTime] * 1000;
    return (isnan(timeInterval) || !isfinite(timeInterval)) ? 0 : timeInterval;
}

- (void)xj_playerView:(UIView *)playerView
  didPassCuePointTime:(NSTimeInterval)cuePointTime
                adUrl:(NSString *)adUrl
{
    if ([self.delegate respondsToSelector:@selector(xj_playerView:didPassCuePointTime:)] &&
        (cuePointTime != EndCuePointTime)) {
        [self.delegate xj_playerView:self didPassCuePointTime:cuePointTime];
    }

    if (adUrl.length)
    {
        if (!self.adManager)
        {
            self.adContainer = [[UIView alloc] initWithFrame:self.bounds];
            self.adContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self addSubview:self.adContainer];
            self.adContainer.hidden = YES;
            self.adManager = [XJPlayerAdManager initWithAdContainer:self.adContainer
                                                   adViewController:self.rootViewController];
            self.adManager.delegate = self;
        }
        [self.adManager requestAdWithAdTagUrl:adUrl];
    }
}

#pragma mark - Preload AD
- (void)playPreloadAD
{
    if([self.player hasAD]) {
        NSTimeInterval time = (self.seekTime) ? : 0;
        [self.player playPreloadADAt:time];
    } else {
        [self.player loadVideo];
    }
}

- (void)loadPlayerVideo
{
    // 因為brightcove要播放preload廣告，所以調整成播完廣告再開始load brightcove video
    [self.player loadVideo];
}

#pragma mark - 缓冲较差时候

/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond
{
    if (self.isStatusFailed) return;
    self.status = XJPlayerStatusBuffering;
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    
    if (self.isBuffering) return;
    self.buffering = YES;
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    self.buffering = NO;
    if (![self.player xj_isLikelyToKeepUp])
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bufferingSomeSecond) object:nil];
        [self performSelector:@selector(bufferingSomeSecond) withObject:nil afterDelay:1];
    }
    else
    {
        self.status = XJPlayerStatusPlaying;
        if (self.isPauseBySystem)
        {
            return;
//            [self systemPause];
        }
        else if (self.isPauseInBackground)
        {
            [self actionPlay:NO];
        }
        else
        {
            [self safePlay];
        }
    }
}

#pragma mark - XJPlayerGestureDelegate

- (void)xj_playerGestureSingleTap:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized)
    {
        if (self.controlView.userInteractionEnabled) {
            [self.controlView xj_controlsShowOrHideControlsView];
        }
    }
}

- (void)xj_playerGestureDoubleTap:(UIGestureRecognizer *)gesture
{
    if (self.status == XJPlayerStatusEnded || self.isAdPlaying) return;
    
    if (!self.isPauseByUser) {
        [self pause];
    } else {
        [self play];
    }
}

- (BOOL)xj_playerGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view.superview isKindOfClass:[UITableViewCell class]]) return NO;

    if ([touch.view isKindOfClass:[UIButton class]]) return NO;
    return YES;
}

#pragma mark - FullScreen

- (BOOL)isFullScreening {
    return self.isFullScreen || self.isFullScreenRotating;
}

- (void)presentFullScreenWithPlayerView:(UIView *)playerView containerView:(UIView *)containerView
{
    XJPlayerFullScreenViewController *vc = [XJPlayerFullScreenViewController initWithPlayerContainer:self.playerContainer playerView:self];
    vc.needShowDFP = !self.playerModel.is_buyer; //付費會員不用看dfp廣告
    [self.rootViewController presentViewController:vc animated:YES completion:nil];
}

- (void)presentFullScreen
{
    if (self.isPauseBySystem ||
        kRootViewController.presentedViewController ||
        self.isFullScreening ||
        !self.isFullScreenEnabled) return;
    
    self.fullScreenRotating = YES;
    [self presentFullScreenWithPlayerView:self containerView:self.playerContainer];
    [self.player xj_layoutFullScreen];
    [self.controlView xj_controlsLayoutFullScreen];

    self.fullScreenRotating = NO;
    self.fullScreen = YES;
}

- (void)dismissFullScreenWithCompletion:(void (^)(void))completion
{
    if (self.isFullScreenRotating || !self.isFullScreen)
    {
        if (completion) completion();
        return;
    }
    
    self.fullScreenRotating = YES;
    [self endEditing:YES];
    __weak typeof(self)weakSelf = self;
    [self.player xj_layoutPortrait];
    [self.controlView xj_controlsLayoutPortrait];

    [self.rootViewController dismissViewControllerAnimated:YES completion:^{

        weakSelf.fullScreenRotating = NO;
        weakSelf.fullScreen = NO;
        if (completion) completion();

    }];
}

#pragma mark - xj_controlsView delegate

- (void)xj_controlsView:(UIView *)controlsView sliderTouchBegan:(CGFloat)progress
{
    if ([self.player xj_isReadyToPlay])
    {
        self.dragged = YES;
        NSInteger dragedSeconds = floorf([self.player xj_duration] * progress);
        [self.controlView xj_controlsDraggedTime:dragedSeconds sliderValue:progress];
    }
}

- (void)xj_controlsView:(UIView *)controlsView sliderValueChanged:(CGFloat)progress
{
    if ([self.player xj_isReadyToPlay])
    {
        NSInteger dragedSeconds = floorf([self.player xj_duration] * progress);
        [self.controlView xj_controlsDraggedTime:dragedSeconds sliderValue:progress];
        [self dispatchDelegateSliderDraggedTime:dragedSeconds];
    }
}

- (void)xj_controlsView:(UIView *)controlView sliderTouchEnded:(CGFloat)progress
{
    if ([self.player xj_isReadyToPlay])
    {
        self.dragged = NO;
        NSInteger dragedSeconds = floorf([self.player xj_duration] * progress);
        [self seekToTime:dragedSeconds];
    }
}

- (void)xj_controlsView:(UIView *)controlView sliderTouchCancelled:(CGFloat)progress
{
    self.dragged = NO;
    NSInteger dragedSeconds = floorf([self.player xj_duration] * progress);
    [self dispatchDelegateSliderDraggedTime:dragedSeconds];
}

- (void)dispatchDelegateSliderDraggedTime:(NSTimeInterval)time
{
    if ([self.delegate respondsToSelector:@selector(xj_playerView:sliderDraggedTime:)]) {
        [self.delegate xj_playerView:self sliderDraggedTime:time];
    }
}

- (void)xj_controlsView:(UIView *)controlsView actionPlay:(UIButton *)sender
{
    self.pauseByUser = !self.isPauseByUser;
    [self safePlay];
}

- (void)xj_controlsView:(UIView *)controlsView actionFullScreen:(UIButton *)sender
{
    if (!self.isFullScreen)
    {
        UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
        self.deviceOrientationLandscape = UIDeviceOrientationIsLandscape(deviceOrientation) ? deviceOrientation :  UIDeviceOrientationLandscapeLeft;
        [self presentFullScreen];
//
//        if (self.deviceOrientationLandscape == deviceOrientation && deviceOrientation != UIDeviceOrientationUnknown) {
//            [self presentFullScreen];
//        }
//        else {
//            self.deviceOrientationLandscape = UIDeviceOrientationIsLandscape(deviceOrientation) ? deviceOrientation :  UIDeviceOrientationLandscapeLeft;
//
//            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationUnknown] forKey:@"orientation"];
//            NSNumber *orientationTarget = [NSNumber numberWithInteger:self.deviceOrientationLandscape];
//            [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
//        }

    }
    else
    {
        [self dismissFullScreenWithCompletion:nil];
    }
}

- (void)xj_controlsView:(UIView *)controlsView actionDismiss:(UIButton *)sender
{
    [kStackPlayerViewController dismissPlayer];
}

- (void)xj_controlsView:(UIView *)controlsView actionReplay:(UIButton *)sender
{
    [self seekToTime:0];
    self.status = XJPlayerStatusBuffering;
}

- (void)xj_controlsView:(UIView *)controlsView actionNext:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(xj_playerViewDidSelectNextEpisode:)]) {
        [self.delegate xj_playerViewDidSelectNextEpisode:self];
    }
}

- (void)xj_controlsView:(UIView *)controlsView actionShare:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(xj_playerViewDidSelectShareMedia:)]) {
        [self.delegate xj_playerViewDidSelectShareMedia:self];
    }
}

- (void)xj_controlsView:(UIView *)controlsView actionError:(UIButton *)sender {
    if (self.isStatusFailed) [self configurePlayer];
}

#pragma mark - Notification

- (void)addNotifications
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    UIViewController *vc = [UIWindow visibleViewController];
    if (self.didEnterBackground ||
        [vc isKindOfClass:[SFSafariViewController class]]) return;

    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation)
    {
        case UIDeviceOrientationPortrait:
            if (!self.didEnterBackground) [self dismissFullScreenWithCompletion:nil];
            self.deviceOrientationLandscape = UIDeviceOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationLandscapeLeft :
        case UIDeviceOrientationLandscapeRight:
            self.deviceOrientationLandscape = deviceOrientation;
            if (!self.didEnterBackground) [self presentFullScreen];
            break;
        default:
            break;
    }
}

- (void)applicationWillEnterBackground:(NSNotification*)notification
{
    self.didEnterBackground = YES;
    self.pauseInBackground = YES;
    [self actionPlay:NO];
}

- (void)applicationWillEnterForeground:(NSNotification*)notification {
}

- (void)applicationDidBecomeActive:(NSNotification*)notification
{
    self.didEnterBackground = NO;
    self.pauseInBackground = NO;

    if (!self.isPauseBySystem)
    {
        [self safePlay];
        [self sendTrackEventWithAction:@"resume" name:nil number:nil];
    }
}

- (void)showLogo {
    [self.controlView xj_controlsShowLogo];
}

- (void)showPreviewText:(NSAttributedString *)text {
    [self.controlView xj_controlsShowPreviewText:text];
}

- (void)watchLaterState:(BOOL)state {
    [self.controlView xj_controlsWatchLaterState:state];
}

- (void)showCastButton {
    [self.controlView xj_controlsShowCastButton];
}

- (void)showNextButton {
    [self.controlView xj_controlsShowNextButton];
}

- (void)show360Button {
    [self.controlView xj_controlsShow360Button];
}

- (void)updateOnlineCount:(NSInteger)count {
    [self.controlView xj_controlsUpdateOnlineCount:count];
}

/**
 *  耳机插入、拔出事件
 */
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];

    switch (routeChangeReason)
    {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;

        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
            // 耳机拔掉
            // 拔掉耳机继续播放
            //[self safePlay];
        }
            break;

        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

@end
