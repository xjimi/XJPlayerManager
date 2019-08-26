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
#import <XJUtil/XJGradientView.h>
#import <XJUtil/UIImage+XJAdditions.h>
#import <Masonry/Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import "UIButton+CenterSpace.h"
#import "UIImageView+XJPlayerImageManager.h"
#import "XJPlayerUtils.h"
#import "XJPlayerBundleResource.h"
#import "PlayerErrorInfoView.h"

@interface XJPlayerControlsView ()

@property (nonatomic, strong) UIImageView             *placeholderView;

@property (nonatomic, strong) UIView                  *controlsView;

@property (nonatomic, strong) XJGradientView          *maskView;

@property (nonatomic, strong) UIView                  *topControlsView;

@property (nonatomic, strong) UIView                  *topLeftControlsView;

@property (nonatomic, strong) UIView                  *bottomControlsView;

@property (nonatomic, strong) UILabel                 *titleLabel;

@property (nonatomic, strong) UIButton                *btn_fullScreen;

@property (nonatomic, strong) UIButton                *btn_play;

@property (nonatomic, strong) UIButton                *btn_prev;

@property (nonatomic, strong) UIButton                *btn_next;

@property (nonatomic, strong) UIButton                *btn_replay;

@property (nonatomic, strong) UIButton                *btn_mute;

@property (nonatomic, strong) PlayerErrorInfoView     *errorView;


@property (nonatomic, strong) XJSlider                *slider;

@property (nonatomic, strong) UILabel                 *timeLabel;

@property (nonatomic, strong) UILabel                 *sliderTimeLabel;


@property (nonatomic, assign, getter=isShowing) BOOL  showing;

@property (nonatomic, assign, getter=isDragged) BOOL  dragged;

@property (nonatomic, assign, getter=isPlayEnd) BOOL  playeEnd;

@property (nonatomic, assign, getter=isBuffering) BOOL buffering;

@property (nonatomic, assign, getter=isFullScreen)BOOL fullScreen;

@property (nonatomic, assign, getter=isFullScreenEnabled) BOOL fullScreenEnabled;

@property (nonatomic, assign) CGFloat startDragProgress;

@property (nonatomic, assign) CGFloat lastDragProgress;

@property (nonatomic, assign, getter=isHiddenControlsView) BOOL hiddenControlsView;

@property (nonatomic, assign) BOOL isMakeConstraints;


@end

@implementation XJPlayerControlsView

- (void)dealloc
{
    //self.delegate = nil;
    NSLog(@"%s", __func__);
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self createView];
        [self xj_controlsLayoutPortrait];
        [self xj_controlsReset];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self makeConstraints];
}

- (void)xj_controlsReset
{
    self.userInteractionEnabled = NO;
    
    self.btn_replay.hidden = YES;

    self.slider.mpVolumeView.hidden = YES;
    self.startDragProgress = 0.0f;
    self.lastDragProgress = 0.0f;
    [self xj_controlsCurrentTime:0 totalTime:0 sliderValue:0];

    self.showing = NO;
    self.dragged = NO;
    self.playeEnd = NO;

    [self hideError];
    [self xj_controlsHideControlsView];
    [self.slider showBuffering];
}

- (void)xj_controlsSliderPorgressEnabled:(BOOL)enabled {
    self.slider.progressEnabled = enabled;
}

- (void)xj_controlsSliderHorizontalGestureEnabled:(BOOL)enabled {
    self.slider.enabledHorizontalGesture = enabled;
}

- (void)xj_controlsSliderVerticalGestureEnabled:(BOOL)enabled {
    self.slider.enabledVerticalGesture = enabled;
}

- (void)addSliderGesture
{
    [self.slider addProgressSlider];
    [self.slider addLastDragProgressSlider];

    //[self.slider addVolumeSlider];
    //[self.slider addBrightnessSlider];

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

        /*if (sliderType == XJSliderTypeVolume || sliderType == XJSliderTypeBrightness) {
         return;
         }*/
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
        } completion:nil];

        if ([weakSelf.delegate respondsToSelector:@selector(xj_controlsView:sliderTouchCancelled:)]) {
            [weakSelf.delegate xj_controlsView:weakSelf sliderTouchCancelled:weakSelf.slider.progress];
        }

    }];
}

