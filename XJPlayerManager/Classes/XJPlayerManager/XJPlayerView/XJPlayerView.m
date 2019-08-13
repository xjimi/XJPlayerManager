//
//  XJPlayerView.m
//  Player
//
//  Created by XJIMI on 2018/1/22.
//  Copyright © 2018年 XJIMI All rights reserved.
//

#import "XJPlayerView.h"
#import "UIView+XJBasePlayerView.h"
#import "UIView+PlayerControlsView.h"
#import "AVPlayerView.h"
#import "XJPlayerControlsView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "XJPlayerFullScreenViewController.h"
#import "XJPlayerGesture.h"
#import <Masonry/Masonry.h>
#import <XJScrollViewStateManager/XJNetworkStatusMonitor.h>
#import <XJUtil/UIWindow+XJVisible.h>
#import "YTPlayerView.h"

@interface XJPlayerView () < XJBasePlayerViewDelegate, XJPlayerControlsViewDelegate, XJPlayerGestureDelegate >

@property (nonatomic, strong) UIView                 *player;

@property (nonatomic, strong) UIView                 *controlView;

@property (nonatomic, strong) XJPlayerModel          *playerModel;

@property (nonatomic, assign) XJPlayerStatus         status;

@property (nonatomic, assign) BOOL                   isStatusFailed;

@property (nonatomic, assign) NSInteger              seekTime;

@property (nonatomic, assign, getter=isDragged) BOOL dragged;

@property (nonatomic, assign) CGFloat                sliderLastValue;

@property (nonatomic, assign, getter=isFullScreen) BOOL fullScreen;

@property (nonatomic, assign, getter=isFullScreenRotating) BOOL fullScreenRotating;

@property (nonatomic, assign) UIDeviceOrientation deviceOrientationLandscape;

@property (nonatomic, strong) XJPlayerFullScreenViewController *fullScreenVC;

@property (nonatomic, assign) CGFloat fullScreenOriginPosY;

@property (nonatomic, strong) XJPlayerGesture *playerGesture;

@property (nonatomic, assign, getter=isBuffering) BOOL buffering;


@property (nonatomic, strong) UIView *adContainer;

@property (nonatomic, strong) XJNetworkStatusMonitor *networkStatusMonitor;

/**
 使用者自行暫停或播放(點擊下一首歌或resetVideoUrl時會回復為PauseByUser = NO)
 */
@property (nonatomic, assign, getter=isPauseByUser) BOOL pauseByUser;


/**
 系統暫停為最高操作權限，但不干擾使用者pauseByUser行為
 */
@property (nonatomic, assign, getter=isPauseBySystem) BOOL pauseBySystem;

@property (nonatomic, assign, getter=isPauseInBackground) BOOL pauseInBackground;

@end

@implementation XJPlayerView

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [self.controlView xj_controlsCancelAutoFadeOutControlsView];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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

- (void)setup
{
    self.backgroundColor = [UIColor blackColor];
    self.fullScreenEnabled = YES;
    [self addNetworkStatusMonitor];
    [self addNotifications];
}

- (void)remove
{
    [self pause];
    if (self.fullScreenVC) [self.fullScreenVC dismissViewControllerAnimated:NO completion:nil];
    [self resetPlayer:nil];
    [self removeFromSuperview];
}

/*- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.playerContainer && !self.isFullScreening) {
        //self.frame = self.playerContainer.bounds;
        //[self layoutIfNeeded];
    }
}*/

- (void)setPlayerView:(UIView *)playerView
          controlView:(nullable UIView *)controlView
          playerModel:(XJPlayerModel *)playerModel
{
    _hiddenControlsView = NO;
    self.player = playerView;
    self.controlView = controlView ? : [[XJPlayerControlsView alloc] init];
    self.playerModel = playerModel;
    [self configurePlayer];
}

