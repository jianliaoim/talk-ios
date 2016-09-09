//
//  TBLoginSessionManager.m
//  Talk
//
//  Created by Suric on 15/11/6.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "TBLoginSessionManager.h"
#import "TBHTTPSessionManager.h"
#import "constants.h"

@implementation TBLoginSessionManager

+ (TBLoginSessionManager *)sharedManager {
    static TBLoginSessionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TBLoginSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kAccountBaseURLString]];
    });
    
    return sharedManager;
}

- (id)initWithBaseURL:(NSURL *)url {
    DDLogVerbose(@"URL_ROOT: %@", url);
    self = [super initWithBaseURL:url];
    if (self) {
    }
    #warning For GA
    if (isGAVersion) {
        [self.requestSerializer setValue:@"ga" forHTTPHeaderField:@"X-Release-Version"];
    }
    return self;
}
@end
