//
//  XJPlayerAdManager.h
//  Vidol
//
//  Created by XJIMI on 2018/4/27.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XJPlayerAdManagerDelegate <NSObject>

@optional
- (void)xj_adManagerDidRequest:(NSObject *)adManager;
- (void)xj_adManagerDidStart:(NSObject *)adManager;
- (void)xj_adManagerDidFinishLoading:(NSObject *)adManager;
- (void)xj_adManagerDidEnd:(NSObject *)adManager;
- (void)xj_adManagerDidFail:(NSObject *)adManager;

@end

@interface XJPlayerAdManager : NSObject

@property (nonatomic, weak, nullable) id < XJPlayerAdManagerDelegate > delegate;

@property (nonatomic, getter=isAdPlaying, readonly) BOOL adPlaying;

+ (instancetype)initWithAdContainer:(UIView *)adContainer
                   adViewController:(UIViewController *)adViewController;

- (void)requestAdWithAdTagUrl:(NSString *)adTagUrl;

- (void)play;

- (void)pause;

- (void)resume;

@end

NS_ASSUME_NONNULL_END
