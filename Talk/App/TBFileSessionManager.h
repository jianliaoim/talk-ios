//
//  TBFileSessionManager.h
//  
//
//  Created by Suric on 15/9/15.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface TBFileSessionManager :AFHTTPSessionManager
+ (TBFileSessionManager *)sharedManager;
@end
