//
//  XJPlayerControlsView.m
//  Vidol
//
//  Created by XJIMI on 2018/3/19.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import "XJPlayerControlsView.h"
#import "UIView+PlayerControlsView.h"
#import "XJSlider.h"
#import "GradientView.h"
#import "CastIconButton.h"
#import "UIImage+LSAdditions.h"
#import <Masonry/Masonry.h>

#import "ChromeCastManager.h"
#import "PlayerErrorInfoView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+ImageManager.h"
#import "UIButton+CenterSpace.h"
#import <YYText/YYLabel.h>

@interface XJPlayerControlsView ()

/** 占位图 */
@property (nonatomic, strong) UIImageView             *placeholderView;

@property (nonatomic, strong) UIView                  *controlsView;

@property (nonatomic, strong) GradientView            *maskView;

@property (nonatomic, strong) UIView                  *topControlsView;

@property (nonatomic, strong) UIView                  *topLeftControlsView;

@property (nonatomic, strong) UIView                  *bottomControlsView;

@property (nonatomic, strong) UILabel                 *titleLabel;

@property (nonatomic, strong) UIButton                *btn_fullScreen;

@property (nonatomic, strong) UIButton                *btn_chatMessage;

@property (nonatomic, strong) UIButton                *btn_watchLater;

@property (nonatomic, strong) UIButton                *btn_share;

@property (nonatomic, strong) CastIconButton          *btn_cast;

@property (nonatomic, strong) UIButton                *btn_back;

@property (nonatomic, strong) UIButton                *btn_play;

@property (nonatomic, strong) UIButton                *btn_next;

@property (nonatomic, strong) UIButton                *btn_replay;

@property (nonatomic, strong) UIButton                *btn_360;

@property (nonatomic, strong) UIButton                *btn_error;

@property (nonatomic, strong) UIButton                *btn_resolution;

@property (nonatomic, strong) XJSlider                *slider;

@property (nonatomic, strong) UILabel                 *timeLabel;

@property (nonatomic, strong) UILabel                 *sliderTimeLabel;

@property (nonatomic, strong) UIImageView             *logoView;

@property (nonatomic, strong) YYLabel                 *previewLabel;

@property (nonatomic, strong) ResolutionView          *resolutionView;

@property (nonatomic, strong) UIView                  *liveCon;

@property (nonatomic, weak) UIView                    *messageView;

@property (nonatomic, strong) UILabel                 *onlineLabel;

@property (nonatomic, strong) UILabel                 *liveLabel;

@property (nonatomic, assign, getter=isShowing) BOOL  showing;

@property (nonatomic, assign, getter=isDragged) BOOL  dragged;

@property (nonatomic, assign, getter=isPlayEnd) BOOL  playeEnd;

@property (nonatomic, assign, getter=isBuffering) BOOL buffering;

@property (nonatomic, assign, getter=isFullScreen)BOOL fullScreen;

@property (nonatomic, assign, getter=isFullScreenEnabled) BOOL fullScreenEnabled;

@property (nonatomic, assign) BOOL  canShowMessageView;

@property (nonatomic, assign) CGFloat startDragProgress;

@property (nonatomic, assign) CGFloat lastDragProgress;

@property (nonatomic, assign, getter=isLive) BOOL live;

@end

@implementation XJPlayerControlsView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __func__);
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.userInteractionEnabled = NO;
        [self createView];
        [self makeConstraints];
        [self xj_controlsHideControlsView];
        [self xj_controlsLayoutPortrait];

        self.canShowMessageView = NO;
        self.logoView.hidden = YES;
        self.liveCon.hidden = YES;
        self.previewLabel.hidden = YES;
        self.btn_replay.hidden = YES;
        self.btn_watchLater.hidden = YES;
        self.btn_cast.hidden = YES;
        self.slider.mpVolumeView.hidden = YES;
        [self.slider showBuffering];
        [self addNotification];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.btn_error centerImageWithTitleGap:10 imageOnTop:YES];
}

- (void)createView
{
    [self addSubview:self.placeholderView];
    [self addSubview:self.maskView];
    [self addSubview:self.slider];
    [self addSubview:self.btn_error];
    //[self addSubview:self.resolutionView];

    [self addSliderGesture];
    [self.slider addSubview:self.controlsView];
    [self.slider addSubview:self.timeLabel];
    [self.slider addSubview:self.sliderTimeLabel];
    [self.slider addSubview:self.logoView];
    [self addSubview:self.previewLabel];
    [self addSubview:self.liveCon];

    [self.controlsView addSubview:self.topControlsView];
    [self.topControlsView addSubview:self.btn_watchLater];
    [self.topControlsView addSubview:self.btn_share];
    //[self.topControlsView addSubview:self.btn_cast];

    [self.controlsView addSubview:self.topLeftControlsView];
    [self.topLeftControlsView addSubview:self.titleLabel];
    //[self.topLeftControlsView addSubview:self.btn_back];

    [self.controlsView addSubview:self.bottomControlsView];
    [self.bottomControlsView addSubview:self.btn_fullScreen];
    [self.bottomControlsView addSubview:self.slider.mpVolumeView];
    [self.bottomControlsView addSubview:self.btn_play];
    [self.bottomControlsView addSubview:self.btn_next];
    //[self.bottomControlsView addSubview:self.btn_resolution];

    [self.controlsView addSubview:self.btn_replay];
    [self.controlsView addSubview:self.btn_360];
}

