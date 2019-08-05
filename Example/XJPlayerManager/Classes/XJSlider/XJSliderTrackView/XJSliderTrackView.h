//
//  XJSliderTrackView.h
//  Vidol
//
//  Created by XJIMI on 2018/5/9.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XJSliderTrackDir) {
    XJSliderTrackDirBottom,
    XJSliderTrackDirLeft,
    XJSliderTrackDirRight,
    XJSliderTrackDirTop
};

@interface XJSliderTrackView : UIView

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) XJSliderTrackDir trackDir;

@property (nonatomic, assign) CGFloat trackSpacing;

@property (nonatomic, strong) UIColor *trackColor;

@property (nonatomic, strong) UIColor *progressColor;

@property (nonatomic, strong) UIColor *bgProgressColor;


- (void)show;
- (void)hide;
- (void)showTrackView;
- (void)hideTrackView;
- (void)showBgProgressView;
- (void)hideBgProgressView;

@end
