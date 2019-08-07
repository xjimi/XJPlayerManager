//
//  XJSlider.m
//  ViewPanGesture
//
//  Created by XJIMI on 2018/3/26.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import "XJSlider.h"
#import "XJBufferingView.h"
#import <AVFoundation/AVFoundation.h>
#import "XJSliderTrackView.h"
#import <Masonry/Masonry.h>
#import "XJMarkSlider.h"

typedef NS_ENUM(NSInteger, PanDir){
    PanDirHorizontal,
    PanDirVertical
};

@interface XJSlider () < UIGestureRecognizerDelegate >

@property (nonatomic, assign) XJSliderType sliderType;

@property (nonatomic, strong) XJSliderTrackView *progressSlider;
@property (nonatomic, strong) XJSliderTrackView *lastDragProgressSlider;
@property (nonatomic, strong) XJMarkSlider *markSlider;

@property (nonatomic, strong) XJSliderTrackView *brightnessSlider;

@property (nonatomic, strong) XJSliderTrackView *volumeSlider;

@property (nonatomic, strong) UIView *brightnessIndicator;
@property (nonatomic, strong) UILabel *brightnessIndicatorLabel;

@property (nonatomic, strong) UIView *volumeIndicator;
@property (nonatomic, strong) UILabel *volumeIndicatorLabel;

@property (nonatomic, assign) CGFloat startPosX;

@property (nonatomic, assign) CGFloat startPosY;

@property (nonatomic, assign) PanDir panDir;

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;

@property (nonatomic, strong) XJBufferingView *bufferingView;

@property (nonatomic, copy) XJSliderGestureBeganBlock      sliderGestureBeganBlock;
@property (nonatomic, copy) XJSliderGestureChangedBlock    sliderGestureChangedBlock;
@property (nonatomic, copy) XJSliderGestureEndedBlock      sliderGestureEndedBlock;
@property (nonatomic, copy) XJSliderGestureCancelledBlock  sliderGestureCancelledBlock;

@property (nonatomic, assign, getter=isVolumeGesture) BOOL volumeGesture;

@property (nonatomic, strong) UISlider *mpVolumeSlider;

@property (nonatomic, assign) CGFloat  progressStartValue;
@property (nonatomic, assign) CGFloat  brightnessStartValue;
@property (nonatomic, assign) CGFloat  volumeStartValue;

@end

@implementation XJSlider

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bufferingView.frame = self.bounds;
}

- (void)configureView
{
    self.clipsToBounds = YES;
    [self addBufferingView];
}

- (void)addBufferingView
{
    self.bufferingView = [[XJBufferingView alloc] initWithFrame:self.bounds];
    [self addSubview:self.bufferingView];
}

- (void)addSliderGestureBeganBlock:(XJSliderGestureBeganBlock)block
{
    self.sliderGestureBeganBlock = block;
    [self addGesture];
}

- (void)addSliderGestureChangedBlock:(XJSliderGestureChangedBlock)block {
    self.sliderGestureChangedBlock = block;
}

- (void)addSliderGestureEndedBlock:(XJSliderGestureEndedBlock)block {
    self.sliderGestureEndedBlock = block;
}

- (void)addSliderGestureCancelledBlock:(XJSliderGestureCancelledBlock)block {
    self.sliderGestureCancelledBlock = block;
}

- (CGFloat)progress {
    return self.progressSlider.progress;
}

- (void)setProgress:(CGFloat)progress {
    self.progressSlider.progress = progress;
}

/**
 *  获取系统音量
 */

- (void)configureVolume
{
    _mpVolumeSlider = nil;
    for (UIView *view in [self.mpVolumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _mpVolumeSlider = (UISlider *)view;
            break;
        }
    }

    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];

    if (!success) { /* handle the error in setCategoryError */ }
}

- (MPVolumeView *)mpVolumeView
{
    if (_mpVolumeView == nil)
    {
        // 如果要显示音量的 view  可在这里设置，默认只调整音量，没有显示View
        _mpVolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _mpVolumeView.hidden = NO;
        _mpVolumeView.showsVolumeSlider = NO;
        _mpVolumeView.showsRouteButton = YES;
    }
    return _mpVolumeView;
}