- (void)xj_controlsReadyToPlay
{
    [self hideError];
    self.slider.mpVolumeView.hidden = NO;
    self.btn_play.enabled = YES;
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
    [UIView animateWithDuration:.15 animations:^{
        [self layoutIfNeeded];
        [self showControls];
    } completion:^(BOOL finished) {
        [self autoFadeOutControlsView];
    }];
}

- (void)xj_controlsHideControlsView
{
    if (!self.isDragged) self.showing = NO;
    [self xj_controlsCancelAutoFadeOutControlsView];
    [UIView animateWithDuration:.3 animations:^{
        [self hideControls];
    } completion:^(BOOL finished) {
    }];
}

- (void)xj_controlsEnabled:(BOOL)enabled
{
    self.userInteractionEnabled = enabled;
    self.slider.enabled = enabled;
}

- (void)xj_controlsHidden:(BOOL)hidden
{
    //這裡hidden將完全不顯示controlsView
    self.hiddenControlsView = hidden;
    self.userInteractionEnabled = !hidden;
    self.slider.hidden = hidden;
    self.slider.enabled = !hidden;
    self.maskView.hidden = hidden;
}

- (void)xj_controlsBtnPrevEnabled:(BOOL)enabled {
    self.btn_prev.enabled = enabled;
}

- (void)xj_controlsBtnNextEnabled:(BOOL)enabled {
    self.btn_next.enabled = enabled;
}

- (void)xj_controlsBtnFullScreenHidden:(BOOL)hidden {
    self.btn_fullScreen.hidden = hidden;
}

- (BOOL)xj_controlsIsShowing {
    return self.isShowing;
}

- (void)xj_controlsSetTitle:(NSString *)title {
    self.titleLabel.text = title ? : @"";
}

- (void)xj_controlsShowCoverImageWithUrl:(NSString *)url
{
    if (!url)
    {
        self.placeholderView.image = nil;
        return;
    }

    __weak typeof(self)weakSelf = self;
    [self xj_controlsHideCoverImageWithCompletion:^{

        if (url.length)
        {
            weakSelf.placeholderView.alpha = 0.0f;
            [weakSelf.placeholderView xj_imageWithURL:[NSURL URLWithString:url]
                                      placeholderType:XJImagePlaceholderTypeNone
                                     downloadAnimated:NO
                                         cornerRadius:0
                                           completion:^(UIImage *image)
             {
                 [UIView animateWithDuration:.3 animations:^{
                     weakSelf.placeholderView.alpha = 1.0f;
                 }];
             }];
        }

    }];
}

- (void)xj_controlsHideCoverImageWithCompletion:(void (^)(void))completion
{
    if (!self.placeholderView.image)
    {
        if (completion) completion();
        return;
    }

    [UIView animateWithDuration:.3 animations:^{
        self.placeholderView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.placeholderView.image = nil;
        if (completion) completion();
    }];
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
    if (!self.isDragged) {
        self.timeLabel.alpha = 0.0f;
    }
}

- (void)xj_controlsLayoutPortrait
{
    self.titleLabel.hidden = YES;
    self.btn_fullScreen.selected = NO;
    
    if (XJP_ISNEATBANG &&  self.bounds.size.width)
    {
        [self.slider mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [self layoutIfNeeded];
    }
}

- (void)xj_controlsLayoutFullScreen
{
    self.titleLabel.hidden = NO;
    self.btn_fullScreen.selected = YES;
    //self.slider.fullScreenMode = YES;
    if (XJP_ISNEATBANG && self.bounds.size.width)
    {
        CGFloat height = XJP_PortraitW;
        CGFloat mw = roundf(height * (16.0 / 9.0));
        [self.slider mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.centerX.equalTo(self);
            make.width.mas_equalTo(mw);
        }];
        [self layoutIfNeeded];
    }
}

- (void)hideError
{
    if (self.errorView.alpha == 0) return;
    [UIView animateWithDuration:.3 animations:^{
        self.errorView.alpha = 0.0f;
    }];
}

