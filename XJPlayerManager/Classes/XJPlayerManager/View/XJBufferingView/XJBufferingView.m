//
//  XJBufferingView.m
//  Vidol
//
//  Created by XJIMI on 2018/4/26.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import "XJBufferingView.h"
#import "XJPlayerBundleResource.h"

@interface XJBufferingView ()

@property (nonatomic, strong) UIView *bufferView;

@property (nonatomic, assign, getter=isBuffering) BOOL buffering;

@property (nonatomic, assign, getter=isHideBuffering) BOOL hideBuffering;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation XJBufferingView

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
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

    /*if (self.bufferView.frame.size.width == 0) {
        self.bufferView.frame = CGRectMake(0, 0, PortraitW, 221);
    }*/
    self.indicatorView.center = self.center;
}

- (void)configureView
{
    self.clipsToBounds = YES;
    self.userInteractionEnabled = NO;

    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.indicatorView.hidesWhenStopped = YES;
    [self.indicatorView stopAnimating];
    [self addSubview:self.indicatorView];
    //[self addBufferingView];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)addBufferingView
{
    self.bufferView = [[UIView alloc] init];
    UIImage *image = [XJPlayerBundleResource imageNamed:@"ic_buffering"];
    self.bufferView.backgroundColor = [UIColor colorWithPatternImage:image];
    self.bufferView.alpha = 0.0f;
    [self addSubview:self.bufferView];
}

- (void)showBuffering
{
    if (self.isBuffering) return;
    self.buffering = YES;
    NSLog(@"==== showBuffering ++++");

    [UIView animateWithDuration:.3 animations:^{
        [self.indicatorView startAnimating];
        self.indicatorView.alpha = 1.0f;
    }];

    /*
    CGFloat posY = -self.bufferView.layer.position.y * .1;
    [self removeAnimationIfNeeded];

    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    basicAnimation.duration = 4;
    basicAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.bufferView.layer.position.x, posY)];
    basicAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bufferView.layer.position.x - 100, posY)];
    basicAnimation.repeatCount = HUGE;
    basicAnimation.removedOnCompletion = NO;
    basicAnimation.fillMode = kCAFillModeForwards;
    [self.bufferView.layer addAnimation:basicAnimation forKey:@"animation"];*/

}

- (void)hideBuffering
{
    if (self.isHideBuffering || !self.isBuffering) return;
    self.hideBuffering = YES;
    [UIView animateWithDuration:.3 animations:^{
        self.indicatorView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.indicatorView stopAnimating];
        self.hideBuffering = NO;
        self.buffering = NO;
    }];
}

- (void)removeAnimationIfNeeded
{
    CAAnimation *animation = [self.bufferView.layer animationForKey:@"animation"];
    if (animation) [self.bufferView.layer removeAnimationForKey:@"animation"];
}

/*
- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    if (self.isBuffering)
    {
        self.buffering = NO;
        [self showBuffering];
    }
}*/

@end
