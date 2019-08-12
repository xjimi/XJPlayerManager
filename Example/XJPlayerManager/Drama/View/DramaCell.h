//
//  DramaCell.h
//  XJCollectionViewManager_Example
//
//  Created by XJIMI on 2019/6/10.
//  Copyright © 2019 xjimi. All rights reserved.
//


#import <XJCollectionViewManager/XJCollectionViewManager.h>
#import "DramaModel.h"
//#import <XJPlayerManager/XJPlayerManager.h>
#import "XJPlayerManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface DramaCell : XJCollectionViewCell < XJPlayerManagerProtocol >

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end

NS_ASSUME_NONNULL_END
