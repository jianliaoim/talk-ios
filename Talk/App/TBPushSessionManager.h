//
//  TBPushSessionManager.h
//  Talk
//
//  Created by Suric on 15/12/14.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface TBPushSessionManager : AFHTTPSessionManager
+ (TBPushSessionManager *)sharedManager;
- (void)fetchBroadcastHistoryMessage;
- (void)updateMinDate:(NSDate *)newMinDate forTeam:(NSString *)teamId;
@end
