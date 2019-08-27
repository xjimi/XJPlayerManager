//
//  UIView+PlayerControlsView.h
//  Vidol
//
//  Created by XJIMI on 2018/3/19.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPlayerControlsViewDelegate.h"

@interface UIView (PlayerControlsView)

@property (nonatomic, weak) id <XJPlayerControlsViewDelegate> delegate;

- (void)xj_controlsReadyToPlay;

- (void)xj_controlsBuffering:(BOOL)buffering;

- (void)xj_controlsCurrentTime:(NSInteger)currentTime
                     totalTime:(NSInteger)totalTime
                   sliderValue:(CGFloat)value;

- (void)xj_controlsDraggedTime:(NSInteger)draggedTime
                   sliderValue:(CGFloat)value;

- (void)xj_controlsReset;

- (void)xj_controlsSetProgress:(CGFloat)progress;

- (void)xj_controlsSetTitle:(NSString *)title;

- (void)xj_controlsMute:(BOOL)mute;

- (void)xj_controlsShowCoverImageWithUrl:(NSString *)url;
- (void)xj_controlsHideCoverImageWithCompletion:(void (^)(void))completion;

- (void)xj_controlsShowControlsView;

- (void)xj_controlsHideControlsView;

- (void)xj_controlsShowOrHideControlsView;

- (void)xj_controlsCancelAutoFadeOutControlsView;

- (void)xj_controlsPlayBtnState:(BOOL)state;

- (void)xj_controlsPlayFailed;

- (void)xj_controlsPlayEnded;

- (void)xj_controlsLayoutPortrait;
- (void)xj_controlsLayoutFullScreen;

- (void)xj_controlsBtnPrevEnabled:(BOOL)enabled;
- (void)xj_controlsBtnNextEnabled:(BOOL)enabled;

- (void)xj_controlsBtnFullScreenHidden:(BOOL)hidden;

- (void)xj_controlsEnabled:(BOOL)enabled;

- (void)xj_controlsHidden:(BOOL)hidden;

- (void)xj_controlsSliderPorgressEnabled:(BOOL)enabled;
- (void)xj_controlsSliderHorizontalGestureEnabled:(BOOL)enabled;
- (void)xj_controlsSliderVerticalGestureEnabled:(BOOL)enabled;

    
- (BOOL)xj_controlsIsShowing;


@end
