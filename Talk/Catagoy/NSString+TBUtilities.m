//
//  NSString+TBUtilities.m
//  Talk
//
//  Created by 王卫 on 15/11/24.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "NSString+TBUtilities.h"
#import <Hanzi2Pinyin/Hanzi2Pinyin.h>
#import "NSString+Emoji.h"

@implementation NSString (TBUtilities)

- (BOOL)isValidUrl {
    if (self.length > 0) {
        NSError *error = nil;
        NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        if (dataDetector && !error) {
            NSRange range = NSMakeRange(0, self.length);
            NSRange notFoundRange = (NSRange){NSNotFound, 0};
            NSRange linkRange = [dataDetector rangeOfFirstMatchInString:self options:0 range:range];
            if (!NSEqualRanges(notFoundRange, linkRange) && NSEqualRanges(range, linkRange)) {
                return YES;
            }
        }
    }
    return NO;
}

- (NSString *)getTalkTeamImageName {
    NSString *firstLetter = [NSString getFirstWordWithEmojiForString:[Hanzi2Pinyin convertToAbbreviation:self]];
    NSString *imageName = @"alphabet-smile";
    if (firstLetter.length) {
        unichar firstChar = [[firstLetter lowercaseString] characterAtIndex:0];
        if (firstChar >= 'a' && firstChar <= 'z') {
            imageName = [NSString stringWithFormat:@"alphabet-%@", [firstLetter lowercaseString]];
        } else if (firstChar >= '0' && firstChar <= '9') {
            imageName = [NSString stringWithFormat:@"number-%@", firstLetter];
        }
    }
    return imageName;
}

- (BOOL)isQQEmail {
    return [self.lowercaseString hasSuffix:@"qq.com"];
}

@end
