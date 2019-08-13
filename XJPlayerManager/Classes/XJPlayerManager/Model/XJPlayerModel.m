//
//  XJPlayerModel.m
//  Player
//
//  Created by XJIMI on 2018/1/22.
//  Copyright © 2018年 XJIMI All rights reserved.
//

#import "XJPlayerModel.h"
#import "XJPlayerUtils.h"

@implementation XJPlayerModel

+ (instancetype)initWithUrl:(NSString *)url coverImageUrl:(NSString *)coverImageUrl
{
    XJPlayerModel *youtubeModel = [[XJPlayerModel alloc] init];
    youtubeModel.videoUrl = url;
    youtubeModel.coverImageUrl = coverImageUrl;
    return youtubeModel;
}

- (void)setVideoUrl:(NSString *)videoUrl
{
    if (!videoUrl.length) return;

    NSString *extractUrl = [XJPlayerUtils extractYoutubeIdFromLink:videoUrl];
    self.playerType = XJPlayerTypeYoutube;
    if ([extractUrl hasPrefix:@"https://"] ||
        [extractUrl hasPrefix:@"http://"]) {
        self.playerType = XJPlayerTypeNative;
    }
    _videoUrl = extractUrl;
}

@end
