//
//  XJPlayerGesture.h
//  Player
//
//  Created by XJIMI on 2018/1/25.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol XJPlayerGestureDelegate <NSObject>
@optional

- (void)xj_playerGestureSingleTap:(UIGestureRecognizer *)gesture;

- (void)xj_playerGestureDoubleTap:(UIGestureRecognizer *)gesture;

- (BOOL)xj_playerGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
                shouldReceiveTouch:(UITouch *)touch;


@end

@interface XJPlayerGesture : NSObject

@property (nonatomic, weak) id<XJPlayerGestureDelegate> delegate;


+ (instancetype)initWithView:(UIView *)view;

- (void)addTapGesture;

@end
