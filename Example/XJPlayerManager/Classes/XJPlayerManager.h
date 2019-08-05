//
//  XJPlayerManager.h
//  Vidol
//
//  Created by XJIMI on 2019/2/19.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XJPlayerView.h"
#import "XJPlayerAdapter.h"

NS_ASSUME_NONNULL_BEGIN

//#define XJPlayerMANAGER [XJPlayerManager shared]

typedef void(^_Nullable BlockDismiss)(void);

@protocol XJPlayerManagerProtocol < NSObject >

@required
- (UIView *)playerContainer;
//- (XJPlayerModel *)playerData;
@property (nonatomic, strong) XJPlayerModel *playerData;

@end

@interface XJPlayerManager : NSObject

+ (instancetype)shared;

- (void)playInContainer:(UIView * _Nonnull)container
             playerView:(XJPlayerView * _Nonnull)playerView
     rootViewController:(UIViewController * _Nonnull)rootViewController;

- (void)playInScrollView:(UIScrollView *)scrollView
               indexPath:(NSIndexPath * _Nonnull)indexPath
      rootViewController:(UIViewController * _Nonnull)rootViewController;

- (void)autoPlayInScrollView:(UIScrollView * _Nonnull)scrollView
          rootViewController:(UIViewController * _Nonnull)rootViewController;

- (void)pauseFromViewController:(UIViewController * __nullable)viewController;

- (void)resumeFromViewController:(UIViewController *)viewController;

- (void)removeFromViewController:(UIViewController *)viewController;

- (void)remove;

- (void)dismissFullScreen;

- (void)dismissFullScreenPlayerWithCompletion:(BlockDismiss)completion;

@end

NS_ASSUME_NONNULL_END