- (void)addProgressSlider
{
    XJSliderTrackView *slider = [[XJSliderTrackView alloc] init];
    slider.trackSpacing = 5.0f;
    slider.progressColor = [UIColor colorWithRed:0.3626 green:0.5479 blue:0.9986 alpha:1.0000];
    slider.trackDir = XJSliderTrackDirBottom;
    slider.userInteractionEnabled = NO;
    [slider hide];
    [self addSubview:slider];
    _progressSlider = slider;
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)addLastDragProgressSlider
{
    XJSliderTrackView *slider = [[XJSliderTrackView alloc] init];
    slider.trackSpacing = 5.0f;
    slider.progressColor = [UIColor colorWithWhite:0 alpha:.3];
    slider.bgProgressColor = [UIColor clearColor];
    slider.trackColor = [UIColor clearColor];
    slider.trackDir = XJSliderTrackDirBottom;
    slider.userInteractionEnabled = NO;
    [slider hide];
    [self addSubview:slider];
    _lastDragProgressSlider = slider;
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)addMarkSliderWithPositions:(NSArray *)positions
{
    if (!positions.count) return;
    XJMarkSlider *slider = [[XJMarkSlider alloc] init];
    slider.markPositions = positions;
    [self addSubview:slider];
    _markSlider = slider;
    _markSlider.alpha = 0.0f;
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.progressSlider);
        make.height.mas_equalTo(self.progressSlider.trackSpacing);
    }];
}

- (void)addBrightnessSlider
{
    self.brightnessSlider = [[XJSliderTrackView alloc] init];
    self.brightnessSlider.trackSpacing = 5.0f;
    self.brightnessSlider.trackDir = XJSliderTrackDirRight;
    self.brightnessSlider.bgProgressColor = [UIColor colorWithWhite:1 alpha:.2];
    self.brightnessSlider.userInteractionEnabled = NO;
    [self.brightnessSlider hide];
    [self addSubview:self.brightnessSlider];
    [self addSubview:self.brightnessIndicator];
    [self.brightnessSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)addVolumeSlider
{
    [self configureVolume];
    self.volumeSlider = [[XJSliderTrackView alloc] init];
    self.volumeSlider.trackSpacing = 5.0f;
    self.volumeSlider.trackDir = XJSliderTrackDirLeft;
    self.volumeSlider.userInteractionEnabled = NO;
    [self.volumeSlider hide];
    [self addSubview:self.volumeSlider];
    [self addSubview:self.volumeIndicator];
    [self.volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (UIView *)volumeIndicator
{
    if (!_volumeIndicator)
    {
        CGFloat width = 70.0f;
        CGFloat height = 30.0f;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 5.0f;
        view.layer.masksToBounds = YES;
        view.alpha = 0.0f;

        CGFloat padding = 5.0f;
        CGFloat imgh = height - padding * 2;
        UIImage *image = [UIImage imageNamed:@"ic_volume"];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
        imgView.frame = CGRectMake(padding, padding, imgh, imgh);
        [view addSubview:imgView];

        CGRect labelFrame = CGRectMake(imgh+padding, padding, width-height, imgh);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.textColor     = [UIColor darkGrayColor];
        label.font          = [UIFont fontWithName:@"KohinoorTelugu-Regular" size:16];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];

        _volumeIndicator = view;
        _volumeIndicatorLabel = label;
    }
    return _volumeIndicator;
}

- (UIView *)brightnessIndicator
{
    if (!_brightnessIndicator)
    {
        CGFloat width = 70.0f;
        CGFloat height = 30.0f;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 5.0f;
        view.layer.masksToBounds = YES;
        view.alpha = 0.0f;

        CGFloat padding = 5.0f;
        CGFloat imgh = height - padding * 2;
        UIImage *image = [UIImage imageNamed:@"ic_brightness"];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
        imgView.frame = CGRectMake(padding, padding, imgh, imgh);
        [view addSubview:imgView];

        CGRect labelFrame = CGRectMake(imgh+padding, padding, width-height, imgh);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.textColor     = [UIColor darkGrayColor];
        label.font          = [UIFont fontWithName:@"KohinoorTelugu-Regular" size:16];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];

        _brightnessIndicator = view;
        _brightnessIndicatorLabel = label;
    }
    return _brightnessIndicator;
}

- (void)updatePosYWithIndicator:(UIView *)indicator value:(CGFloat)value
{
    CGFloat vw = self.bounds.size.width;
    CGFloat vh = self.bounds.size.height;
    CGFloat verPadding = 15.0f;
    CGFloat padding = 20.0f;

    CGRect iFrame = indicator.frame;
    NSString *percent = [NSString stringWithFormat:@"%d%@",(int)(value*100), @"%"];
    if ([indicator isEqual:self.brightnessIndicator])
    {
        iFrame.origin.x = (vw * .75) - (iFrame.size.width * .5);
        self.brightnessIndicatorLabel.text = percent;
    }
    else
    {
        iFrame.origin.x = (vw * .25) - (iFrame.size.width * .5);
        self.volumeIndicatorLabel.text = percent;
    }

    CGFloat indicatorH = iFrame.size.height;
    CGFloat posY = vh - (vh * value) - (indicatorH * .5);
    CGFloat maxPosY = (vh - indicatorH - verPadding);
    if (posY < padding) posY = verPadding;
    else if (posY > maxPosY) posY = (vh - indicatorH - verPadding);
    iFrame.origin.y = posY;
    indicator.frame = iFrame;
}

- (void)addGesture
{
    if (_panRecognizer) return;
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.delegate = self;
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelaysTouchesBegan:YES];
    [panRecognizer setDelaysTouchesEnded:YES];
    [panRecognizer setCancelsTouchesInView:YES];
    [self addGestureRecognizer:panRecognizer];
    _panRecognizer = panRecognizer;
}

