//
//  AVPlayerView.m
//  Player
//
//  Created by XJIMI on 2018/1/20.
//  Copyright © 2018年 XJIMI All rights reserved.
//

#import "AVPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+XJBasePlayerView.h"

static NSString *const kStatus                   = @"status";
static NSString *const kLoadedTimeRanges         = @"loadedTimeRanges";
static NSString *const kPlaybackBufferEmpty      = @"playbackBufferEmpty";
static NSString *const kPlaybackLikelyToKeepUp   = @"playbackLikelyToKeepUp";
static NSString *const kPresentationSize         = @"presentationSize";

@interface AVPlayerLayerView : UIView

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVLayerVideoGravity videoGravity;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, assign) NSTimeInterval totalTime;

@end

@implementation AVPlayerLayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)avLayer {
    return (AVPlayerLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)setPlayer:(AVPlayer *)player
{
    if (player == _player) return;
    _player = player;
    self.avLayer.player = player;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    if (videoGravity == self.videoGravity) return;
    [self avLayer].videoGravity = videoGravity;
}

- (AVLayerVideoGravity)videoGravity {
    return [self avLayer].videoGravity;
}

@end

@interface AVPlayerView ()

@property (nonatomic, strong) AVPlayer               *player;
@property (nonatomic, strong) AVPlayerItem           *playerItem;
@property (nonatomic, strong) AVURLAsset             *urlAsset;
@property (nonatomic, strong) AVAssetImageGenerator  *imageGenerator;
@property (nonatomic, strong) AVPlayerLayerView      *playerLayerView;
@property (nonatomic, copy)   NSString               *videoGravity;
@property (nonatomic, strong) NSURL                  *videoURL;
@property (nonatomic, strong) id                     timeObserver;
@property (nonatomic, assign, getter=isReadyToPlay)  BOOL readyToPlay;
@property (nonatomic, assign) XJPlayerLoadStatus     loadStatus;
@property (nonatomic, assign) XJPlayerPlayStatus     playStatus;

@end

@implementation AVPlayerView

- (void)dealloc
{
    self.delegate = nil;
    self.playerItem = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }

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

- (void)setup {
    self.videoGravity = AVLayerVideoGravityResizeAspect;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayerView.frame = self.frame;
}

- (void)resetPlayer
{
    if (self.timeObserver)
    {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }

    [self.player pause];
    self.urlAsset = nil;
    self.playerItem = nil;
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    [self.playerLayerView removeFromSuperview];
    self.playerLayerView = nil;
}

- (void)initPlayer
{
    self.readyToPlay = NO;
    self.loadStatus = XJPlayerLoadStatusPrepare;

    self.urlAsset = [AVURLAsset URLAssetWithURL:self.videoURL options:self.requestHeader];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    //[self enableAudioTracks:YES inPlayerItem:_playerItem];
    [self addPeriodicTimeObserver];

    self.playerLayerView = [[AVPlayerLayerView alloc] init];
    self.playerLayerView.frame = self.bounds;
    self.playerLayerView.player = self.player;
    self.playerLayerGravity = self.videoGravity;
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem) return;

    if (_playerItem) [self removeObservers];
    _playerItem = playerItem;
    if (@available(iOS 10.0, *)) {
        _playerItem.preferredForwardBufferDuration = 5;
        _player.automaticallyWaitsToMinimizeStalling = NO;
    }

    if (playerItem) [self addObservers];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kStatus])
    {
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
        {
            if (self.loadStatus == XJPlayerLoadStatusPrepare)
            {
                NSLog(@"player.currentItem.status ======== XJPlayerStatusReadyToPlay");
                //self.loadStatus = XJPlayerLoadStatusReadyToPlay;
                if (![self.playerLayerView isDescendantOfView:self]) {
                    [self addSubview:self.playerLayerView];
                }
            }
        }
        else if (self.player.currentItem.status == AVPlayerItemStatusFailed)
        {
            NSError *error = self.player.currentItem.error;
            NSLog(@"player.currentItem.status ======== AVPlayerItemStatusFailed : %@", error);
            NSLog(@"%@", self.videoURL.absoluteString);
            self.playStatus = XJPlayerPlayStatusFailed;
        }
        else if (self.player.currentItem.status == AVPlayerItemStatusUnknown)
        {

            NSLog(@"player.currentItem.status ======== AVPlayerItemStatusUnknown");
            self.playStatus = XJPlayerPlayStatusFailed;
        }

    }
    else if ([keyPath isEqualToString:kLoadedTimeRanges])
    {
        if ([self.delegate respondsToSelector:@selector(xj_playerView:loadedTimeRangesWithProgress:)])
        {
            NSTimeInterval timeInterval = [self availableDuration];
            CGFloat progress = timeInterval / self.xj_duration;
            [self.delegate xj_playerView:self loadedTimeRangesWithProgress:progress];
        }

    }
    else if ([keyPath isEqualToString:kPlaybackBufferEmpty])
    {
        if (self.playerItem.playbackBufferEmpty)
        {
            self.loadStatus = XJPlayerLoadStatusStalled;
            if ([self.delegate respondsToSelector:@selector(xj_playerViewBufferingSomeSecond)]) {
                [self.delegate xj_playerViewBufferingSomeSecond];
            }
        }
    }
    else if ([keyPath isEqualToString:kPlaybackLikelyToKeepUp])
    {
        if (self.playerItem.playbackLikelyToKeepUp) {
            self.loadStatus = XJPlayerLoadStatusPlayable;
        }
    }
}

