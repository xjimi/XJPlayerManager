//
//  AVPlayerView.h
//  Player
//
//  Created by XJIMI on 2018/1/20.
//  Copyright © 2018年 XJIMI All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerView : UIView

@property (nonatomic, assign) AVLayerVideoGravity playerLayerGravity;

@property (nonatomic, assign) NSTimeInterval timeRefreshInterval;

@property (nonatomic, strong) NSDictionary *requestHeader;

@property (nonatomic, assign) float rate;

@end
