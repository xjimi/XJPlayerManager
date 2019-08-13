//
//  XJPlayerAdManager.m
//  Vidol
//
//  Created by XJIMI on 2018/4/27.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import "XJPlayerAdManager.h"
#import <GoogleInteractiveMediaAds/GoogleInteractiveMediaAds.h>
//#import <FBAudienceNetwork/FBAudienceNetwork.h>

typedef NS_ENUM(NSUInteger, XJPlayerAdSource) {
    XJPlayerAdSourceNone,
    XJPlayerAdSourceGoogle,
    XJPlayerAdSourceFacebook
};

@interface XJPlayerAdManager () < IMAAdsLoaderDelegate,
                                  //FBInstreamAdViewDelegate,
                                  IMAAdsManagerDelegate >

@property(nonatomic, strong) IMAAdsLoader *imaLoader;

@property(nonatomic, strong) IMAAdsManager *imaManager;

@property (nonatomic, getter=isAdPlaying, assign) BOOL adPlaying;

@property (nonatomic, weak) UIView *adContainer;

@property (nonatomic, weak) UIViewController *adViewController;

//@property (nonatomic, strong) FBInstreamAdView *fbView;

@property (nonatomic, strong) NSMutableDictionary *adPlayedUrls;

@property (nonatomic, strong) NSString *requestAdUrl;

@property (nonatomic, assign) BOOL didEnterBackground;

@property (nonatomic, assign) BOOL needResumeIMAAd;

@property (nonatomic, assign) BOOL needResumeFBAd;

@property (nonatomic, assign) XJPlayerAdSource adSource;

@end

@implementation XJPlayerAdManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __func__);
}

+ (instancetype)initWithAdContainer:(UIView *)adContainer
                   adViewController:(UIViewController *)adViewController
{
    XJPlayerAdManager *adManager = [[XJPlayerAdManager alloc] init];
    adManager.adContainer = adContainer;
    adManager.adViewController = adViewController;
    return adManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.adPlayedUrls = [[NSMutableDictionary alloc] init];
        [self addNotification];
    }
    return self;
}

- (void)pause {
    [self applicationWillEnterBackground:nil];
}

- (void)resume {
    [self applicationDidBecomeActive:nil];
}

- (void)play
{
    switch (self.adSource)
    {
        case XJPlayerAdSourceGoogle:
        {
            if (self.imaManager) {
                [self.imaManager start];
            }
            break;
        }
        case XJPlayerAdSourceFacebook:
        {
            /*
            if (self.fbView)
            {
                if ([self.delegate respondsToSelector:@selector(xj_adManagerDidStart:)]) {
                    [self.delegate xj_adManagerDidStart:self];
                }
                
                [self.fbView showAdFromRootViewController:self.adViewController];
            }*/
            break;
        }
        default:
            break;
    }
}

- (void)requestAdWithAdTagUrl:(NSString *)adTagUrl
{
    if (!adTagUrl.length || self.requestAdUrl) return;
    BOOL isPlayed = [self.adPlayedUrls[adTagUrl] boolValue];
    if (self.isAdPlaying || isPlayed) return;
    self.requestAdUrl = adTagUrl;

    self.adSource = XJPlayerAdSourceGoogle;
    
    IMAAdDisplayContainer *adDisplayContainer =
    [[IMAAdDisplayContainer alloc] initWithAdContainer:self.adContainer companionSlots:nil];
    IMAAdsRequest *request = [[IMAAdsRequest alloc] initWithAdTagUrl:adTagUrl
                                                  adDisplayContainer:adDisplayContainer
                                                     contentPlayhead:nil
                                                         userContext:nil];

    if (!self.imaLoader)
    {
        IMASettings *imaSettings = [[IMASettings alloc] init];
        imaSettings.ppid = @"18689016";
        imaSettings.language = @"en";
        self.imaLoader = [[IMAAdsLoader alloc] initWithSettings:imaSettings];
        self.imaLoader.delegate = self;
    }

    [self.imaLoader requestAdsWithRequest:request];

    if ([self.delegate respondsToSelector:@selector(xj_adManagerDidRequest:)]) {
        [self.delegate xj_adManagerDidRequest:self];
    }
}

#pragma mark AdsLoader Delegates

- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData
{
    NSLog(@"adsLoadedWithData");
    self.imaManager = adsLoadedData.adsManager;
    self.imaManager.delegate = self;
    IMAAdsRenderingSettings *adsRenderingSettings = [[IMAAdsRenderingSettings alloc] init];
    [self.imaManager initializeWithAdsRenderingSettings:adsRenderingSettings];
}

- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData
{
    // Something went wrong loading ads. Log the error and play the content.
    NSLog(@"IMAAdsManager failedWithErrorData: %@", adErrorData.adError.message);
    [self loadInstreamAd];
}

