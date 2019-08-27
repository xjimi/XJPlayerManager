//
//  XJPlayerModel.h
//  Player
//
//  Created by XJIMI on 2018/1/22.
//  Copyright © 2019年 XJIMI All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XJPlayerType) {
    XJPlayerTypeNone,
    XJPlayerTypeNative,
    XJPlayerTypeYoutube
};

NS_ASSUME_NONNULL_BEGIN

@interface XJPlayerModel : NSObject

@property (nonatomic, assign) XJPlayerType playerType;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *videoUrl;

@property (nonatomic, strong) id videoObject;

@property (nonatomic, copy) NSString *coverImageUrl;

@property (nonatomic, assign) NSTimeInterval seekTime;

@property (nonatomic, copy) NSString *preRollAdUrl;

+ (instancetype)initWithUrl:(NSString *)url
              coverImageUrl:(nullable NSString *)coverImageUrl;

@end

NS_ASSUME_NONNULL_END
