//
//  XJPlayerModel.h
//  Player
//
//  Created by XJIMI on 2018/1/22.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XJPlayerType) {
    XJPlayerTypeNone,
    XJPlayerTypeNative,
    XJPlayerTypeYoutube,
};

@interface XJPlayerModel : NSObject

@property (nonatomic, assign) XJPlayerType playerType;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *videoUrl;

@property (nonatomic, strong) id videoObject;

@property (nonatomic, copy) NSString *webUrl;

@property (nonatomic, copy) NSString *coverImageUrl;

@property (nonatomic, assign) NSInteger episodeId;

@property (nonatomic, assign) NSInteger programmeId;

@property (nonatomic, assign) NSTimeInterval seekTime;

@property (nonatomic, strong) NSArray *cuePoints;

@property (nonatomic, assign) BOOL is_buyer;

@property (nonatomic, assign) BOOL isLive;

@property (nonatomic, assign) BOOL muted;

+ (instancetype)initWithUrl:(NSString *)url coverImageUrl:(NSString *)coverImageUrl;

@end
