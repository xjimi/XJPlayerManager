//
//  PlayerErrorInfoView.m
//  Vidol
//
//  Created by XJIMI on 2016/2/28.
//  Copyright © 2016年 XJIMI. All rights reserved.
//

#import "PlayerErrorInfoView.h"
#import <Masonry/Masonry.h>
#import "XJPlayerBundleResource.h"

@interface PlayerErrorInfoView () < UIGestureRecognizerDelegate >

@property (nonatomic, copy) DidTapViewBlock didTapViewBlock;

@end

@implementation PlayerErrorInfoView

+ (instancetype)createInView:(UIView *)inView didTapViewBlock:(DidTapViewBlock)block
{
    PlayerErrorInfoView *nibView  = (PlayerErrorInfoView *)[XJPlayerBundleResource nibViewWithNamed:NSStringFromClass(self)];

    nibView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [inView addSubview:nibView];
    nibView.backgroundColor = [UIColor blackColor];
    nibView.frame = inView.bounds;
    UIImage *reload = [XJPlayerBundleResource imageNamed:@"ic_reload_light"];
    nibView.infoImageView.image = reload;
    nibView.alpha = 0.0f;
    if (block)
    {
        nibView.didTapViewBlock = block;
        [nibView addGesture];
    }
    return nibView;
}

- (void)addGesture
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.delegate = self;
    [self addGestureRecognizer:singleTap];
}

- (void)tapDetected:(UIGestureRecognizer *)gestureRecognizer
{
    [self hide];
    if (self.didTapViewBlock) self.didTapViewBlock();
}

- (void)show {
    [self showWithInfo:nil];
}

- (void)showWithInfo:(NSString *)info
{
    info = info ? : @"Network Error";
    self.infoLabel.text = info;
    [self animationWithHidden:NO];
}

- (void)hide {
    [self animationWithHidden:YES];
}

- (void)animationWithHidden:(BOOL)hidden
{
    CGFloat alpha = hidden ? 0.0f : 1.0f;
    if (self.alpha == alpha) return;
    [UIView animateWithDuration:.4 delay:0 options:(7 << 16) animations:^{
        self.alpha = alpha;
    } completion:nil];
}

@end