- (void)setPlayer:(UIView *)player
{
    if (_player || !player) return;
    _player = player;
    _player.delegate = self;
    [self addSubview:_player];
    [_player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setControlView:(UIView *)controlView
{
    if (_controlView) return;
    _controlView = controlView;
    _controlView.delegate = self;
    [_controlView xj_controlsHidden:NO];
    [self addSubview:_controlView];
    [_controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setPlayerModel:(XJPlayerModel *)playerModel
{
    if (!playerModel) return;
    _playerModel = playerModel;
    [self resetPlayerWithTitle:playerModel.title coverImageUrl:playerModel.coverImageUrl];
    self.seekTime = playerModel.seekTime ? : 0;
}

- (void)resetPlayer:(nullable UIView *)player
{
    [self.player xj_resetPlayer];
    [self.controlView xj_controlsReset];
    if (!player) {
        [self.controlView xj_controlsShowCoverImageWithUrl:nil];
    }

    _player.delegate = nil;
    [_player removeFromSuperview];
    _player = nil;

    self.player = player;
}

- (void)resetPlayerWithTitle:(NSString *)title coverImageUrl:(NSString *)coverImageUrl
{
    [self.player xj_resetPlayer];
    [self.controlView xj_controlsReset];
    [self.controlView xj_controlsSetTitle:title];
    [self.controlView xj_controlsShowCoverImageWithUrl:coverImageUrl];
}

- (void)resetVideoUrl:(id)url
{
    self.playerModel.videoUrl = url;
    [self configurePlayer];
}

- (void)setPlayerContainer:(UIView *)playerContainer {
    [self addPlayerToContainer:playerContainer];
}

- (void)addPlayerToContainer:(UIView *)container
{
    if (container)
    {
        _playerContainer = container;
        container.userInteractionEnabled = YES;
        [container addSubview:self];
        self.frame = container.bounds;
    }
}

- (void)configurePlayer
{
    if ((self.player && !self.playerModel.videoUrl) ||
        self.networkStatusMonitor.netStatus == NotReachable) {
        self.status = XJPlayerStatusFailed;
        return;
    }

    [self.controlView xj_controlsReset];
    self.status = XJPlayerStatusBuffering;
    id videoObj = self.playerModel.videoUrl ? : self.playerModel.videoObject;
    [self.player xj_setVideoObject:videoObj];
    //self.seekTime = self.seekTime ? : [self.player xj_currentTime];
}

- (void)setHiddenControlsView:(BOOL)hiddenControlsView
{
    //if (_hiddenControlsView == hiddenControlsView) return;
    _hiddenControlsView = hiddenControlsView;
    [self.controlView xj_controlsHidden:hiddenControlsView];
}

- (void)setButtonNextEnabled:(BOOL)buttonNextEnabled
{
    _buttonNextEnabled = buttonNextEnabled;
    [self.controlView xj_controlsBtnNextEnabled:buttonNextEnabled];
}

- (void)setButtonPrevEnabled:(BOOL)buttonPrevEnabled
{
    _buttonPrevEnabled = buttonPrevEnabled;
    [self.controlView xj_controlsBtnPrevEnabled:buttonPrevEnabled];
}

- (void)systemPlay
{
    self.pauseBySystem = NO;
    [self safePlay];
}

- (void)safePlay
{
    if (self.isPauseByUser) [self pause];
    else [self play];
}

- (void)systemPause
{
    self.pauseBySystem = YES;
    [self actionPlay:NO];
}

- (void)play
{
    //if (self.isStatusFailed) return;

    if (self.status == XJPlayerStatusPause) {
        self.status = XJPlayerStatusPlaying;
    }

    [self disablePauseByProperty];
    [self actionPlay:YES];
}

- (void)pause
{
    //if (self.isStatusFailed) return;

    NSLog(@"%s", __func__);
    [self.controlView xj_controlsPlayBtnState:NO];
    if (self.status == XJPlayerStatusPlaying) {
        self.status = XJPlayerStatusPause;
    }

    self.pauseByUser = YES;
    [self actionPlay:NO];
}

- (void)actionPlay:(BOOL)isPlay
{
    //不改變任何播放變數，單純控制UI與播放影片
    if (isPlay)
    {
        if (![self.player isKindOfClass:[YTPlayerView class]]) {
            [self enabledSessionCategoryPlayback];
        }
        [self.player xj_play];
    }
    else
    {
        [self.player xj_pause];
    }

    [self.controlView xj_controlsPlayBtnState:isPlay];
    if ([self.delegate respondsToSelector:@selector(xj_playerView:isPlaying:)]) {
        [self.delegate xj_playerView:self isPlaying:isPlay];
    }
}

- (void)setMuted:(BOOL)muted
{
    _muted = muted;
    if (muted) {
        [self.player xj_mute];
    } else {
        [self.player xj_unMute];
    }
}

- (void)enabledSessionCategoryPlayback
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory: AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
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
         NSLog(@"monitorWithNetworkStatusChange %ld", (long)weakSelf.status);
         if (netStatus != NotReachable)
         {
             if (weakSelf.isStatusFailed) {
                 NSLog(@"monitorWithNetworkStatusChange - configurePlayer");
                 [weakSelf configurePlayer];
             }
         }
     }];
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
            [self processReadyToPlay];
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
                if ([self.delegate respondsToSelector:@selector(xj_playerViewDidPlayToEndTime:)]) {
                    [self.delegate xj_playerViewDidPlayToEndTime:self];
                }
            }
            break;
        }
        case XJPlayerStatusFailed:
            if ([self.delegate respondsToSelector:@selector(xj_playerViewDidFailed:)]) {
                [self.delegate xj_playerViewDidFailed:self];
            }
            break;
        case XJPlayerStatusFailedToPlayToEndTime:
        {
            [self.controlView xj_controlsPlayFailed];
            break;
        }
        case XJPlayerStatusNone:
        case XJPlayerStatusBuffering:
        case XJPlayerStatusPause:
            break;
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

    self.muted = self.playerModel.muted;

    if (self.isPauseBySystem)
    {
        [self systemPause];
    }
    else if (self.isPauseInBackground)
    {
        [self actionPlay:NO];
    }
    else
    {
        NSLog(@"READY TO PLAY - safePlay");
        [self safePlay];
    }

    //由上層決定是否要播放
    if ([self.delegate respondsToSelector:@selector(xj_playerViewReadyToPlay:duration:)]) {
        [self.delegate xj_playerViewReadyToPlay:self duration:duration];
    }


    self.player.alpha = 0.0f;
    __weak typeof(self)weakSelf = self;
    [self.controlView xj_controlsHideCoverImageWithCompletion:^{
        [self.controlView xj_controlsShowControlsView];
        [UIView animateWithDuration:.3 animations:^{
            weakSelf.player.alpha = 1.0f;
        }];
    }];
}

