//
//  XJSliderTrackView.m
//  Vidol
//
//  Created by XJIMI on 2018/5/9.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import "XJSliderTrackView.h"

@interface XJSliderTrackView ()

@property (nonatomic, strong) UIView *bgProgressView;

@property (nonatomic, strong) UIView *trackView;

@property (nonatomic, strong) UIView *progressView;

@property (nonatomic, strong) UIView *sliderIndicator;

@end

@implementation XJSliderTrackView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configureView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

- (void)configureView
{
    self.clipsToBounds = YES;

    [self addSubview:self.bgProgressView];
    [self addSubview:self.trackView];
    [self.trackView addSubview:self.progressView];

    _trackDir = XJSliderTrackDirBottom;
    _trackSpacing = 5.0f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.trackSpacing = _trackSpacing;
    self.progress = _progress;
}

- (void)setTrackSpacing:(CGFloat)trackSpacing
{
    _trackSpacing = trackSpacing;
    CGRect trackFrame = CGRectZero;
    CGRect bgProgressFrame = CGRectZero;
    CGRect progressFrame = self.trackView.bounds;

    CGFloat vw = self.bounds.size.width;
    CGFloat vh = self.bounds.size.height;
    switch (self.trackDir)
    {
        case XJSliderTrackDirBottom:
        {
            CGFloat progressW = vw * self.progress;
            trackFrame = CGRectMake(0, vh-trackSpacing, vw, trackSpacing);
            bgProgressFrame = CGRectMake(0, 0, progressW, vh - trackSpacing);
            progressFrame.size.width = progressW;
            break;
        }
        case XJSliderTrackDirLeft:
        {
            trackFrame = CGRectMake(0, 0, trackSpacing, vh);
            CGFloat progressH = vh * self.progress;
            bgProgressFrame = CGRectMake(trackSpacing, vh-progressH, vw-trackSpacing, progressH);
            progressFrame.origin.y = bgProgressFrame.origin.y;
            progressFrame.size.height = progressH;
            break;
        }
        case XJSliderTrackDirRight:
        {

            trackFrame = CGRectMake(vw-trackSpacing, 0, trackSpacing, vh);
            CGFloat progressH = vh * self.progress;
            bgProgressFrame = CGRectMake(0, vh-progressH, vw-trackSpacing, progressH);
            progressFrame.origin.y = bgProgressFrame.origin.y;
            progressFrame.size.height = progressH;
            break;
        }
        case XJSliderTrackDirTop:
        {
            CGFloat progressW = vw * self.progress;
            trackFrame = CGRectMake(0, 0, vw, trackSpacing);
            bgProgressFrame = CGRectMake(0, trackSpacing, progressW, vh-trackSpacing);
            progressFrame.size.width = progressW;
            break;
        }
    }
    
    self.trackView.frame = trackFrame;
    self.progressView.frame = progressFrame;
    self.bgProgressView.frame = bgProgressFrame;
}

- (void)setProgress:(CGFloat)progress
{
    progress = (isnan(progress) || isinf(progress)) ? 0 : progress;

    if (progress < 0) progress = 0;
    else if (progress > 1) progress = 1;

    _progress = progress;

    CGFloat vw = self.bounds.size.width;
    CGFloat vh = self.bounds.size.height;

    switch (self.trackDir)
    {
        case XJSliderTrackDirBottom:
        {
            CGFloat progressW = vw * progress;
            [self view:self.progressView width:progressW];
            [self view:self.bgProgressView width:progressW];
            break;
        }
        case XJSliderTrackDirLeft:
        {
            CGFloat progressH = vh * progress;
            [self view:self.progressView height:progressH];
            [self view:self.bgProgressView height:progressH];
            break;
        }
        case XJSliderTrackDirRight:
        {
            CGFloat progressH = vh * progress;
            [self view:self.progressView height:progressH];
            [self view:self.bgProgressView height:progressH];
            break;
        }
        case XJSliderTrackDirTop:
        {
            CGFloat progressW = vw * progress;
            [self view:self.progressView width:progressW];
            [self view:self.bgProgressView width:progressW];
            break;
        }
    }
}

- (void)setTrackColor:(UIColor *)trackColor {
    self.trackView.backgroundColor = trackColor;
}

- (void)setProgressColor:(UIColor *)progressColor {
    self.progressView.backgroundColor = progressColor;
}

- (void)setBgProgressColor:(UIColor *)bgProgressColor {
    self.bgProgressView.backgroundColor = bgProgressColor;
}


#pragma mark - public method

- (void)showTrackView
{
    [UIView animateWithDuration:.15 animations:^{
        self.trackView.alpha = 1.0f;
    }];
}
- (void)hideTrackView
{
    [UIView animateWithDuration:.15 animations:^{
        self.trackView.alpha = 0.0f;
    }];
}

- (void)showBgProgressView
{
    [UIView animateWithDuration:.15 animations:^{
        self.bgProgressView.alpha = 1.0f;
    }];
}

- (void)hideBgProgressView
{
    [UIView animateWithDuration:.15 animations:^{
        self.bgProgressView.alpha = 0.0f;
    }];
}

- (void)show
{
    [UIView animateWithDuration:.15 animations:^{
        self.trackView.alpha = 1.0f;
        self.bgProgressView.alpha = 1.0f;
    }];
}

- (void)hide
{
    [UIView animateWithDuration:.15 animations:^{
        self.trackView.alpha = 0.0f;
        self.bgProgressView.alpha = 0.0f;
    }];
}

- (void)view:(UIView *)view width:(CGFloat)width
{
    CGRect frame = view.frame;
    frame.size.width = width;
    view.frame = frame;
}

- (void)view:(UIView *)view height:(CGFloat)height
{
    CGRect frame = view.frame;
    CGFloat vh = self.bounds.size.height;
    frame.origin.y = vh - height;
    frame.size.height = height;
    view.frame = frame;
}

- (UIView *)bgProgressView
{
    if (!_bgProgressView)
    {
        _bgProgressView = [[UIView alloc] init];
        _bgProgressView.backgroundColor = [UIColor colorWithWhite:0 alpha:.2];
        _bgProgressView.alpha = 0.0f;
    }
    return _bgProgressView;
}

- (UIView *)trackView
{
    if (!_trackView)
    {
        _trackView = [[UIView alloc] init];
        _trackView.backgroundColor = [UIColor colorWithWhite:1 alpha:.3];
        _trackView.alpha = 0.0f;
    }
    return _trackView;
}

- (UIView *)progressView
{
    if (!_progressView)
    {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = [UIColor colorWithWhite:1 alpha:.8];
    }
    return _progressView;
}

- (UIView *)sliderIndicator
{
    if (!_sliderIndicator)
    {
        _sliderIndicator               = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 65, 25)];
        _sliderIndicator.layer.cornerRadius = 3.0f;
        _sliderIndicator.layer.masksToBounds = YES;
        _sliderIndicator.alpha         = 0.0f;
    }
    return _sliderIndicator;
}

@end
