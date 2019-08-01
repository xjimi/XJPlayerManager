//
//  UIView+PlayerControlsView.h
//  Vidol
//
//  Created by XJIMI on 2018/3/19.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPlayerControlsViewDeleagte.h"

@interface UIView (PlayerControlsView)

@property (nonatomic, weak) id <XJPlayerControlsViewDelegate> delegate;

/**
 * 正常播放

 * @param currentTime 当前播放时长
 * @param totalTime   视频总时长
 * @param value       slider的value(0.0~1.0)
 */

- (void)xj_controlsReadyToPlay;

- (void)xj_controlsBuffering:(BOOL)buffering;

- (void)xj_controlsCurrentTime:(NSInteger)currentTime
                     totalTime:(NSInteger)totalTime
                   sliderValue:(CGFloat)value;

- (void)xj_controlsDraggedTime:(NSInteger)draggedTime
                   sliderValue:(CGFloat)value;

/**
 * progress显示缓冲进度
 */
- (void)xj_controlsSetProgress:(CGFloat)progress;

- (void)xj_controlsSetTitle:(NSString *)title;

- (void)xj_controlsShowCoverImageWithUrl:(NSString *)url;
- (void)xj_controlsHideCoverImageWithCompletion:(void (^)(void))completion;

- (void)xj_controlsHideControlsView;

- (void)xj_controlsShowOrHideControlsView;

- (void)xj_controlsCancelAutoFadeOutControlsView;

- (void)xj_controlsPlayBtnState:(BOOL)state;

- (void)xj_controlsWatchLaterState:(BOOL)state;

- (void)xj_controlsNextBtnEnabled:(BOOL)enabled;

- (void)xj_controlsPlayFailed;

- (void)xj_controlsPlayEnded;

- (void)xj_controlsLayoutPortrait;

- (void)xj_controlsLayoutFullScreen;

- (void)xj_controlsShowLogo;

- (void)xj_controlsShowPreviewText:(NSAttributedString *)text;

- (void)xj_controlsShowCastButton;

- (void)xj_controlsAirPlayEnabled:(BOOL)enabled;

- (void)xj_controlsShowNextButton;

- (void)xj_controlsShow360Button;

- (void)xj_setResolutions:(NSArray *)resolutions;

- (void)xj_controlsEnabled:(BOOL)enabled;

- (void)xj_controlsSliderPorgressEnabled:(BOOL)enabled;

- (BOOL)xj_controlsIsShowing;

- (void)xj_controlsSetMarkPositions:(NSArray *)positions;

- (void)xj_controlsIsLiveMode:(BOOL)isLive;

- (void)xj_controlsUpdateOnlineCount:(NSInteger)count;

- (void)xj_controlsAddChatMessageView:(UIView *)messageView;

- (void)xj_controlsShowChatMessageView:(BOOL)show;

- (void)xj_controlsShowChatMessageButton;

- (void)xj_controlsHideChatMessageButton;

@end