- (void)xj_controlsPlayFailed
{
    //有可能錯誤發生在ReadyToPlay前
    self.userInteractionEnabled = YES;
    [UIView animateWithDuration:.3 animations:^{
        self.errorView.alpha = 1.0f;
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

- (void)action_prev:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionPrev:)]) {
        [self.delegate xj_controlsView:self actionPrev:sender];
    }
}

- (void)action_mute:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionMute:)]) {
        [self.delegate xj_controlsView:self actionMute:sender];
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
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionFullScreen:)]) {
        [self.delegate xj_controlsView:self actionFullScreen:sender];
    }
}

- (void)action_share:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionShare:)]) {
        [self.delegate xj_controlsView:self actionShare:sender];
    }
}

- (void)action_back:(UIButton *)sender
{
    [self action_fullScreen:self.btn_fullScreen];
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

#pragma mark - create controls view

- (UIImageView *)placeholderView
{
    if (!_placeholderView) {
        _placeholderView = [[UIImageView alloc] init];
        _placeholderView.contentMode = UIViewContentModeScaleAspectFill;
        _placeholderView.clipsToBounds = YES;
    }
    return _placeholderView;
}

- (XJGradientView *)maskView
{
    if (!_maskView)
    {
        _maskView = [[XJGradientView alloc] init];
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
        UIImage *replay = [XJPlayerBundleResource imageNamed:@"ic_replay"];
        [_btn_replay setImage:replay forState:UIControlStateNormal];
        [_btn_replay addTarget:self action:@selector(action_replay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_replay;
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
        _titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
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
        [_btn_fullScreen setImage:[XJPlayerBundleResource imageNamed:@"ic_fullscr"] forState:UIControlStateNormal];
        [_btn_fullScreen setImage:[XJPlayerBundleResource imageNamed:@"ic_miniscr"] forState:UIControlStateSelected];
        [_btn_fullScreen addTarget:self action:@selector(action_fullScreen:) forControlEvents:UIControlEventTouchUpInside];
        //_btn_fullScreen.contentMode = UIViewContentModeScaleAspectFit;
        //_btn_fullScreen.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        //_btn_fullScreen.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;

    }
    return _btn_fullScreen;
}

- (UIButton *)btn_play
{
    if (!_btn_play)
    {
        _btn_play = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn_play setImage:[XJPlayerBundleResource imageNamed:@"ic_play"] forState:UIControlStateNormal];
        [_btn_play setImage:[XJPlayerBundleResource imageNamed:@"ic_pause"] forState:UIControlStateSelected];
        [_btn_play addTarget:self action:@selector(action_play:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn_play;
}

- (UIButton *)btn_next
{
    if (!_btn_next)
    {
        _btn_next = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn_next setImage:[XJPlayerBundleResource imageNamed:@"ic_player_next"] forState:UIControlStateNormal];
        [_btn_next addTarget:self action:@selector(action_next:) forControlEvents:UIControlEventTouchUpInside];
        _btn_next.enabled = NO;
    }
    return _btn_next;
}

- (UIButton *)btn_prev
{
    if (!_btn_prev)
    {
        _btn_prev = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn_prev setImage:[XJPlayerBundleResource imageNamed:@"ic_player_prev"] forState:UIControlStateNormal];
        [_btn_prev addTarget:self action:@selector(action_prev:) forControlEvents:UIControlEventTouchUpInside];
        _btn_prev.enabled = NO;
    }
    return _btn_prev;
}

- (UIButton *)btn_mute
{
    if (!_btn_mute)
    {
        _btn_mute = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn_mute setImage:[XJPlayerBundleResource imageNamed:@"ic_player_unMute"] forState:UIControlStateNormal];
        [_btn_mute setImage:[XJPlayerBundleResource imageNamed:@"ic_player_mute"] forState:UIControlStateSelected];
        [_btn_mute addTarget:self action:@selector(action_mute:) forControlEvents:UIControlEventTouchUpInside];
        _btn_mute.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _btn_mute;
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
        _sliderTimeLabel.textColor     = [UIColor whiteColor];
        _sliderTimeLabel.font          = [UIFont fontWithName:@"KohinoorTelugu-Regular" size:15];
        _sliderTimeLabel.textAlignment = NSTextAlignmentCenter;
        _sliderTimeLabel.layer.cornerRadius = 3.0f;
        _sliderTimeLabel.layer.masksToBounds = YES;
        _sliderTimeLabel.backgroundColor = [UIColor colorWithRed:0.3626 green:0.5479 blue:0.9986 alpha:1.0000];
        _sliderTimeLabel.alpha         = 0.0f;
    }
    return _sliderTimeLabel;
}

- (void)createView
{
    [self addSubview:self.placeholderView];
    [self addSubview:self.maskView];
    [self addSubview:self.slider];

    __weak typeof(self)weakSelf = self;
    self.errorView = [PlayerErrorInfoView createInView:self didTapViewBlock:^{
        
        if ([self.delegate respondsToSelector:@selector(xj_controlsView:actionReload:)]) {
            [self.delegate xj_controlsView:weakSelf actionReload:weakSelf.errorView];
        }
    }];

    [self addSliderGesture];
    [self.slider addSubview:self.controlsView];
    [self.slider addSubview:self.timeLabel];
    [self.slider addSubview:self.sliderTimeLabel];

    [self.controlsView addSubview:self.topControlsView];

    [self.controlsView addSubview:self.topLeftControlsView];
    [self.topLeftControlsView addSubview:self.titleLabel];

    [self.controlsView addSubview:self.bottomControlsView];
    [self.bottomControlsView addSubview:self.btn_fullScreen];
    [self.bottomControlsView addSubview:self.btn_play];
    [self.bottomControlsView addSubview:self.btn_prev];
    [self.bottomControlsView addSubview:self.btn_next];
    [self.bottomControlsView addSubview:self.btn_mute];
    [self.bottomControlsView addSubview:self.slider.mpVolumeView];

    [self.controlsView addSubview:self.btn_replay];
}

- (void)makeConstraints
{
    if (self.isMakeConstraints) return;
    self.isMakeConstraints = YES;

    [self.placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];

    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];

    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {

        if (XJP_ISNEATBANG)
        {
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.centerX.equalTo(self);
            make.width.mas_equalTo(self.bounds.size.width);
        }
        else
        {
            make.edges.equalTo(self);
        }

    }];

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

    CGFloat multiplieH = 30.0 / (XJP_PortraitW * (9.0 / 16.0));
    [self.topControlsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.trailing.mas_equalTo(-10);
        make.height.equalTo(self).multipliedBy(multiplieH);
    }];

    [self.topLeftControlsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.leading.equalTo(self.controlsView.mas_leading).offset(10);
        make.trailing.equalTo(self.controlsView.mas_centerX);
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

    [self.btn_prev mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.btn_play.mas_trailing).offset(5);
        make.centerY.equalTo(self.bottomControlsView.mas_centerY);
        make.width.height.mas_equalTo(self.bottomControlsView.mas_height);
    }];

    [self.btn_next mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.btn_prev.mas_trailing).offset(5);
        make.centerY.equalTo(self.bottomControlsView.mas_centerY);
        make.width.height.mas_equalTo(self.bottomControlsView.mas_height);
    }];

    [self.btn_fullScreen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.bottomControlsView.mas_trailing);
        make.centerY.equalTo(self.bottomControlsView.mas_centerY);
        make.width.height.equalTo(self.bottomControlsView.mas_height);
    }];

    [self.btn_mute mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.btn_fullScreen.mas_leading).offset(-10);
        make.centerY.equalTo(self.bottomControlsView.mas_centerY);
        make.height.mas_equalTo(self.bottomControlsView.mas_height);
        make.width.mas_equalTo(self.bottomControlsView.mas_height);
    }];

    [self.slider.mpVolumeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.btn_mute.mas_leading).offset(-10);
        make.centerY.equalTo(self.bottomControlsView.mas_centerY);
        make.width.height.equalTo(self.bottomControlsView.mas_height);
    }];

    [self.btn_replay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.controlsView);
        make.width.height.equalTo(self.topControlsView.mas_height);
    }];
}

@end