- (void)seekToTime:(NSTimeInterval)time
{
    if (self.isStatusFailed) return;
    [self.controlView xj_controlsBuffering:YES];
    [self.player xj_pause];

    if ([self.player xj_isValidDuration])
    {
        NSTimeInterval duration = [self.player xj_duration];
        CGFloat progress = time / duration;
        progress = isnan(progress) ? 0 : progress;
        [self.controlView xj_controlsSetProgress:progress];
        if ([self.delegate respondsToSelector:@selector(xj_playerView:seekToProgress:)]) {
            [self.delegate xj_playerView:self seekToProgress:progress];
        }
    }
    __weak typeof(self)weakSelf = self;
    [self.player xj_seekToTime:time
             completionHandler:^(BOOL finished)
     {
         [weakSelf.controlView xj_controlsBuffering:NO];
         weakSelf.seekTime = 0;
         weakSelf.dragged = NO;

         if (![weakSelf.player xj_isLikelyToKeepUp]) {
             weakSelf.status = XJPlayerStatusBuffering;
         }

         if (weakSelf.isPauseInBackground ||
             weakSelf.isPauseBySystem)
         {
             return;
         }

         [weakSelf safePlay];

     }];
}

- (NSTimeInterval)getCurrentPlayedTime
{
    NSTimeInterval timeInterval = [self.player xj_currentTime];
    return (isnan(timeInterval) || !isfinite(timeInterval)) ? 0 : timeInterval;
}

- (BOOL)isReadyToPlay {
    return [self.player xj_isReadyToPlay];
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
            [self systemPause];
        }
        else if (self.isPauseInBackground)
        {
            [self actionPlay:NO];
        }
        else
        {
            NSLog(@"BUFFERING SOME SECOND - safePlay");
            [self safePlay];
        }
    }
}

#pragma mark - XJPlayerGestureDelegate

