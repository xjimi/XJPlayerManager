//
//  UIImageView+XJPlayerImageManager.m
//  XJPlayerManager_Example
//
//  Created by XJIMI on 2019/8/13.
//  Copyright © 2019 xjimi. All rights reserved.
//

#import "UIImageView+XJPlayerImageManager.h"
#import <XJUtil/NSArray+XJEnumExtensions.h>
#import <XJUtil/UIImageView+XJImageManager.h>

@implementation UIImageView (XJPlayerImageManager)

- (void)xj_imageWithURL:(NSURL *)url
        placeholderType:(XJImagePlaceholderType)placeholderType
       downloadAnimated:(BOOL)downloadAnimated
           cornerRadius:(CGFloat)radius
             completion:(XJImageManagerCompletion)completion
{
    self.image = nil;
    NSString *placeholder = [XJImagePlaceholderTypes stringFromEnum:XJImagePlaceholderTypeDefault];
    UIImage *placeholderImage = [UIImage imageNamed:placeholder];
    [self pin_setImageFromURL:url
             placeholderImage:placeholderImage
                   completion:^(PINRemoteImageManagerResult *result)
     {
         self.image = nil;
         __weak typeof(self)weakSelf = self;
         NSString *placeholder = [XJImagePlaceholderTypes stringFromEnum:placeholderType];
         UIImage *placeholderImage = [UIImage imageNamed:placeholder];

         [self pin_setImageFromURL:url
                  placeholderImage:placeholderImage
                        completion:^(PINRemoteImageManagerResult *result)
          {

              if (downloadAnimated)
              {
                  if (result.resultType == PINRemoteImageResultTypeDownload)
                  {
                      weakSelf.alpha = 0.0f;
                      [UIView animateWithDuration:.6 animations:^{
                          weakSelf.alpha = 1.0f;
                      }];
                  }
                  else
                  {
                      weakSelf.alpha = 1.0f;
                  }
              }

              if (completion) completion(result.image);

          }];

     }];
}

@end