- (void)makeConstraints
{
    [self.placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];

    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];

    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        if (XJ_ISNEATBANG) {
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.centerX.equalTo(self);
            make.width.mas_equalTo(PortraitW);
        } else {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }
    }];

    [self.btn_error mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];

    /*
     [self.resolutionView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.right.bottom.equalTo(self);
     make.width.mas_equalTo(150);
     }];*/

    [self.controlsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.slider);
        make.bottom.equalTo(self.slider).offset(-5);
    }];

    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomControlsView);
        make.leading.equalTo(self.btn_next.mas_trailing).offset(10);
        make.width.mas_equalTo(150);
        make.height.equalTo(self.bottomControlsView.mas_height);
    }];

    [self.logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(-15);
        make.height.equalTo(self.logoView.mas_width).multipliedBy(88.0/160.0);
        make.height.equalTo(self.mas_height).multipliedBy(0.15);
    }];

    [self.previewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).mas_offset(0);
        make.bottom.equalTo(self).mas_offset(0);
        make.right.equalTo(self).mas_offset(0);
        make.height.mas_equalTo(25);
    }];

    [self.liveCon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).mas_offset(10);
        make.centerX.equalTo(self);
        make.height.mas_offset(30);
    }];

    CGFloat multiplieH = 30.0 / (PortraitW * (9.0 / 16.0));
    [self.topControlsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.leading.equalTo(self.btn_watchLater.mas_leading).offset(0);
        make.trailing.mas_equalTo(-10);
        make.height.equalTo(self).multipliedBy(multiplieH);
    }];

    [self.topLeftControlsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(26);
        make.leading.equalTo(self.controlsView.mas_leading).offset(10);
        make.trailing.equalTo(self.mas_centerX).offset(-50);
    }];

    [self.bottomControlsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(10);
        make.trailing.mas_equalTo(-10);
        make.bottom.mas_equalTo(-10);
        make.height.equalTo(self).multipliedBy(multiplieH);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topLeftControlsView).offset(15);
        make.top.right.bottom.equalTo(self.topLeftControlsView);
    }];

    [self.btn_play mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bottomControlsView.mas_leading);
        make.centerY.equalTo(self.bottomControlsView.mas_centerY);
        make.width.height.mas_equalTo(self.bottomControlsView.mas_height);
    }];

    [self.btn_next mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.btn_play.mas_trailing).offset(5);
        make.centerY.equalTo(self.bottomControlsView.mas_centerY);
        make.width.height.mas_equalTo(self.bottomControlsView.mas_height);
    }];

    [self.btn_fullScreen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.bottomControlsView.mas_trailing);
        make.centerY.equalTo(self.bottomControlsView.mas_centerY);
        make.width.height.equalTo(self.bottomControlsView.mas_height);
    }];

    [self.slider.mpVolumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.btn_fullScreen.mas_leading).offset(-10);
        make.centerY.equalTo(self.bottomControlsView.mas_centerY);
        make.width.height.equalTo(self.bottomControlsView.mas_height);
    }];
    
    /*
     [self.btn_resolution mas_makeConstraints:^(MASConstraintMaker *make) {
     make.trailing.equalTo(self.btn_fullScreen.mas_leading).offset(-10);
     make.centerY.equalTo(self.bottomControlsView.mas_centerY);
     make.width.mas_equalTo(50);
     make.height.equalTo(self.bottomControlsView.mas_height);
     }];*/

    [self.btn_share mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.topControlsView.mas_trailing);
        make.centerY.equalTo(self.topControlsView.mas_centerY);
        make.width.height.equalTo(self.topControlsView.mas_height);
    }];

    [self.btn_watchLater mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.btn_share.mas_leading).offset(-10);
        make.centerY.equalTo(self.topControlsView.mas_centerY);
        make.width.height.equalTo(self.topControlsView.mas_height);
    }];

    /*[self.btn_cast mas_makeConstraints:^(MASConstraintMaker *make) {
     make.trailing.equalTo(self.btn_watchLater.mas_leading).offset(-13);
     make.centerY.equalTo(self.topControlsView.mas_centerY);
     make.width.height.equalTo(self.topControlsView.mas_height);
     }];*/

    /*[self.btn_back mas_makeConstraints:^(MASConstraintMaker *make) {
     make.leading.equalTo(self.topLeftControlsView.mas_leading);
     make.centerY.equalTo(self.topControlsView.mas_centerY);
     make.width.height.equalTo(self.topLeftControlsView.mas_height);
     }];*/

    [self.btn_replay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.controlsView);
        make.width.height.equalTo(self.topControlsView.mas_height);
    }];

    [self.btn_360 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.controlsView.mas_centerY);
        make.trailing.mas_equalTo(-10);
        make.width.height.equalTo(self.topControlsView.mas_height);
    }];
}

