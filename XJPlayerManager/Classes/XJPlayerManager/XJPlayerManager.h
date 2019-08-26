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

@property (nonatomic, assign) BOOL muted;

+ (instancetype)shared;

- (void)playInScrollView:(UIScrollView *)scrollView
               indexPath:(NSIndexPath *)indexPath
      rootViewController:(UIViewController *)rootViewController;

- (void)autoPlayInScrollView:(UIScrollView *)scrollView
          rootViewController:(UIViewController *)rootViewController;

- (void)systemPause;

- (void)systemPlay;

- (void)remove;

@end

NS_ASSUME_NONNULL_END