- (void)addPeriodicTimeObserver
{
    __weak typeof(self)weakSelf = self;
    CMTime interval = CMTimeMakeWithSeconds(self.timeRefreshInterval > 0 ? self.timeRefreshInterval : 0.1, NSEC_PER_SEC);
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval
                                     queue:nil usingBlock:^(CMTime time)
                         {

                             NSArray *loadedRanges = weakSelf.playerItem.seekableTimeRanges;
                             if (CMTimeGetSeconds(time) > 0 && !weakSelf.isReadyToPlay)
                             {
                                 // 大於0才把狀態改為可以播放，解決黑屏問題
                                 weakSelf.readyToPlay = YES;
                                 weakSelf.loadStatus = XJPlayerLoadStatusReadyToPlay;
                             }

                             if (loadedRanges.count > 0)
                             {
                                 if ([weakSelf.delegate respondsToSelector:@selector(xj_playerView:currentTime:totalTime:)])
                                 {
                                     [weakSelf.delegate xj_playerView:weakSelf
                                                          currentTime:weakSelf.xj_currentTime
                                                            totalTime:weakSelf.xj_duration];
                                 }
                             }
                         }];
}

- (void)setLoadStatus:(XJPlayerLoadStatus)loadStatus
{
    _loadStatus = loadStatus;
    if ([self.delegate respondsToSelector:@selector(xj_playerView:loadStatus:)]) {
        [self.delegate xj_playerView:self loadStatus:loadStatus];
    }
}

- (void)setPlayStatus:(XJPlayerPlayStatus)playStatus
{
    _playStatus = playStatus;
    if ([self.delegate respondsToSelector:@selector(xj_playerView:playStatus:)]) {
        [self.delegate xj_playerView:self playStatus:playStatus];
    }
}

- (void)setPlayerLayerGravity:(AVLayerVideoGravity)playerLayerGravity
{
    _playerLayerGravity = playerLayerGravity;
    self.playerLayerView.videoGravity = playerLayerGravity;
    self.videoGravity = playerLayerGravity;
}

- (void)videoPlayDidEnd:(NSNotification *)notification {
    self.playStatus = XJPlayerPlayStatusEnded;
}

