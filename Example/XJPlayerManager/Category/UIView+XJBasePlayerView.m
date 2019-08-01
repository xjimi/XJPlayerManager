//
//  UIView+PlayerBaseEvent.m
//  Player
//
//  Created by XJIMI on 2018/1/22.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import "UIView+XJBasePlayerView.h"
#import <objc/runtime.h>

@implementation UIView (XJBasePlayerView)

- (void)setDelegate:(id<XJBasePlayerViewDelegate>)delegate {
    objc_setAssociatedObject(self, @selector(delegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<XJBasePlayerViewDelegate>)delegate {
    return objc_getAssociatedObject(self, _cmd);
}

/* Player操作功能 */

- (void)xj_vip:(BOOL)isVip {}

- (void)xj_setVideoObject:(id)videoObject {}

- (void)xj_play {}

- (void)xj_pause {}

- (void)xj_seekToTime:(NSTimeInterval)time
    completionHandler:(void (^)(BOOL))completionHandler {}

- (void)xj_resetPlayer {}


- (void)xj_bufferingSomeSecond {}

- (NSTimeInterval)xj_currentTime {
    return 0;
}

- (NSTimeInterval)xj_duration {
    return 0;
}

- (BOOL)xj_isReadyToPlay {
    return NO;
}

- (BOOL)xj_isLikelyToKeepUp {
    return NO;
}

- (BOOL)xj_isValidDuration {
    return NO;
}

- (void)xj_layoutPortrait {
}

- (void)xj_layoutFullScreen {
}

/* Player狀態 */

- (void)xj_playerStatusReadyToPlay {}

- (void)xj_playerStatusBuffering {}

- (void)xj_playerStatusPlaying {}

- (void)xj_playerStatusEnded {}

- (void)xj_playerStatusFailed {}

/* Player更新顯示時間 */

- (void)xj_playerLoadedTimeRangesWithProgress:(CGFloat)progress {}

- (void)xj_playerCurrentTime:(NSTimeInterval)currentTime
                   totalTime:(NSTimeInterval)totalTime {}

- (void)xj_preferredStreamInfo:(StreamInfoModel *)streamInfo {}

- (void)xj_findM3U8ResolutionWithUrl:(NSString *)url
                          completion:(void(^)(NSArray *resolutions))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSMutableArray *streamList = [[NSMutableArray alloc] init];
        NSError *error;
        NSURL *URL = [NSURL URLWithString:url];
        M3U8PlaylistModel *playlistModel = [[M3U8PlaylistModel alloc] initWithURL:URL error:&error];
        if (error)
        {
            NSLog(@"M3U8PlaylistModel error: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(streamList);
            });
            return;
        }

        M3U8ExtXStreamInfList *streamInfList = playlistModel.masterPlaylist.xStreamList;
        [streamInfList sortByBandwidthInOrder:NSOrderedAscending];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (NSInteger i = 0; i< streamInfList.count; i++)
        {
            M3U8ExtXStreamInf *streamInfo = [streamInfList xStreamInfAtIndex:i];
            NSString *resolution = NSStringFromMediaResolution(streamInfo.resolution);
            [dict setObject:@(streamInfo.bandwidth) forKey:resolution];
        }

        NSArray *sortedKeys = [self sortKeysByIntValue:dict];
        for (NSString *key in sortedKeys)
        {
            NSString *resolution = key;
            NSArray *subStrings = [resolution componentsSeparatedByString:@"x"];
            CGFloat width = [subStrings.firstObject integerValue];
            CGFloat height = [subStrings.lastObject integerValue];
            NSDictionary *dictionary = @{@"resolution" : resolution,
                                         @"bandWidth"  : dict[key],
                                         @"width"      : @(width),
                                         @"height"     : @(height)};
            StreamInfoModel *model = [StreamInfoModel modelWithDictionary:dictionary];
            [streamList addObject:model];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(streamList);
        });

    });
}

- (NSArray *)sortKeysByIntValue:(NSDictionary *)dictionary
{
    NSArray *sortedKeys = [dictionary keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int v1 = [obj1 intValue];
        int v2 = [obj2 intValue];

        if (v1 < v2)
            return NSOrderedAscending;
        else if (v1 > v2)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    return sortedKeys;
}

- (BOOL)hasAD {
    return NO;
}

- (void)loadVideo { }

- (void)playPreloadADAt:(NSTimeInterval)seekTime { }


@end
