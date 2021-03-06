//
//  XJPlayerView.h
//  Player
//
//  Created by XJIMI on 2018/1/22.
//  Copyright © 2018年 XJIMI All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPlayerModel.h"

NS_ASSUME_NONNULL_BEGIN

@class XJPlayerView;
@protocol XJPlayerViewDelegate <NSObject>
@optional

- (void)xj_playerView:(XJPlayerView *)playerView sliderDraggedTime:(NSTimeInterval)time;

- (void)xj_playerView:(UIView *)playerView didPlayTime:(NSTimeInterval)playTime;

- (void)xj_playerViewReadyToPlay:(UIView *)playerView duration:(NSTimeInterval)duration;

- (void)xj_playerViewStartToPlay:(UIView *)playerView;

- (void)xj_playerView:(UIView *)playerView seekToProgress:(CGFloat)progress;

- (void)xj_playerViewDidSelectNextEpisode:(UIView *)playerView;

- (void)xj_playerViewDidSelectPrevEpisode:(UIView *)playerView;

- (void)xj_playerViewDidPlayToEndTime:(UIView *)playerView;

- (void)xj_playerViewDidFailed:(UIView *)playerView;

- (void)xj_playerView:(UIView *)playerView isFullScreen:(BOOL)isFullScreen;

- (void)xj_playerView:(UIView *)playerView isPlaying:(CGFloat)isPlaying;

@end


typedef NS_ENUM(NSInteger, XJPlayerPlayStatus) {
    XJPlayerPlayStatusUnknown,
    XJPlayerPlayStatusPlaying,
    XJPlayerPlayStatusPaused,
    XJPlayerPlayStatusFailed,
    XJPlayerPlayStatusEnded,
    XJPlayerPlayStatusFailedToPlayToEndTime
};

typedef NS_OPTIONS(NSUInteger, XJPlayerLoadStatus) {
    XJPlayerLoadStatusUnknown        = 0,
    XJPlayerLoadStatusPrepare        = 1 << 0,
    XJPlayerLoadStatusPlayable       = 1 << 1,
    XJPlayerLoadStatusReadyToPlay    = 1 << 2,
    XJPlayerLoadStatusStalled        = 1 << 3,
};

@interface XJPlayerView : UIView

@property (nonatomic, weak, nullable) id < XJPlayerViewDelegate >  delegate;

@property (nonatomic, strong, readonly) UIView *player;

@property (nonatomic, strong, readonly) XJPlayerModel *playerModel;

@property (nonatomic, assign, getter=isFullScreenEnabled) BOOL fullScreenEnabled;

@property (nonatomic, readonly, getter=isDragged) BOOL dragged;

@property (nonatomic, readonly) BOOL isReadyToPlay;

@property (nonatomic, readonly) BOOL isStatusFailed;

@property (nonatomic, assign, getter=isPauseByUser, readonly) BOOL pauseByUser;

@property (nonatomic, assign, getter=isPauseBySystem, readonly) BOOL pauseBySystem;

@property (nonatomic, assign, readonly, getter=isFullScreening) BOOL fullScreening;

@property (nonatomic, assign, getter=isPlayable) BOOL playable;

@property (nonatomic, assign) BOOL didEnterBackground;

@property (nonatomic, assign, getter=isHiddenControlsView) BOOL hiddenControlsView;

@property (nonatomic, assign) BOOL buttonPrevEnabled;

@property (nonatomic, assign) BOOL buttonNextEnabled;

@property (nonatomic, weak) UIView *playerContainer;

@property (nonatomic, weak) UIViewController *rootViewController;

@property (nonatomic, assign, getter=isMuted) BOOL muted;

@property (nonatomic, assign, readonly, getter=isStartToPlay) BOOL startToPlay;


- (void)setPlayerView:(UIView *)playerView
          controlView:(nullable UIView *)controlView
          playerModel:(XJPlayerModel *)playerModel;

- (void)resetPlayer:(nullable UIView *)player;

- (void)resetPlayerWithTitle:(NSString *)title coverImageUrl:(NSString *)coverImageUrl;

- (void)resetVideoUrl:(id)url;

- (void)play;
- (void)safePlay;
- (void)systemPlay;

- (void)pause;
- (void)systemPause;

- (void)actionPlay:(BOOL)isPlay;

- (void)disablePauseByProperty;

- (void)seekToTime:(NSTimeInterval)time;

- (NSTimeInterval)getCurrentPlayedTime;

- (void)dismissFullScreenWithCompletion:(nullable void (^)(void))completion;

- (void)remove;

- (void)refreshPlayerFrame:(CGRect)frame;

/** XJSlider **/
- (void)xj_sliderTouchBegan:(CGFloat)progress;
- (void)xj_sliderValueChanged:(CGFloat)progress;
- (void)xj_sliderTouchEnded:(CGFloat)progress;
- (void)xj_sliderTouchCancelled:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
