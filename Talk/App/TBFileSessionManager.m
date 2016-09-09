//
//  TBFileSessionManager.m
//  
//
//  Created by Suric on 15/9/15.
//
//

#import "TBFileSessionManager.h"
#import "TBHTTPSessionManager.h"
#import "constants.h"

@implementation TBFileSessionManager

+ (TBFileSessionManager *)sharedManager {
    static TBFileSessionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TBFileSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kUploadURLString]];
    });
    
    return sharedManager;
}

- (id)initWithBaseURL:(NSURL *)url {
    DDLogVerbose(@"URL_ROOT: %@", url);
    self = [super initWithBaseURL:url];
    #warning For GA
    if (isGAVersion) {
        [self.requestSerializer setValue:@"ga" forHTTPHeaderField:@"X-Release-Version"];
    }
    return self;
}

@end
