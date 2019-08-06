//
//  DramaCell.m
//  XJCollectionViewManager_Example
//
//  Created by XJIMI on 2019/6/10.
//  Copyright © 2019 xjimi. All rights reserved.
//

#import "DramaCell.h"

@implementation DramaCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)reloadData:(id)data
{
    if ([data isKindOfClass:[DramaModel class]])
    {
        DramaModel *dramaModel = (DramaModel *)data;
        self.playerData = dramaModel.playerModel;

        self.coverImageView.image = [UIImage imageNamed:dramaModel.imageName];
        self.titleLabel.text = dramaModel.dramaName;
        self.subtitleLabel.text = dramaModel.detailInfo;
    }
}


@synthesize playerData;

- (nonnull UIView *)playerContainer {
    return self.coverImageView;
}

@end
