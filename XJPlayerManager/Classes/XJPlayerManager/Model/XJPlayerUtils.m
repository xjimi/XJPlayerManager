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
    NSString *regexString = @"^(?:http(?:s)?://)?(?:www\\.)?(?:m\\.)?(?:youtu\\.be/|youtube\\.com/(?:(?:watch)?\\?(?:.*&)?v(?:i)?=|(?:embed|v|vi|user)/))([^\?&\"'>]+)";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:link
                                                    options:0
                                                      range:NSMakeRange(0, link.length)];
    
    if (match && match.numberOfRanges > 1)
    {
        NSRange videoIDRange = [match rangeAtIndex:1];
        NSString *videoID = [link substringWithRange:videoIDRange];
        return videoID;
    }

    return link;
}

@end
