//
//  XJPlayerUtils.m
//  XJPlayerManager_Example
//
//  Created by XJIMI on 2019/8/2.
//  Copyright © 2019 xjimi. All rights reserved.
//

#import "XJPlayerUtils.h"

@implementation XJPlayerUtils

+ (NSString *)extractYoutubeIdFromLink:(NSString *)link
{
    NSString *regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    NSArray *array = [regExp matchesInString:link options:0 range:NSMakeRange(0, link.length)];
    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
        return [link substringWithRange:result.range];
    }

    return link;
}

@end
