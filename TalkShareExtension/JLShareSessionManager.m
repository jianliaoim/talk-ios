//
//  JLShareSessionManager.m
//  Talk
//
//  Created by teambition-ios on 15/4/14.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "JLShareSessionManager.h"
#import "ShareConstants.h"
#import <UIKit/UIKit.h>

// Restful API Define
#ifdef DEBUG
NSString * const kAPIBaseURLString                          = @"http://custom.com/v2/";
NSString * const kUploadURLString                           = @"https://custom.com/upload";
#else
NSString * const kAPIBaseURLString                          = @"https://custom.com/v2/";
NSString * const kUploadURLString                           = @"https://custom.com/upload";
#endif

NSString * const kTeamURLString                             = @"teams";
NSString * const kSendMessageURLString                      = @"messages";
NSString * const kStoryCreateURLString                      = @"stories";

@implementation JLShareSessionManager

+ (NSMutableURLRequest *)requestWithURLString:(NSString *)URLString {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[kAPIBaseURLString stringByAppendingString:URLString]]];
    [request setHTTPMethod:@"GET"];
    NSUserDefaults *groupDeafaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
    NSString *accessToken = [groupDeafaults objectForKey:kAccessToken];
    if (accessToken) {
        [request addValue:[NSString stringWithFormat:@"aid %@", accessToken] forHTTPHeaderField:@"Authorization"];
        [request addValue:@"ios" forHTTPHeaderField:@"X-Client-Type"];
        NSString *UUIDString = [groupDeafaults objectForKey:kDeviceUUID];
        [request addValue:UUIDString forHTTPHeaderField:@"X-Client-Id"];
    }
    return request;
}

@end