- (void)xj_controlsSliderPorgressEnabled:(BOOL)enabled {
    self.slider.progressEnabled = enabled;
}

- (void)addSliderGesture
{
    [self.slider addProgressSlider];
    [self.slider addLastDragProgressSlider];

    [self.slider addVolumeSlider];
    [self.slider addBrightnessSlider];

    __weak typeof(self)weakSelf = self;
    [self.slider addSliderGestureBeganBlock:^(XJSliderType sliderType) {

        if (sliderType == XJSliderTypeVolume || sliderType == XJSliderTypeBrightness) {
            [weakSelf xj_controlsHideControlsView];
            return;
        }

        weakSelf.dragged = YES;
        weakSelf.startDragProgress = weakSelf.slider.progress;
        weakSelf.btn_replay.hidden = YES;
        [weakSelf xj_controlsHideControlsView];
        [weakSelf.slider showBottomTrackView];
        [UIView animateWithDuration:.15 animations:^{
            weakSelf.timeLabel.alpha = 1.0f;
            weakSelf.sliderTimeLabel.alpha = 1.0f;
            weakSelf.logoView.alpha = 0.0f;
            weakSelf.previewLabel.alpha = 0.0f;
        } completion:nil];

        if ([weakSelf.delegate respondsToSelector:@selector(xj_controlsView:sliderTouchBegan:)]) {
            [weakSelf.delegate xj_controlsView:weakSelf sliderTouchBegan:weakSelf.slider.progress];
        }

    }];

    [self.slider addSliderGestureChangedBlock:^(CGFloat progress) {

        if ([weakSelf.delegate respondsToSelector:@selector(xj_controlsView:sliderValueChanged:)]) {
            [weakSelf.delegate xj_controlsView:weakSelf sliderValueChanged:weakSelf.slider.progress];
        }

    }];

    [self.slider addSliderGestureEndedBlock:^(XJSliderType sliderType) {

        if (sliderType == XJSliderTypeVolume || sliderType == XJSliderTypeBrightness) {
            return;
        }
        //weakSelf.lastDragProgress = weakSelf.slider.progress;
        weakSelf.dragged = NO;
        [UIView animateWithDuration:.3 animations:^{
            weakSelf.sliderTimeLabel.alpha = 0.0f;
        }];

        if (weakSelf.isShowing)
        {
            [weakSelf xj_controlsShowControlsView];
        }
        else
        {
            [UIView animateWithDuration:.3 animations:^{
                weakSelf.timeLabel.alpha = 0.0f;
                weakSelf.logoView.alpha = 1.0f;
                weakSelf.previewLabel.alpha = 1.0f;
            } completion:nil];
        }

        if ([weakSelf.delegate respondsToSelector:@selector(xj_controlsView:sliderTouchEnded:)]) {
            [weakSelf.delegate xj_controlsView:weakSelf sliderTouchEnded:weakSelf.slider.progress];
        }

    }];

    [self.slider addSliderGestureCancelledBlock:^(XJSliderType sliderType) {

        weakSelf.showing = NO;
        weakSelf.dragged = NO;
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            weakSelf.timeLabel.alpha = 0.0f;
            weakSelf.sliderTimeLabel.alpha = 0.0f;
            weakSelf.logoView.alpha = 1.0f;
            weakSelf.previewLabel.alpha = 1.0f;
        } completion:nil];

        if ([weakSelf.delegate respondsToSelector:@selector(xj_controlsView:sliderTouchCancelled:)]) {
            [weakSelf.delegate xj_controlsView:weakSelf sliderTouchCancelled:weakSelf.slider.progress];
        }

    }];
}

- (void)xj_controlsReadyToPlay
{
    [self hideError];
    self.userInteractionEnabled = YES;
}

- (void)xj_controlsBuffering:(BOOL)buffering
{
    self.buffering = buffering;
    if (buffering)
    {
        [self.slider showBuffering];
    }
    else
    {
        [self.slider hideBuffering];
        if (!self.isShowing && !self.isDragged)
        {
            [self.slider hideBottomTrackView];
            [UIView animateWithDuration:.3 animations:^{
                self.timeLabel.alpha = 0.0f;
            }];
        }
    }
}

- (void)xj_controlsShowOrHideControlsView
{
    if (self.isShowing) {
        [self xj_controlsHideControlsView];
    } else {
        [self xj_controlsShowControlsView];
    }
}

- (void)xj_controlsShowControlsView
{
    self.showing = YES;
    [self xj_controlsCancelAutoFadeOutControlsView];
    [self refreshLiveConLayout];
    
    [self bringControlsToFront];

    [UIView animateWithDuration:.15 animations:^{
        [self layoutIfNeeded];
        [self showControls];
    } completion:^(BOOL finished) {
        [self autoFadeOutControlsView];
        [self hideMessageView];
    }];
}

