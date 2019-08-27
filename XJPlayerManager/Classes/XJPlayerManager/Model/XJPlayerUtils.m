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

+ (NSString *)videoFormatTime:(NSTimeInterval)time
{
    time = isnan(time) ? 0 : time;
    NSInteger hr  = floor(time / 60.0f / 60.0f);
    NSInteger min = (NSInteger)(time / 60.0f) % 60;
    NSInteger sec = (NSInteger)time % 60;

    NSString *timeStr;
    if (hr > 0) {
        timeStr = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", hr, min, sec];
    } else {
        timeStr = [NSString stringWithFormat:@"%02zd:%02zd", min, sec];
    }
    return timeStr;
}

@end