- (void)startSwipeWithGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint veloctyPoint = [recognizer velocityInView:self];

    CGFloat x = fabs(veloctyPoint.x);
    CGFloat y = fabs(veloctyPoint.y);
    CGPoint location = [recognizer locationInView:self];

    if (x > y)
    {
        self.panDir = PanDirHorizontal;
        self.sliderType = XJSliderTypeProgress;

        [self.volumeSlider hide];
        [self.brightnessSlider hide];
        
        if (!self.isProgressEnabled) return;
        self.startPosX = location.x;
        self.progressStartValue = self.progressSlider.progress;
        [self.progressSlider show];
        [self showLastDragProgress:self.progressSlider.progress];
        self.markSlider.alpha = 1.0f;

        if (self.sliderGestureBeganBlock) {
            self.sliderGestureBeganBlock(self.sliderType);
        }
    }
    else if (x < y)
    {
        self.panDir = PanDirVertical;
        if (!self.volumeSlider && !self.brightnessSlider) return;
        [self.progressSlider hide];

        self.volumeGesture = (location.x > self.bounds.size.width * .5);
        self.startPosY = location.y;
        if (self.volumeGesture)
        {
            self.sliderType = XJSliderTypeVolume;
            self.volumeStartValue = self.mpVolumeSlider.value;
            [self.volumeSlider show];
            [self updatePosYWithIndicator:self.volumeIndicator value:self.volumeStartValue];
            [UIView animateWithDuration:.15 animations:^{
                self.volumeIndicator.alpha = 1.0f;
            }];
        }
        else
        {
            self.sliderType = XJSliderTypeBrightness;
            self.brightnessStartValue = [UIScreen mainScreen].brightness;
            [self.brightnessSlider show];
            [self updatePosYWithIndicator:self.brightnessIndicator value:self.brightnessSlider.progress];
            [UIView animateWithDuration:.15 animations:^{
                self.brightnessIndicator.alpha = 1.0f;
            }];
        }

        if (self.sliderGestureBeganBlock) {
            self.sliderGestureBeganBlock(self.sliderType);
        }
    }
}