- (void)xj_controlsHideControlsView
{
    if (!self.isDragged) self.showing = NO;
    [self xj_controlsCancelAutoFadeOutControlsView];
    [self refreshLiveConLayout];

    [UIView animateWithDuration:.3 animations:^{
        [self hideControls];
    } completion:^(BOOL finished) {
        [self sendControlsToBack];
        [self showMessageView];
    }];
}

- (void)xj_controlsEnabled:(BOOL)enabled
{
    self.userInteractionEnabled = enabled;
    self.slider.enabled = enabled;
}

- (BOOL)xj_controlsIsShowing {
    return self.isShowing;
}

- (void)xj_controlsShowLogo
{
    self.logoView.alpha = 1.0f;
    self.logoView.hidden = NO;
    /*
     [UIView animateWithDuration:.3 animations:^{
     self.logoView.alpha = 1.0f;
     }];*/
}

- (void)xj_controlsShowPreviewText:(NSAttributedString *)text
{
    self.previewLabel.attributedText = text;
    self.previewLabel.alpha = 1.0f;
    self.previewLabel.hidden = NO;
}

- (void)xj_controlsSetTitle:(NSString *)title {
    if (title.length) self.titleLabel.text = title;
}

- (void)xj_controlsShowCoverImageWithUrl:(NSString *)url {
    if (url.length) [self.placeholderView imageManagerWithURL:url];
}

- (void)xj_controlsHideCoverImageWithCompletion:(void (^)(void))completion
{
    [UIView animateWithDuration:.3 animations:^{
        self.placeholderView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.placeholderView.image = nil;
        if (completion) completion();
    }];
}

- (void)xj_controlsShowCastButton
{
    self.slider.mpVolumeView.hidden = NO;
    self.btn_cast.hidden = NO;
    ChromecastManager.btn_cast = self.btn_cast;
}

- (void)xj_controlsAirPlayEnabled:(BOOL)enabled {
    self.slider.mpVolumeView.hidden = !enabled;
}

- (void)xj_controlsShowNextButton {
    self.btn_next.enabled = YES;
}

- (void)xj_controlsShow360Button {
    self.btn_360.hidden = NO;
}

- (void)xj_setResolutions:(NSArray *)resolutions {
    [self.resolutionView reloadWithResolutions:resolutions];
}

- (void)xj_controlsWatchLaterState:(BOOL)state
{
    self.btn_watchLater.hidden = NO;
    self.btn_watchLater.selected = state;
}

- (void)xj_controlsFullScreenEnabled:(BOOL)enabled {
    self.fullScreenEnabled = enabled;
}

- (void)autoFadeOutControlsView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startAutoFadeOutControlsView) object:nil];
    [self performSelector:@selector(startAutoFadeOutControlsView) withObject:nil afterDelay:3];
}

- (void)startAutoFadeOutControlsView
{
    if (self.btn_play.selected && self.btn_replay.hidden) {
        [self xj_controlsHideControlsView];
    }
}

- (void)xj_controlsCancelAutoFadeOutControlsView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)showControls
{
    self.maskView.alpha = 1.0f;
    self.controlsView.alpha = 1.0f;
    self.logoView.alpha = 0.0f;
    self.previewLabel.alpha = 0.0f;
    if (!self.isDragged)
    {
        [self.slider showBottomTrackView];
        self.timeLabel.alpha = 1.0f;
    }
}

- (void)hideControls
{
    if (!self.isDragged && !self.isBuffering) [self.slider hideBottomTrackView];
    self.maskView.alpha = 0.0f;
    self.controlsView.alpha = 0.0f;
    if (!self.isDragged)
    {
        self.timeLabel.alpha = 0.0f;
        self.logoView.alpha = 1.0f;
        self.previewLabel.alpha = 1.0f;
    }
}

- (void)bringControlsToFront
{
    if (self.messageView && self.canShowMessageView) {
        [self insertSubview:self.messageView belowSubview:self.slider];
        [self.messageView endEditing:YES]; // close keyboard
    }
    
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[OverlayAdButton class]]) {
            [self insertSubview:subView belowSubview:self.slider];
        }
    }
}

- (void)sendControlsToBack
{
    if (self.messageView && self.canShowMessageView) {
        [self insertSubview:self.messageView aboveSubview:self.slider];
    }
    
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[OverlayAdButton class]]) {
            [self insertSubview:subView aboveSubview:self.slider];
        }
    }
}

/////// chat message view /////////////////
- (void)xj_controlsAddChatMessageView:(UIView *)messageView
{
    self.messageView = messageView;
    self.messageView.alpha = (self.canShowMessageView) ? 1.0 : 0.0;
    [self addSubview:self.messageView];
    
    [self.messageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
    
    
    [self xj_controlsShowChatMessageButton];
}

- (void)xj_controlsShowChatMessageView:(BOOL)show
{
    self.canShowMessageView = show;

    if (show) {
        [self xj_controlsHideControlsView];
    } else {
        [self hideControls];
        [self hideMessageView];
    }
}

- (void)xj_controlsShowChatMessageButton
{
    [self.bottomControlsView addSubview:self.btn_chatMessage];
    [self.btn_chatMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.btn_fullScreen.mas_leading).offset(10);
        make.centerY.equalTo(self.bottomControlsView.mas_centerY);
        make.width.height.equalTo(self.bottomControlsView.mas_height);
    }];
}

