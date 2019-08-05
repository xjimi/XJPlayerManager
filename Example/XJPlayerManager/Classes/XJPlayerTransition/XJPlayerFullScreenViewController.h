//
//  XJPlayerFullScreenViewController.h
//  Player
//
//  Created by XJIMI on 2018/1/24.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPlayerTransitioningDelegate.h"

@interface XJPlayerFullScreenViewController : UIViewController

@property (nonatomic, strong) XJPlayerTransitioningDelegate *transition;

+ (instancetype)initWithPlayerContainer:(UIView *)playerContainer
                             playerView:(UIView *)playerView;

@end
