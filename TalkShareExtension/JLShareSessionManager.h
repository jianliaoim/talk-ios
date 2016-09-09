//
//  JLShareSessionManager.h
//  Talk
//
//  Created by teambition-ios on 15/4/14.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kAPIBaseURLString;
extern NSString * const kTeamURLString;
extern NSString * const kSendMessageURLString;
extern NSString * const kUploadURLString;
extern NSString * const kStoryCreateURLString;

@interface JLShareSessionManager : NSURLSession

+ (NSMutableURLRequest *)requestWithURLString:(NSString *)URLString;

@end