- (void)xj_controlsHideChatMessageButton
{
    if (_btn_chatMessage) {
        [self.btn_chatMessage removeFromSuperview];
    }
}

- (void)hideMessageView
{
    if (!self.messageView) {
        return;
    }
    
    [UIView animateWithDuration:.15 animations:^{
        self.messageView.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showMessageView
{
    if (!self.messageView || !self.canShowMessageView) {
        return;
    }
    
    [UIView animateWithDuration:.15 animations:^{
        self.messageView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}
//////////////////////////////////////

- (void)xj_controlsLayoutPortrait
{
    [self xj_controlsHideChatMessageButton];
    
    self.titleLabel.hidden = YES;
    self.btn_fullScreen.selected = NO;
    [self refreshLiveConLayout];

    if (XJ_ISNEATBANG && self.bounds.size.width)
    {
        [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(PortraitW);
        }];
        [UIView animateWithDuration:.3 animations:^{
            [self layoutIfNeeded];
        }];
    }
}

- (void)xj_controlsLayoutFullScreen
{
    self.titleLabel.hidden = NO;
    self.btn_fullScreen.selected = YES;
    [self refreshLiveConLayout];

    if (XJ_ISNEATBANG && self.bounds.size.width)
    {
        CGFloat height = PortraitW;
        CGFloat mw = roundf(height * (16.0 / 9.0));
        [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(mw);
        }];
        [UIView animateWithDuration:.3 animations:^{
            [self layoutIfNeeded];
        }];
    }
}

- (void)hideError
{
    if (self.btn_error.alpha == 0) return;
    [UIView animateWithDuration:.3 animations:^{
        self.btn_error.alpha = 0.0f;
    }];
}

- (void)xj_controlsPlayFailed
{
    //有可能錯誤發生在ReadyToPlay前
    self.userInteractionEnabled = YES;
    [UIView animateWithDuration:.3 animations:^{
        self.btn_error.alpha = 1.0f;
    }];
}

- (void)xj_controlsPlayEnded
{
    self.btn_replay.hidden = NO;
    self.btn_play.enabled = NO;
    [self showControls];
}

- (void)xj_controlsPlayBtnState:(BOOL)state
{
    self.btn_play.selected = state;
    if (self.btn_play.selected) [self autoFadeOutControlsView];
}

- (void)xj_controlsCurrentTime:(NSInteger)currentTime
                     totalTime:(NSInteger)totalTime
                   sliderValue:(CGFloat)value
{
    NSString *curTimeStr = [XJPlayerControlsView formatTime:currentTime];
    NSString *durTimeStr =  [XJPlayerControlsView formatTime:totalTime];
    NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", curTimeStr, durTimeStr];
    self.timeLabel.text = timeStr;
    //playingProgress 紀錄正在播放的時間
    self.slider.playingProgress = value;
    if (!self.isDragged)
    {
        if (self.lastDragProgress >= self.startDragProgress)
        {
            //往後 seek >>
            if (value >= self.lastDragProgress) {
                self.slider.progress = value;
            }
        }
        else
        {
            //往回 seek <<
            if (value >= self.lastDragProgress &&
                value <  self.startDragProgress )

            {
                self.slider.progress = value;
            }
        }
    }
}

- (void)xj_controlsSetProgress:(CGFloat)progress
{
    progress = (progress < 0) ? 0 : progress;
    self.btn_replay.hidden = YES;
    self.btn_play.enabled = YES;

    self.lastDragProgress = progress;
    self.slider.progress = progress;
}

- (void)xj_controlsDraggedTime:(NSInteger)draggedTime
                   sliderValue:(CGFloat)value
{
    NSString *curTimeStr = [XJPlayerControlsView formatTime:draggedTime];
    self.sliderTimeLabel.text = curTimeStr;

    CGFloat vw = self.slider.bounds.size.width;
    CGFloat slidePosX = vw * value;
    CGRect frame = self.sliderTimeLabel.frame;
    CGFloat labelW = frame.size.width;
    CGFloat posX =  slidePosX - (labelW * .5);
    CGFloat padding = 20.0f;
    CGFloat maxPosX = (vw - labelW - padding);
    if (posX < padding) posX = padding;
    else if (posX > maxPosX) posX = (vw - labelW - padding);
    frame.origin.x = posX;
    self.sliderTimeLabel.frame = frame;
}

- (void)xj_controlsDraggedTime:(NSInteger)draggedTime
                     totalTime:(NSInteger)totalTime
{
    NSString *dragTimeStr = [XJPlayerControlsView formatTime:draggedTime];
    self.sliderTimeLabel.text = dragTimeStr;
}

- (void)xj_controlsSetMarkPositions:(NSArray *)positions {
    [self.slider addMarkSliderWithPositions:positions];
}

+ (NSString *)formatTime:(NSTimeInterval)time
{
    time = isnan(time) ? 0 : time;
    NSInteger hr  = floor(time / 60.0f / 60.0f);
    NSInteger min = (NSInteger)(time / 60.0f) % 60;
    NSInteger sec = (NSInteger)time % 60;

    NSString *timeStr;
    if (hr > 0) {
        timeStr = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", hr, min, sec];
    } else {
        timeStr = [NSString stringWithFormat:@"%02zd:%02zd", min, sec];
    }
    return timeStr;
}

#pragma mark - action

- (void)action_play:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionPlay:)]) {
        [self.delegate xj_controlsView:self actionPlay:sender];
    }
}

