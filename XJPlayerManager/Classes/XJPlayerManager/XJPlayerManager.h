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

typedef void(^_Nullable XJPlayerManagerDismiss)(void);

@protocol XJPlayerManagerProtocol < NSObject >

@required

- (UIView *)playerContainer;

@property (nonatomic, strong) XJPlayerModel *playerData;

@end

@interface XJPlayerManager : NSObject

+ (instancetype)shared;

- (void)playInContainer:(UIView *)container
             playerView:(XJPlayerView *)playerView
     rootViewController:(UIViewController *)rootViewController;

- (void)playInScrollView:(UIScrollView *)scrollView
               indexPath:(NSIndexPath *)indexPath
      rootViewController:(UIViewController *)rootViewController;

- (void)autoPlayInScrollView:(UIScrollView *)scrollView
          rootViewController:(UIViewController *)rootViewController;

- (void)pause;

- (void)resume;

- (void)remove;

- (void)dismissFullScreen;

- (void)dismissFullScreenPlayerWithCompletion:(XJPlayerManagerDismiss)completion;

@end

NS_ASSUME_NONNULL_END
