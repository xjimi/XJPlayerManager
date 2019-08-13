//
//  XJPlayerControlsViewDeleagte.h
//  Vidol
//
//  Created by XJIMI on 2018/3/19.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol XJPlayerControlsViewDelegate <NSObject>

@optional

- (void)xj_controlsView:(UIView *)controlsView sliderTouchBegan:(CGFloat)progress;
- (void)xj_controlsView:(UIView *)controlsView sliderValueChanged:(CGFloat)progress;
- (void)xj_controlsView:(UIView *)controlsView sliderTouchEnded:(CGFloat)progress;
- (void)xj_controlsView:(UIView *)controlsView sliderTouchCancelled:(CGFloat)progress;

- (void)xj_controlsView:(UIView *)controlsView actionPlay:(UIButton *)sender;
- (void)xj_controlsView:(UIView *)controlsView actionPrev:(UIButton *)sender;
- (void)xj_controlsView:(UIView *)controlsView actionNext:(UIButton *)sender;
- (void)xj_controlsView:(UIView *)controlsView actionReplay:(UIButton *)sender;
- (void)xj_controlsView:(UIView *)controlsView actionFullScreen:(UIButton *)sender;

- (void)xj_controlsView:(UIView *)controlsView actionShare:(UIButton *)sender;
- (void)xj_controlsView:(UIView *)controlsView actionError:(UIButton *)sender;

@end
