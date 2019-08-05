//
//  XJSlider.h
//  ViewPanGesture
//
//  Created by XJIMI on 2018/3/26.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSInteger, XJSliderType) {
    XJSliderTypeNone,
    XJSliderTypeProgress,
    XJSliderTypeVolume,
    XJSliderTypeBrightness
};

typedef void(^XJSliderGestureBeganBlock)(XJSliderType sliderType);
typedef void(^XJSliderGestureChangedBlock)(CGFloat progress);
typedef void(^XJSliderGestureEndedBlock)(XJSliderType sliderType);
typedef void(^XJSliderGestureCancelledBlock)(XJSliderType sliderType);

@interface XJSlider : UIView

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) CGFloat playingProgress;

@property (nonatomic, strong) MPVolumeView *mpVolumeView;
@property (nonatomic, strong) UIButton *btn_airPlay;

@property(nonatomic, getter=isProgressEnabled) BOOL progressEnabled;

@property(nonatomic, getter=isEnabled) BOOL enabled;

- (void)hideTrackView;
- (void)showBottomTrackView;
- (void)hideBottomTrackView;
- (void)showBuffering;
- (void)hideBuffering;

- (void)addSliderGestureBeganBlock:(XJSliderGestureBeganBlock)block;
- (void)addSliderGestureChangedBlock:(XJSliderGestureChangedBlock)block;
- (void)addSliderGestureEndedBlock:(XJSliderGestureEndedBlock)block;
- (void)addSliderGestureCancelledBlock:(XJSliderGestureCancelledBlock)block;

- (void)addProgressSlider;
- (void)addVolumeSlider;
- (void)addBrightnessSlider;
- (void)addLastDragProgressSlider;
- (void)addMarkSliderWithPositions:(NSArray *)positions;

@end
