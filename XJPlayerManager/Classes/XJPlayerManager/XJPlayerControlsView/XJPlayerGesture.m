//
//  XJPlayerGesture.m
//  Player
//
//  Created by XJIMI on 2018/1/25.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import "XJPlayerGesture.h"
#import <MediaPlayer/MediaPlayer.h>

@interface XJPlayerGesture () < UIGestureRecognizerDelegate >

@property (nonatomic, weak) UIView *view;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@end

@implementation XJPlayerGesture

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

+ (instancetype)initWithView:(UIView *)view
{
    XJPlayerGesture *playerGesture = [[XJPlayerGesture alloc] init];
    playerGesture.view = view;
    return playerGesture;
}

- (void)addTapGesture
{
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(action_singleTapGesture:)];
    self.singleTap.delegate                = self;
    self.singleTap.numberOfTouchesRequired = 1; //手指数
    self.singleTap.numberOfTapsRequired    = 1;
    [self.view addGestureRecognizer:self.singleTap];

    // 双击(播放/暂停)
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(action_doubleTapGesture:)];
    self.doubleTap.delegate                = self;
    self.doubleTap.numberOfTouchesRequired = 1; //手指数
    self.doubleTap.numberOfTapsRequired    = 2;
    [self.view addGestureRecognizer:self.doubleTap];

    // 解决点击当前view时候响应其他控件事件
    [self.singleTap setDelaysTouchesBegan:YES];
    [self.doubleTap setDelaysTouchesBegan:YES];
    // 双击失败响应单击事件
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
}

#pragma mark - action

- (void)action_singleTapGesture:(UIGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(xj_playerGestureSingleTap:)]) {
        [self.delegate xj_playerGestureSingleTap:gesture];
    }
}

- (void)action_doubleTapGesture:(UIGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(xj_playerGestureDoubleTap:)]) {
        [self.delegate xj_playerGestureDoubleTap:gesture];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([self.delegate respondsToSelector:@selector(xj_playerGestureRecognizer:shouldReceiveTouch:)]) {
        return [self.delegate xj_playerGestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
    return YES;
}

/*
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if(touch.tapCount == 1)
    {
        [self performSelector:@selector(action_singleTapGesture:) withObject:@(NO) ];
    }
    else if (touch.tapCount == 2)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(action_singleTapGesture:) object:nil];
        [self action_doubleTapGesture:touch.gestureRecognizers.lastObject];
    }
}*/

@end
