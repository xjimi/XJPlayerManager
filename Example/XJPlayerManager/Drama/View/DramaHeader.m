//
//  DramaHeader.m
//  XJCollectionViewManager_Example
//
//  Created by XJIMI on 2019/6/11.
//  Copyright © 2019 xjimi. All rights reserved.
//

#import "DramaHeader.h"

@implementation DramaHeader

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)reloadData:(id)data
{
    if ([data isKindOfClass:[NSString class]]) {
        self.titleLabel.text = data;
    }
}

@end