- (void)action_next:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionNext:)]) {
        [self.delegate xj_controlsView:self actionNext:sender];
    }
}

- (void)action_error:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionError:)]) {
        [self.delegate xj_controlsView:self actionError:sender];
    }
}

- (void)action_replay:(UIButton *)sender
{
    self.btn_replay.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionReplay:)]) {
        [self.delegate xj_controlsView:self actionReplay:sender];
    }
}

- (void)action_fullScreen:(UIButton *)sender
{
    self.slider.mpVolumeView.hidden = YES;
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionFullScreen:)]) {
        [self.delegate xj_controlsView:self actionFullScreen:sender];
    }
}

- (void)action_showChatMessage:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:canShowMessage:)]) {
        BOOL isFullScreen = [self.delegate xj_controlsView:self canShowMessage:sender];
        if (isFullScreen && self.messageView) {
            sender.selected = !sender.isSelected;
            [self xj_controlsShowChatMessageView:sender.isSelected];
        }
    }
}

- (void)action_watchLater:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionWatchLater:)]) {
        [self.delegate xj_controlsView:self actionWatchLater:sender];
    }
}

- (void)action_share:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionShare:)]) {
        [self.delegate xj_controlsView:self actionShare:sender];
    }
}

- (void)action_cast:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionCast:)]) {
        [self.delegate xj_controlsView:self actionCast:sender];
    }
}

- (void)action_360:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:action360:)]) {
        [self.delegate xj_controlsView:self action360:sender];
    }
}

- (void)action_dismiss:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionDismiss:)]) {
        [self.delegate xj_controlsView:self actionDismiss:sender];
    }
}

- (void)action_back:(UIButton *)sender
{
    [self action_fullScreen:self.btn_fullScreen];
}

- (void)action_resolution:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionResolution:)]) {
        [self.delegate xj_controlsView:self actionResolution:sender];
    }
}

- (void)xj_controlsIsLiveMode:(BOOL)isLive
{
    self.live = isLive;
    self.liveCon.hidden = !isLive;
    if (self.isLive)
    {
        [self refreshLiveConLayout];
        self.liveLabel.alpha = 1.0f;
        [UIView animateWithDuration:1 delay:0
                            options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                         animations:^{
                             self.liveLabel.alpha = .4f;
                         } completion:nil];
    }
}

- (void)xj_controlsUpdateOnlineCount:(NSInteger)count
{
    NSString *onlineCount = [@(count) descriptionWithLocale:[NSLocale currentLocale]];
    self.onlineLabel.text = onlineCount;
}

/**
    太早refreshLiveConLayout會導致layout error
 */
- (void)refreshLiveConLayout
{
    if (!self.isLive) return;
    BOOL isFullScreen = self.btn_fullScreen.selected;
    [self.liveCon mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.isShowing) {
            make.centerX.equalTo(self);
        } else {
            make.left.equalTo(self).mas_offset(isFullScreen ? 20 : 10);
        }
        make.top.mas_equalTo(isFullScreen ? 21 : 10);
        make.height.mas_equalTo(30);
    }];

    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:1.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self layoutIfNeeded];
                     } completion:nil];
}

#pragma mark - ResolutionView delegate

- (void)resolutionViewWithView:(ResolutionView *)view selectStreamInfo:(StreamInfoModel *)streamInfo
{
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:changeResolutionWithStreamInfo:)]) {
        [self.delegate xj_controlsView:self changeResolutionWithStreamInfo:streamInfo];
    }
}

#pragma mark - create controls view

- (UIImageView *)placeholderView
{
    if (!_placeholderView) {
        _placeholderView = [[UIImageView alloc] init];
    }
    return _placeholderView;
}

- (GradientView *)maskView
{
    if (!_maskView)
    {
        _maskView = [[GradientView alloc] init];
        _maskView.alpha = 0.0f;
    }
    return _maskView;
}

- (UIView *)controlsView
{
    if (!_controlsView)
    {
        _controlsView = [[UIView alloc] init];
        _controlsView.alpha = 0.0f;
    }
    return _controlsView;
}

- (XJSlider *)slider
{
    if (!_slider) {
        _slider = [[XJSlider alloc] init];
    }
    return _slider;
}