- (void)swipeWithGesture:(UIPanGestureRecognizer *)recognizer
{
    if (self.panDir == PanDirVertical)
    {
        if (!self.volumeSlider && !self.brightnessSlider) return;

        CGPoint location = [recognizer locationInView:self];
        CGFloat movPosY = 0;
        if (location.y > self.startPosY)
        {
            // top
            movPosY = -(location.y - self.startPosY);

        }
        else if (location.y < self.startPosY)
        {
            // down
            movPosY = (self.startPosY - location.y);
        }

        CGFloat vh = self.bounds.size.height;

        if (self.isVolumeGesture)
        {
            CGFloat progressH = (vh * self.volumeStartValue) + movPosY;
            self.volumeSlider.progress = progressH / vh;
            self.mpVolumeSlider.value = self.volumeSlider.progress;
            [self updatePosYWithIndicator:self.volumeIndicator value:self.volumeSlider.progress];
        }
        else
        {
            CGFloat progressH = (vh * self.brightnessStartValue) + movPosY;
            self.brightnessSlider.progress = progressH / vh;
            [UIScreen mainScreen].brightness = self.brightnessSlider.progress;
            [self updatePosYWithIndicator:self.brightnessIndicator value:self.brightnessSlider.progress];
        }
        return;
    }

    if (!self.isProgressEnabled) return;
    
    CGPoint location = [recognizer locationInView:self];
    CGFloat movPosX = 0;
    if (location.x > self.startPosX)
    {
        // right
        movPosX = location.x - self.startPosX;

    }
    else if (location.x < self.startPosX)
    {
        // left
        movPosX = -(self.startPosX - location.x);
    }

    CGFloat vw = self.bounds.size.width;
    CGFloat progressw = (vw * self.progressStartValue) + movPosX;
    self.progressSlider.progress = progressw / vw;

    if (self.sliderGestureChangedBlock) {
        self.sliderGestureChangedBlock(self.progress);
    }
}

- (void)endSwipeWithGesture:(UIPanGestureRecognizer *)recognizer
{
    if (self.panDir == PanDirVertical)
    {
        if (!self.volumeSlider && !self.brightnessSlider) return;
        self.volumeGesture = NO;
        [self.brightnessSlider hide];
        [self.volumeSlider hide];
        [self sliderIndicatorHidden];

        if (self.sliderGestureEndedBlock) {
            self.sliderGestureEndedBlock(self.sliderType);
        }
        return;
    }

    if (!self.isProgressEnabled) return;
    [self hideTrackView];
    [self.lastDragProgressSlider hideTrackView];
    self.markSlider.alpha = 0.0f;

    if (self.sliderGestureEndedBlock) {
        self.sliderGestureEndedBlock(self.sliderType);
    }
}

- (void)showTrackView {
    [self.progressSlider showBgProgressView];
}

- (void)hideTrackView {
    [self.progressSlider hideBgProgressView];
}

- (void)showBottomTrackView
{
    [self.progressSlider showTrackView];
    self.markSlider.alpha = 1.0f;
}

- (void)hideBottomTrackView
{
    [self.progressSlider hideTrackView];
    self.markSlider.alpha = 0.0f;
}

- (void)showBuffering {
    [self.bufferingView showBuffering];
}

- (void)hideBuffering {
    [self.bufferingView hideBuffering];
}

- (void)showLastDragProgress:(CGFloat)lastDragProgress {
    self.lastDragProgressSlider.progress = lastDragProgress;
    [self.lastDragProgressSlider showTrackView];
}

#pragma mark - Pan gestures

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self startSwipeWithGesture:recognizer];
            break;
        }

        case UIGestureRecognizerStateChanged:
        {
            [self swipeWithGesture:recognizer];
            break;
        }

        case UIGestureRecognizerStateEnded:
        {
            if ([recognizer numberOfTouches] == 0) {
                [self endSwipeWithGesture:recognizer];
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        {
            [self.progressSlider hide];
            [self.volumeSlider hide];
            [self.brightnessSlider hide];
            [self sliderIndicatorHidden];
            [self.lastDragProgressSlider hideTrackView];
            self.markSlider.alpha = 0.0f;

            if (!self.isProgressEnabled) return;
            self.progress = self.playingProgress;

            if (self.sliderGestureCancelledBlock) {
                self.sliderGestureCancelledBlock(self.sliderType);
            }
        }
        default:
            break;
    }
}

- (void)sliderIndicatorHidden
{
    [UIView animateWithDuration:.15 animations:^{
        self.brightnessIndicator.alpha = 0.0f;
        self.volumeIndicator.alpha = 0.0f;
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) return NO;
    return YES;
}

- (void)setEnabled:(BOOL)enabled {
    self.panRecognizer.enabled = enabled;
    [self.panRecognizer setCancelsTouchesInView:!enabled];
}

@end