#pragma mark AdsManager Delegates

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event
{
    if (event.type == kIMAAdEvent_LOADED)
    {
        if (self.didEnterBackground)
        {
            self.needResumeIMAAd = YES;
            return;
        }
        
        // 由playAD()控制
        if ([self.delegate respondsToSelector:@selector(xj_adManagerDidFinishLoading:)]) {
            [self.delegate xj_adManagerDidFinishLoading:self];
        }
        
//        [adsManager start];
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error
{
    NSLog(@"IMAAdsManager didReceiveAdError: %ld : %@", (long)error.code, error.message);
    [self loadInstreamAd];
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager
{
    NSLog(@"AdsManager = Pause");
    self.adPlaying = YES;
    self.needResumeIMAAd = NO;
    if ([self.delegate respondsToSelector:@selector(xj_adManagerDidStart:)]) {
        [self.delegate xj_adManagerDidStart:self];
    }
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager
{
    NSLog(@"AdsManager = Resume");
    self.adPlaying = NO;
    self.needResumeIMAAd = NO;
    [self recordAdPlayedUrl];
    [self removeIMAAD];

    if ([self.delegate respondsToSelector:@selector(xj_adManagerDidEnd:)]) {
        [self.delegate xj_adManagerDidEnd:self];
    }
}

- (void)recordAdPlayedUrl
{
    if (self.requestAdUrl.length)
    {
        self.adPlayedUrls[self.requestAdUrl] = @1;
        self.requestAdUrl = nil;
    }
}

- (void)removeIMAAD
{
    self.imaManager = nil;
    self.imaLoader.delegate = nil;
    self.imaLoader = nil;
}

#pragma mark facebook audience ad

- (void)loadInstreamAd
{
    /*
    [self removeIMAAD];
    
    self.adSource = XJPlayerAdSourceFacebook;
    
    NSLog(@"fbAd == loadInstreamAd");
    if (!self.fbView)
    {
        //1044817312247946_1826619924067677
        //1044817312247946_1845419472187722
        self.fbView = [[FBInstreamAdView alloc] initWithPlacementID:@"1044817312247946_1845419472187722"];
        self.fbView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.fbView.delegate = self;
    }

    if (self.didEnterBackground)
    {
        self.needResumeFBAd = YES;
        return;
    }
    [self.fbView loadAd];
     */
}

/*
- (void)adViewDidLoad:(FBInstreamAdView *)adView
{
    NSLog(@"fbAd - adViewDidLoad");
    //要注意「Background mode : audio,airplay」時，廣告會在背景播
//    if (self.didEnterBackground) {
//        NSLog(@"進入背景才load好的 一律刪除");
//        self.needResumeFBAd = YES;
//        [self removeFBAd];
//        return;
//     }

    if ([self.delegate respondsToSelector:@selector(xj_adManagerDidFinishLoading:)]) {
        [self.delegate xj_adManagerDidFinishLoading:self];
    }

    self.adPlaying = YES;
    self.needResumeFBAd = NO;
    // The ad can now be added to the layout and shown
    [self.adContainer addSubview:self.fbView];
    self.fbView.frame = self.adContainer.bounds;
    
    // 由playAD()控制
//    [self.fbView showAdFromRootViewController:self.adViewController];
//    if ([self.delegate respondsToSelector:@selector(xj_adManagerDidStart:)]) {
//        [self.delegate xj_adManagerDidStart:self];
//    }
}

- (void)adViewDidEnd:(FBInstreamAdView *)adView
{
    NSLog(@"fbAd - ended");
    self.adPlaying = NO;
    self.needResumeFBAd = NO;
    [self recordAdPlayedUrl];
    [self removeFBAd];
    if ([self.delegate respondsToSelector:@selector(xj_adManagerDidEnd:)]) {
        [self.delegate xj_adManagerDidEnd:self];
    }
}

- (void)adView:(FBInstreamAdView *)adView didFailWithError:(NSError *)error
{
    NSLog(@"fbAd - failed: %@", error);
    self.adPlaying = NO;
    self.needResumeFBAd = NO;
    self.requestAdUrl = nil;
    [self removeFBAd];
    if ([self.delegate respondsToSelector:@selector(xj_adManagerDidFail:)]) {
        [self.delegate xj_adManagerDidFail:self];
    }
}

- (void)removeFBAd
{
    [self.fbView removeFromSuperview];
    self.fbView = nil;
}
 */
- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)applicationWillEnterBackground:(NSNotification*)notification
{
    self.didEnterBackground = YES;
    if (self.imaManager) {
        [self.imaManager pause];
    }
}

- (void)applicationDidBecomeActive:(NSNotification*)notification
{
    self.didEnterBackground = NO;
    if (self.isAdPlaying && self.imaManager) {
        [self.imaManager resume];
        return;
    }

    if (self.needResumeFBAd)
    {
        NSLog(@"resume - fb");
        [self loadInstreamAd];
    }
    else if (self.needResumeIMAAd)
    {
        NSLog(@"resume - adsManager start");
        [self.imaManager start];
    }
}

#pragma mark - FBAd test
/*
- (void)addFBTestDevice
{
    [FBAdSettings clearTestDevices];
    [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
}
*/

@end