- (void)xj_playerGestureSingleTap:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateRecognized)
    {
        if (self.controlView.userInteractionEnabled && !self.hiddenControlsView) {
            [self.controlView xj_controlsShowOrHideControlsView];
        }
    }
}

- (void)xj_playerGestureDoubleTap:(UIGestureRecognizer *)gesture
{
    if (self.isStatusFailed ||
        self.status == XJPlayerStatusEnded ||
        self.hiddenControlsView) return;

    self.pauseByUser = !self.isPauseByUser;
    [self safePlay];
}

- (BOOL)xj_playerGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) return NO;
    return YES;
}

#pragma mark - FullScreen

- (BOOL)isFullScreening {
    return self.isFullScreen || self.isFullScreenRotating;
}

- (void)presentFullScreen
{
    if (self.isPauseBySystem ||
        [UIWindow xj_rootViewController].presentedViewController ||
        self.isFullScreening ||
        !self.isFullScreenEnabled) return;

    self.fullScreenRotating = YES;
    [self presentFullScreenWithPlayerView:self containerView:self.playerContainer];
    [self.player xj_layoutFullScreen];
    [self.controlView xj_controlsLayoutFullScreen];

    self.fullScreenRotating = NO;
    self.fullScreen = YES;
}

- (void)presentFullScreenWithPlayerView:(UIView *)playerView containerView:(UIView *)containerView
{
    XJPlayerFullScreenViewController *vc = [XJPlayerFullScreenViewController initWithPlayerContainer:self.playerContainer playerView:self];
    [self.rootViewController presentViewController:vc animated:YES completion:nil];
}

- (void)dismissFullScreenWithCompletion:(nullable void (^)(void))completion
{
    if (self.isFullScreenRotating || !self.isFullScreen)
    {
        if (completion) completion();
        return;
    }

    self.fullScreenRotating = YES;
    [self endEditing:YES];
    [self.player xj_layoutPortrait];
    [self.controlView xj_controlsLayoutPortrait];
    __weak typeof(self)weakSelf = self;
    [self.rootViewController dismissViewControllerAnimated:YES completion:^{

        weakSelf.fullScreenRotating = NO;
        weakSelf.fullScreen = NO;
        if (completion) completion();

    }];
}

#pragma mark - XJSlider

- (void)xj_sliderTouchBegan:(CGFloat)progress {
    [self xj_controlsView:nil sliderTouchBegan:progress];
}

- (void)xj_sliderValueChanged:(CGFloat)progress {
    [self xj_controlsView:nil sliderValueChanged:progress];
}

- (void)xj_sliderTouchEnded:(CGFloat)progress {
    [self xj_controlsView:nil sliderTouchEnded:progress];
}

- (void)xj_sliderTouchCancelled:(CGFloat)progress {
    [self xj_controlsView:nil sliderTouchCancelled:progress];
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
    }
    else
    {
        [self dismissFullScreenWithCompletion:nil];
    }
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

- (void)xj_controlsView:(UIView *)controlsView actionPrev:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(xj_playerViewDidSelectPrevEpisode:)]) {
        [self.delegate xj_playerViewDidSelectPrevEpisode:self];
    }
}

- (void)xj_controlsView:(UIView *)controlsView actionError:(UIButton *)sender {
    if (self.isStatusFailed) [self configurePlayer];
}

#pragma mark - Notification

- (void)addNotifications
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    //[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    /*[[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(applicationWillEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];*/

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{

    if (self.didEnterBackground) return;

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

- (void)applicationDidEnterBackground:(NSNotification*)notification
{
    self.didEnterBackground = YES;
    //[self.player xj_removePlayerOnPlayerLaye];
    [self applicationWillEnterBackground:notification];
}

- (void)applicationWillEnterBackground:(NSNotification*)notification {
}

- (void)applicationWillEnterForeground:(NSNotification*)notification {
    //[self.player xj_resetPlayerToPlayerLayer];
}

- (void)applicationDidBecomeActive:(NSNotification*)notification
{
    self.didEnterBackground = NO;
    self.pauseInBackground = NO;

    if (!self.isPauseBySystem) {
        //[self safePlay];
    }
}

- (void)refreshPlayerFrame:(CGRect)frame
{
    self.frame = frame;
    [self layoutIfNeeded];
}

@end
