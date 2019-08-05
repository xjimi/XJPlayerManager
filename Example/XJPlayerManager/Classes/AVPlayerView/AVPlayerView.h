//
//  AVPlayerView.h
//  Player
//
//  Created by XJIMI on 2018/1/20.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerLayerView : UIView

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@interface AVPlayerView : UIView

@property (nonatomic, assign) AVLayerVideoGravity playerLayerGravity;

@end
