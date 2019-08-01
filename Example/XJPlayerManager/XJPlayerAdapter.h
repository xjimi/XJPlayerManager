//
//  XJPlayerAdapter.h
//  Vidol
//
//  Created by XJIMI on 2019/3/5.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XJPlayerView.h"


@interface XJPlayerAdapter : NSObject

@property (nonatomic, assign) UIViewController *rootViewController;

@property (nonatomic, strong) NSMutableDictionary *players;

+ (instancetype)initWithRootViewController:(UIViewController *)rootViewController
                                scrollView:(UIScrollView *)scrollView
                                  autoPlay:(BOOL)autoPlay
                                 indexPath:(NSIndexPath *)indexPath;

- (void)playAtIndexPath:(NSIndexPath *)indexPath;

- (XJPlayerView *)currentFullScreenPlayerView;

- (void)pause;

- (void)resume;

- (void)remove;

@end

