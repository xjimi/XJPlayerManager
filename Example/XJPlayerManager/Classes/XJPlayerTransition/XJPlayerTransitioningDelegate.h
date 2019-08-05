//
//  XJPlayerTransition.h
//  XJPlayerTransition
//
//  Created by XJIMI on 2019/1/22.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XJPlayerTransitioningDelegate : NSObject < UIViewControllerTransitioningDelegate >

@property (nonatomic, weak) UIView *sourceView;
@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, weak) UIView *playerView;

@property (nonatomic, assign) NSTimeInterval presentDuration;
@property (nonatomic, assign) NSTimeInterval dismissDuration;

@end

NS_ASSUME_NONNULL_END
