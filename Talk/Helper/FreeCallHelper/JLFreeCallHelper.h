//
//  JLFreeCallHelper.h
//  Talk
//
//  Created by 史丹青 on 9/22/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface JLFreeCallHelper : NSObject

- (RACSignal *)callFrom:(NSString *)fromPhone To:(NSString *)toPhone;
- (RACSignal *)cancelCall;
- (RACSignal *)creatConference;
- (RACSignal *)invitePhoneNumbers:(NSArray *)phoneNumberArray;
- (RACSignal *)cancelConference;

@end
