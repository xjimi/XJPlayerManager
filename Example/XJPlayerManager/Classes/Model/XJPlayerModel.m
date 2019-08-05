//
//  XJPlayerModel.m
//  Player
//
//  Created by XJIMI on 2018/1/22.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import "XJPlayerModel.h"

@implementation XJPlayerModel

+ (instancetype)initWithYoutubeId:(NSString *)videoId coverImageUrl:(NSString *)coverImageUrl
{
    XJPlayerModel *youtubeModel = [XJPlayerModel new];
    youtubeModel.videoUrl = videoId;
    youtubeModel.coverImageUrl = coverImageUrl;
    youtubeModel.playerType = XJPlayerTypeYoutube;
    return youtubeModel;
}

@end
