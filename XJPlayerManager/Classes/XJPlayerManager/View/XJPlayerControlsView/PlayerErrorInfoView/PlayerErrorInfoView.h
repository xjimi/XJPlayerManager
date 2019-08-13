//
//  PlayerErrorInfoView.h
//  Vidol
//
//  Created by XJIMI on 2016/2/28.
//  Copyright © 2016年 XJIMI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidTapViewBlock)(void);

@interface PlayerErrorInfoView : UIView

@property (nonatomic, weak) IBOutlet UILabel *infoLabel;

+ (instancetype)createInView:(UIView *)inView didTapViewBlock:(DidTapViewBlock)block;

- (void)show;

- (void)showWithInfo:(NSString *)info;

- (void)hide;

@end

