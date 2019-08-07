//
//  AVPlayerView.m
//  Player
//
//  Created by XJIMI on 2018/1/20.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import "AVPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+XJBasePlayerView.h"

@implementation AVPlayerLayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

@end

@interface AVPlayerView ()

@property (nonatomic, strong) AVPlayer               *player;
@property (nonatomic, strong) AVPlayerItem           *playerItem;
@property (nonatomic, strong) AVURLAsset             *urlAsset;
@property (nonatomic, strong) AVAssetImageGenerator  *imageGenerator;
@property (nonatomic, strong) AVPlayerLayerView      *playerLayerView;
@property (nonatomic, copy)   NSString               *videoGravity;
@property (nonatomic, copy)   NSString               *videoUrl;
@property (nonatomic, strong) id                     timeObserver;

@end

@implementation AVPlayerView

- (void)dealloc
{
    self.delegate = nil;
    self.playerItem = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timeObserver)
    {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }

    NSLog(@"%s", __func__);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayerView.frame = self.bounds;
}

- (void)setup
{
    self.backgroundColor = [UIColor blackColor];
    self.videoGravity = AVLayerVideoGravityResizeAspect;
}

- (void)xj_setVideoObject:(id)videoObject
{
    [self xj_setVideoUrl:videoObject playerReadyBlock:nil];
}

- (void)xj_setVideoUrl:(NSString *)videoUrl
      playerReadyBlock:(PlayerReadyBlock)playerReadyBlock
{
    _videoUrl = videoUrl;
    [self resetPlayer];
    [self initPlayer];
    if (playerReadyBlock) playerReadyBlock();
}

- (void)resetPlayer
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }

    self.playerItem = nil;
    [self.player pause];
    [self.playerLayerView.playerLayer removeFromSuperlayer];
    self.player = nil;
}

- (void)initPlayer
{
    self.urlAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:self.videoUrl]];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    // 初始化playerLayer
    self.playerLayerView = [[AVPlayerLayerView alloc] initWithFrame:self.bounds];
    self.playerLayerView.playerLayer.player = self.player;
    self.playerLayerView.playerLayer.videoGravity = self.videoGravity;
    [self addPeriodicTimeObserver];
}

- (void)xj_play
{
    [self.player play];
}

- (void)xj_pause
{
    [self.player pause];
}

- (void)xj_seekToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL finished))completionHandler
{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
    {
        // seekTime:completionHandler:不能精确定位
        // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
        // 转换成CMTime才能给player来控制播放进度

        [self.player pause];
        CMTime seekTime = CMTimeMake(time, 1); //kCMTimeZero
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:seekTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {

            if (completionHandler) completionHandler(finished);
            if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp)
            {
                if ([weakSelf.delegate respondsToSelector:@selector(xj_playerView:status:)]) {
                    [weakSelf.delegate xj_playerView:weakSelf status:XJPlayerStatusBuffering];
                }
            }

        }];
    }
}

- (void)xj_resetPlayer
{
    [self resetPlayer];
}

/**
 *  根据playerItem，来添加移除观察者
 *
 *  @param playerItem playerItem
 */
- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem) return;

    if (_playerItem)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _playerItem = playerItem;
    if (playerItem)
    {
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.player.currentItem)
    {
        if ([keyPath isEqualToString:@"status"])
        {
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
            {
                NSLog(@"player.currentItem.status ======== XJPlayerStatusReadyToPlay");
                // 添加playerLayer到self.layer
                if (![self.playerLayerView isDescendantOfView:self]) {
                    [self addSubview:self.playerLayerView];
                }
                //[self.playerLayerView.layer insertSublayer:self.playerLayerView.playerLayer atIndex:0];
                if ([self.delegate respondsToSelector:@selector(xj_playerView:status:)]) {
                    [self.delegate xj_playerView:self status:XJPlayerStatusReadyToPlay];
                }
            }
            else if (self.player.currentItem.status == AVPlayerItemStatusFailed)
            {
                NSLog(@"player.currentItem.status ======== AVPlayerItemStatusFailed");

                if ([self.delegate respondsToSelector:@selector(xj_playerView:status:)]) {
                    [self.delegate xj_playerView:self status:XJPlayerStatusFailed];
                }
            }
            else if (self.player.currentItem.status == AVPlayerItemStatusUnknown)
            {

                NSLog(@"player.currentItem.status ======== AVPlayerItemStatusUnknown");

            }

        } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {

            // 计算缓冲进度
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration             = self.playerItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            CGFloat progress            = timeInterval / totalDuration;

            if ([self.delegate respondsToSelector:@selector(xj_playerView:loadedTimeRangesWithProgress:)]) {
                [self.delegate xj_playerView:self loadedTimeRangesWithProgress:progress];
            }

        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {

            // 当缓冲是空的时候
            if (self.playerItem.playbackBufferEmpty)
            {
                if ([self.delegate respondsToSelector:@selector(xj_playerView:status:)]) {
                    [self.delegate xj_playerView:self status:XJPlayerStatusBuffering];
                }

                if ([self.delegate respondsToSelector:@selector(xj_playerViewBufferingSomeSecond)]) {
                    [self.delegate xj_playerViewBufferingSomeSecond];
                }
            }

        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {

            // 当缓冲好的时候
            if (self.playerItem.playbackLikelyToKeepUp)
            {
                if ([self.delegate respondsToSelector:@selector(xj_playerView:status:)]) {
                    [self.delegate xj_playerView:self status:XJPlayerStatusPlaying];
                }
            }
        }
    }
}

- (BOOL)xj_isPlaybackLikelyToKeepUp {
    return self.playerItem.isPlaybackLikelyToKeepUp;
}

- (AVPlayerItem *)xj_currentItem {
    return self.player.currentItem;
}

- (void)addPeriodicTimeObserver
{
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
                                                                  queue:nil usingBlock:^(CMTime time)
    {
        AVPlayerItem *currentItem = weakSelf.playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0)
        {
            NSTimeInterval currentTime = (NSTimeInterval)CMTimeGetSeconds([currentItem currentTime]);
            CGFloat totalTime     = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
            if ([weakSelf.delegate respondsToSelector:@selector(xj_playerView:currentTime:totalTime:)]) {
                [weakSelf.delegate xj_playerView:weakSelf currentTime:currentTime totalTime:totalTime];
            }
        }
    }];
}

- (void)setPlayerLayerGravity:(AVLayerVideoGravity)playerLayerGravity
{
    _playerLayerGravity = playerLayerGravity;
    self.playerLayerView.playerLayer.videoGravity = playerLayerGravity;
    self.videoGravity = playerLayerGravity;
}

- (void)videoPlayDidEnd:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(xj_playerView:status:)]) {
        [self.delegate xj_playerView:self status:XJPlayerStatusEnded];
    }
}

#pragma mark - 计算缓冲进度

/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration
{
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

@end