- (UIButton *)btn_replay
{
    if (!_btn_replay)
    {
        _btn_replay = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *replay = [UIImage imageNamed:@"ic_replay"];
        [_btn_replay setImage:replay forState:UIControlStateNormal];
        [_btn_replay addTarget:self action:@selector(action_replay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_replay;
}

- (UIButton *)btn_360
{
    if (!_btn_360)
    {
        _btn_360 = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"ic_360"];
        [_btn_360 setImage:image forState:UIControlStateNormal];
        [_btn_360 addTarget:self action:@selector(action_360:) forControlEvents:UIControlEventTouchUpInside];
        _btn_360.hidden = YES;
    }
    return _btn_360;
}

- (ResolutionView *)resolutionView
{
    if (!_resolutionView) {
        _resolutionView = [[ResolutionView alloc] init];
        _resolutionView.delegate = self;
    }
    return _resolutionView;
}

- (UIView *)topControlsView
{
    if (!_topControlsView) {
        _topControlsView = [[UIView alloc] init];
        _topControlsView.userInteractionEnabled = YES;
    }
    return _topControlsView;
}

- (UIView *)topLeftControlsView
{
    if (!_topLeftControlsView) {
        _topLeftControlsView = [[UIView alloc] init];
    }
    return _topLeftControlsView;
}

- (UIView *)bottomControlsView
{
    if (!_bottomControlsView) {
        _bottomControlsView = [[UIView alloc] init];
    }
    return _bottomControlsView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        //_titleLabel.adjustsFontSizeToFitWidth = YES;
        //_titleLabel.minimumScaleFactor = 0.6;
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UIButton *)btn_fullScreen
{
    if (!_btn_fullScreen)
    {
        _btn_fullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn_fullScreen.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_btn_fullScreen setImage:[UIImage imageNamed:@"ic_fullscr"] forState:UIControlStateNormal];
        [_btn_fullScreen setImage:[UIImage imageNamed:@"ic_miniscr"] forState:UIControlStateSelected];
        [_btn_fullScreen addTarget:self action:@selector(action_fullScreen:) forControlEvents:UIControlEventTouchUpInside];
        //_btn_fullScreen.contentMode = UIViewContentModeScaleAspectFit;
        //_btn_fullScreen.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        //_btn_fullScreen.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;

    }
    return _btn_fullScreen;
}

- (UIButton *)btn_chatMessage
{
    if (!_btn_chatMessage)
    {
        _btn_chatMessage = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn_chatMessage.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _btn_chatMessage.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [_btn_chatMessage setImage:[UIImage imageNamed:@"ic_bubble_off"] forState:UIControlStateNormal];
        [_btn_chatMessage setImage:[UIImage imageNamed:@"ic_bubble_on"] forState:UIControlStateSelected];
        [_btn_chatMessage addTarget:self action:@selector(action_showChatMessage:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btn_chatMessage;
}

- (UIButton *)btn_watchLater
{
    if (!_btn_watchLater)
    {
        _btn_watchLater = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn_watchLater setImage:[UIImage imageNamed:@"ic_unWatchLater"] forState:UIControlStateNormal];
        [_btn_watchLater setImage:[UIImage imageNamed:@"ic_watchLater"] forState:UIControlStateSelected];
        [_btn_watchLater addTarget:self action:@selector(action_watchLater:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_watchLater;
}

- (UIButton *)btn_share
{
    if (!_btn_share)
    {
        _btn_share = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn_share setImage:[UIImage imageNamed:@"ic_share"] forState:UIControlStateNormal];
        [_btn_share addTarget:self action:@selector(action_share:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_share;
}

- (CastIconButton *)btn_cast
{
    if (!_btn_cast)
    {
        _btn_cast = [[CastIconButton alloc] init];
        [_btn_cast addTarget:self action:@selector(action_cast:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_cast;
}

- (UIButton *)btn_back
{
    if (!_btn_back)
    {
        _btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn_back setImage:[UIImage imageNamed:@"ic_player_back"] forState:UIControlStateNormal];
        [_btn_back addTarget:self action:@selector(action_back:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_back;
}

- (UIButton *)btn_play
{
    if (!_btn_play)
    {
        _btn_play = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn_play setImage:[UIImage imageNamed:@"ic_play"] forState:UIControlStateNormal];
        [_btn_play setImage:[UIImage imageNamed:@"ic_pause"] forState:UIControlStateSelected];
        [_btn_play addTarget:self action:@selector(action_play:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_play;
}

- (UIButton *)btn_next
{
    if (!_btn_next)
    {
        _btn_next = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn_next setImage:[UIImage imageNamed:@"ic_player_next"] forState:UIControlStateNormal];
        [_btn_next addTarget:self action:@selector(action_next:) forControlEvents:UIControlEventTouchUpInside];
        _btn_next.enabled = NO;
    }
    return _btn_next;
}

- (UIButton *)btn_error
{
    if (!_btn_error)
    {
        _btn_error = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn_error.backgroundColor = [UIColor blackColor];
        [_btn_error setImage:[UIImage imageNamed:@"ic_network_error"] forState:UIControlStateNormal];
        [_btn_error setTitle:LInfo_NetworkError forState:UIControlStateNormal];
        [_btn_error addTarget:self action:@selector(action_error:) forControlEvents:UIControlEventTouchUpInside];
        _btn_error.titleLabel.textColor = [UIColor whiteColor];
        _btn_error.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        _btn_error.alpha = 0.0f;
    }
    return _btn_error;
}

- (UIButton *)btn_resolution
{
    if (!_btn_resolution)
    {
        _btn_resolution = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn_resolution.titleLabel.font = [UIFont fontWithName:@"KohinoorTelugu-Medium" size:15];
        [_btn_resolution setTitle:@"360P" forState:UIControlStateNormal];
        [_btn_resolution setTitleColor:VIDOL_COLOR forState:UIControlStateHighlighted];
        [_btn_resolution addTarget:self action:@selector(action_resolution:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_resolution;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel)
    {
        _timeLabel               = [[UILabel alloc] init];
        _timeLabel.textColor     = [UIColor whiteColor];
        _timeLabel.font          = [UIFont fontWithName:@"KohinoorTelugu-Medium" size:15];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.alpha         = 0.0f;
    }
    return _timeLabel;
}

- (UILabel *)sliderTimeLabel
{
    if (!_sliderTimeLabel)
    {
        _sliderTimeLabel               = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 65, 30)];
        _sliderTimeLabel.textColor     = [UIColor blackColor];
        _sliderTimeLabel.font          = [UIFont fontWithName:@"KohinoorTelugu-Regular" size:15];
        _sliderTimeLabel.textAlignment = NSTextAlignmentCenter;
        _sliderTimeLabel.layer.cornerRadius = 3.0f;
        _sliderTimeLabel.layer.masksToBounds = YES;
        _sliderTimeLabel.backgroundColor = [UIColor colorWithRed:0.9990 green:0.9321 blue:0.0398 alpha:1.0000];
        _sliderTimeLabel.alpha         = 0.0f;
    }
    return _sliderTimeLabel;
}

- (UIImageView *)logoView
{
    if (!_logoView)
    {
        _logoView                        = [[UIImageView alloc] init];
        _logoView.image                  = [[UIImage imageNamed:@"ic_player_logo"] imageByApplyingAlpha:.5];
        _logoView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _logoView;
}

- (YYLabel *)previewLabel
{
    if (!_previewLabel)
    {
        _previewLabel               = [[YYLabel alloc] init];
        _previewLabel.textColor     = [UIColor whiteColor];
        _previewLabel.font          = [UIFont fontWithName:@"HelveticaNeue" size:14];
        _previewLabel.textAlignment = NSTextAlignmentLeft;
        _previewLabel.alpha         = 0.0f;
        _previewLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    }
    return _previewLabel;
}

- (UIView *)liveCon
{
    if (!_liveCon)
    {
        _liveCon = [[UIView alloc] init];
        _liveCon.layer.cornerRadius = 4.0f;
        _liveCon.layer.masksToBounds = YES;
        _liveCon.backgroundColor = [UIColor clearColor];

        UILabel *liveLabel = [[UILabel alloc] init];
        liveLabel.font = fontHelveticaNeueMedium(12);
        liveLabel.textAlignment = NSTextAlignmentCenter;
        liveLabel.textColor = [UIColor whiteColor];
        liveLabel.backgroundColor = RED_COLOR;
        liveLabel.layer.cornerRadius = 3.0f;
        liveLabel.layer.masksToBounds = YES;
        [_liveCon addSubview:liveLabel];
        _liveLabel = liveLabel;
        liveLabel.text = LPlayer_ControlsView_Live;

        UIView *containerView = [[UIView alloc]init];
        containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
        containerView.layer.cornerRadius = 4.0f;
        containerView.layer.masksToBounds = YES;
        [_liveCon addSubview:containerView];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_people"]];
        [containerView addSubview:imgView];

        UILabel *label = [[UILabel alloc] init];
        label.font = fontHelveticaNeueRegular(13);
        label.textColor = [UIColor whiteColor];
        [containerView addSubview:label];
        _onlineLabel = label;
        label.text = @"--";

        [liveLabel mas_makeConstraints:^(MASConstraintMaker *make) {

            make.left.top.equalTo(_liveCon).mas_offset(4);
            make.bottom.equalTo(_liveCon).mas_offset(-4);
            make.width.mas_equalTo(40);

        }];

        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(_liveCon).mas_offset(4);
            make.right.equalTo(_liveCon).mas_offset(0);
            make.bottom.equalTo(_liveCon).mas_offset(-4);
            make.left.equalTo(liveLabel.mas_right).mas_offset(5);
            
        }];
        
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(containerView).mas_offset(5);
            make.size.mas_equalTo(CGSizeMake(11, 15));
            make.centerY.equalTo(containerView).mas_offset(1);

        }];

        [label mas_makeConstraints:^(MASConstraintMaker *make) {

            make.top.equalTo(containerView).mas_offset(3);
            make.right.equalTo(containerView).mas_offset(-8);
            make.bottom.equalTo(containerView).mas_offset(-3);
            make.left.equalTo(imgView.mas_right).mas_offset(3);

        }];
    }
    return _liveCon;
}

#pragma mark Notification

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification*)notification
{
    [self xj_controlsIsLiveMode:self.isLive];
}

@end
