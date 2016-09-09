//
//  JLAccountHelper.h
//  Talk
//
//  Created by 史丹青 on 9/8/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"

@interface JLAccountHelper : NSObject

+ (void)setAccessToken:(NSString *)accessToken;
+ (void)setCurrentUserKey:(NSString *)userId;
+ (void)updateUserDataWithResponse:(NSDictionary *)responseObject;
+ (RACSignal *)changeUserName:(NSString *)userName;

@end
