//
//  AlbumModel.h
//  Demo
//
//  Created by XJIMI on 2019/6/5.
//  Copyright © 2019 XJIMI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XJTableViewManager/XJTableViewManager.h>
#import "XJPlayerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlbumModel : XJTableViewCellModel

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, copy) NSString *albumName;

@property (nonatomic, copy) NSString *artistName;

@property (nonatomic, strong) XJPlayerModel *playerModel;


@end

NS_ASSUME_NONNULL_END
