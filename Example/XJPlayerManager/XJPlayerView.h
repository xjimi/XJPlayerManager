//
//  XJPlayerView.h
//  Player
//
//  Created by XJIMI on 2018/1/22.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPlayerModel.h"

#define PortraitW MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define PortraitH MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)

typedef NS_ENUM(NSInteger, XJPlayerStatus) {
    XJPlayerStatusNone,
    XJPlayerStatusReadyToPlay,
    XJPlayerStatusBuffering,
    XJPlayerStatusPlaying,
    XJPlayerStatusPause,
    XJPlayerStatusEnded,
    XJPlayerStatusFailed,
    XJPlayerStatusFailedToPlayToEndTime,
    XJPlayerStatusAccessDenied
};

@class XJPlayerView;
@protocol XJPlayerViewDelegate <NSObject>
@optional

- (void)xj_playerView:(XJPlayerView *)playerView sliderDraggedTime:(NSTimeInterval)time;

- (void)xj_playerView:(UIView *)playerView didChangeStatus:(XJPlayerStatus)status;

- (void)xj_playerView:(UIView *)playerView didPlayTime:(NSTimeInterval)playTime;

- (void)xj_playerViewReadyToPlay:(UIView *)playerView;

- (void)xj_playerViewAccessDenied:(UIView *)playerView;

- (void)xj_playerViewDidSelectShareMedia:(UIView *)playerView;

- (void)xj_playerViewDidSelectNextEpisode:(UIView *)playerView;

- (void)xj_playerViewDidSelectCast:(UIView *)playerView;

@end


@interface XJPlayerView : UIView

@property (nonatomic, weak) id < XJPlayerViewDelegate >  delegate;

@property (nonatomic, assign) BOOL playerPushedOrPresented;

@property (nonatomic, assign, getter=isFullScreenEnabled) BOOL fullScreenEnabled;

@property (nonatomic, readonly, getter=isDragged) BOOL dragged;

@property (nonatomic, weak) UIView *playerContainer;

@property (nonatomic, weak) UIViewController *rootViewController;

@property (nonatomic, assign, getter=isPlayable) BOOL playable;

@property (nonatomic, assign, readonly, getter=isPauseByUser) BOOL pauseByUser;
@property (nonatomic, assign, readonly, getter=isPauseBySystem) BOOL pauseBySystem;
@property (nonatomic, assign, readonly, getter=isFullScreening) BOOL fullScreening;


- (void)setPlayerView:(UIView *)playerView
          controlView:(UIView *)controlView
          playerModel:(XJPlayerModel *)playerModel;

- (void)playerModel:(XJPlayerModel *)playerModel;

- (void)play;
- (void)systemPlay;

- (void)pause;
- (void)systemPause;

- (void)seekToTime:(NSTimeInterval)time;

- (NSTimeInterval)getCurrentPlayedTime;

- (void)dismissFullScreenWithCompletion:(void (^)(void))completion;

- (void)remove;

- (void)watchLaterState:(BOOL)state;

- (void)showLogo;

- (void)showPreviewText:(NSAttributedString *)text;

- (void)showNextButton;

- (void)showCastButton;

@end