- (void)removeObservers
{
    [_playerItem removeObserver:self forKeyPath:kStatus];
    [_playerItem removeObserver:self forKeyPath:kLoadedTimeRanges];
    [_playerItem removeObserver:self forKeyPath:kPlaybackBufferEmpty];
    [_playerItem removeObserver:self forKeyPath:kPlaybackLikelyToKeepUp];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

- (void)addObservers
{
    [_playerItem addObserver:self forKeyPath:kStatus options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:kLoadedTimeRanges options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:kPlaybackBufferEmpty options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:kPlaybackLikelyToKeepUp options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

#pragma mark - setter

- (void)xj_setVideoObject:(id)videoObject
{
    if ([videoObject isKindOfClass:[NSURL class]]) {
        _videoURL = (NSURL *)videoObject;
    } else if ([videoObject isKindOfClass:[NSString class]]) {
        _videoURL = [NSURL URLWithString:videoObject];
    }

    if (!_videoURL) return;
    [self resetPlayer];
    [self initPlayer];
}

- (void)xj_seekToTime:(NSTimeInterval)time
    completionHandler:(void (^)(BOOL finished))completionHandler
{
    if ([self xj_isReadyToPlay])
    {
        CMTime seekTime = CMTimeMake(time, 1);
        if (![self xj_isValidDuration])
        {
            NSLog(@"kCMTimePositiveInfinity %f", time);
            seekTime = kCMTimePositiveInfinity;
        }

        [self.player seekToTime:seekTime
                toleranceBefore:kCMTimeZero
                 toleranceAfter:kCMTimeZero
              completionHandler:^(BOOL finished) {
                  if (completionHandler) completionHandler(finished);
              }];
    }
}

- (void)xj_play {
    [self.player play];
}

- (void)xj_pause {
    [self.player pause];
}

- (void)xj_mute {
    self.player.muted = YES;
}

- (void)xj_unMute {
    self.player.muted = NO;
}

- (void)xj_resetPlayer {
    [self resetPlayer];
}

#pragma mark - getter

- (BOOL)xj_isReadyToPlay {
    return (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay);
}

- (BOOL)xj_isLikelyToKeepUp {
    return self.player.currentItem.isPlaybackLikelyToKeepUp;
}

- (BOOL)xj_isValidDuration
{
    NSTimeInterval duration = [self xj_duration];
    return !(isnan(duration) || !isfinite(duration) || !duration);
}

- (float)rate {
    return _rate == 0 ?1:_rate;
}

- (NSTimeInterval)xj_duration
{
    NSTimeInterval sec = CMTimeGetSeconds(self.player.currentItem.duration);
    if (isnan(sec)) {
        return 0;
    }
    return sec;
}

- (NSTimeInterval)xj_currentTime
{
    NSTimeInterval sec = CMTimeGetSeconds(self.playerItem.currentTime);
    if (isnan(sec) || sec < 0) {
        return 0;
    }
    return sec;
}

- (BOOL)xj_isPlaybackLikelyToKeepUp {
    return self.playerItem.isPlaybackLikelyToKeepUp;
}

- (AVPlayerItem *)xj_currentItem {
    return self.player.currentItem;
}

#pragma mark - private method

/// Calculate buffer progress
- (NSTimeInterval)availableDuration
{
    NSArray *timeRangeArray = _playerItem.loadedTimeRanges;
    CMTime currentTime = [_player currentTime];
    BOOL foundRange = NO;
    CMTimeRange aTimeRange = {0};
    if (timeRangeArray.count) {
        aTimeRange = [[timeRangeArray objectAtIndex:0] CMTimeRangeValue];
        if (CMTimeRangeContainsTime(aTimeRange, currentTime)) {
            foundRange = YES;
        }
    }

    if (foundRange) {
        CMTime maxTime = CMTimeRangeGetEnd(aTimeRange);
        NSTimeInterval playableDuration = CMTimeGetSeconds(maxTime);
        if (playableDuration > 0) {
            return playableDuration;
        }
    }
    return 0;
}

/// Playback speed switching method
- (void)enableAudioTracks:(BOOL)enable inPlayerItem:(AVPlayerItem*)playerItem
{
    for (AVPlayerItemTrack *track in playerItem.tracks){
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeVideo]) {
            track.enabled = enable;
        }
    }
}

- (void)xj_removePlayerOnPlayerLayer {
    self.playerLayerView.player = nil;
}

- (void)xj_resetPlayerToPlayerLayer {
    self.playerLayerView.player = self.player;
}

@end

