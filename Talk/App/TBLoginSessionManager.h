//
//  TBLoginSessionManager.h
//  Talk
//
//  Created by Suric on 15/11/6.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface TBLoginSessionManager : AFHTTPSessionManager
+ (TBLoginSessionManager *)sharedManager;
@end
