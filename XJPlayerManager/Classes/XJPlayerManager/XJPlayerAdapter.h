//
//  XJPlayerAdapter.h
//  Vidol
//
//  Created by XJIMI on 2019/3/5.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XJPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XJPlayerAdapter : NSObject

@property (nonatomic, weak, nullable) UIViewController *rootViewController;

+ (instancetype)initWithRootViewController:(UIViewController *)rootViewController
                                scrollView:(UIScrollView *)scrollView
                                  autoPlay:(BOOL)autoPlay
                                 indexPath:(NSIndexPath *)indexPath;

- (void)playAtIndexPath:(NSIndexPath *)indexPath;

- (XJPlayerView *)currentFullScreenPlayerView;

- (void)systemPause;

- (void)systemPlay;

- (void)remove;

+ (XJPlayerView *)playerViewWithPlayerModel:(XJPlayerModel *)playerModel
                            playerContainer:(UIView *)playerContainer
                         rootViewController:(UIViewController *)rootViewController;

+ (XJPlayerView *)playerViewWithPlayerModel:(XJPlayerModel *)playerModel
                                controlView:(nullable UIView *)controlView
                            playerContainer:(UIView *)playerContainer
                         rootViewController:(UIViewController *)rootViewController;

@end

NS_ASSUME_NONNULL_END
