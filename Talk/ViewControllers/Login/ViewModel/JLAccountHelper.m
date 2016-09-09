//
//  JLAccountHelper.m
//  Talk
//
//  Created by 史丹青 on 9/8/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "JLAccountHelper.h"
#import "TBHTTPSessionManager.h"
#import "CoreData+MagicalRecord.h"
#import "constants.h"
#import "TBUtility.h"
#import "TBUser.h"

@implementation JLAccountHelper

+ (void)setAccessToken:(NSString *)accessToken {
    if (accessToken) {
        DDLogVerbose(@"accessToken: %@", accessToken);
        [[TBHTTPSessionManager sharedManager].requestSerializer setValue:[NSString stringWithFormat:@"aid %@", accessToken] forHTTPHeaderField:@"Authorization"];
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject:accessToken forKey:kAccessToken];
        [standardUserDefaults setBool:YES forKey:kUserHaveLogin];
        [standardUserDefaults synchronize];
        
        NSUserDefaults *groupDeafaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
        [groupDeafaults setObject:accessToken forKey:kAccessToken];
        [groupDeafaults setBool:YES forKey:kUserHaveLogin];
        [groupDeafaults synchronize];
        
        [[TBUtility currentAppDelegate] openRemoteNotification];
        //fetch striker token for upload file
        //[[TBHTTPSessionManager sharedManager] fetchStrikerToken];
    }
}

+ (void)setCurrentUserKey:(NSString *)userId {
    if (userId) {
        [[NSUserDefaults standardUserDefaults] setValue:userId forKey:kCurrentUserKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)updateUserDataWithResponse:(NSDictionary *)responseObject {
    TBUser *newUser = [MTLJSONAdapter modelOfClass:[TBUser class]
                                fromJSONDictionary:responseObject
                                             error:NULL];
    
    // save user id & name & avatar to user d8efault
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:newUser.id forKey:kCurrentUserKey];
    [defaults setValue:newUser.name forKey:kCurrentUserName];
    [defaults setValue:[newUser.avatarURL absoluteString] forKey:kCurrentUserAvatar];
    [defaults synchronize];
    
    //容联云通信
    NSDictionary *voip = responseObject[@"voip"];
    if (voip != nil) {
        [[NSUserDefaults standardUserDefaults] setValue:voip[@"subAccountSid"] forKey:KYTXSubAccountSid];
        [[NSUserDefaults standardUserDefaults] setValue:voip[@"subToken"] forKey:kYTXSubAccountToken];
    }
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MOUser *user = [MOUser findFirstWithId:newUser.id inContext:localContext];
        if (user == nil) {
            user = [MTLManagedObjectAdapter managedObjectFromModel:newUser insertingIntoContext:localContext error:NULL];
        } else {
            user.avatarURL = newUser.avatarURL.absoluteString;
            user.name = newUser.name;
            user.phoneForLogin = newUser.phoneForLogin;
        }
    } completion:^(BOOL success, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPersonalInfoChangeNotification object:nil];
    }];
    
    //user preference
    BOOL emailNotification = [[[responseObject objectForKey:@"preference"] objectForKey:@"emailNotification"] boolValue];
    BOOL notifyOnRelated = [[[responseObject objectForKey:@"preference"] objectForKey:@"notifyOnRelated"] boolValue];
    [defaults setBool:emailNotification forKey:kEmailNOtification];
    [defaults setBool:notifyOnRelated forKey:kNotifyOnRelated];
    [defaults synchronize];
}

+ (RACSignal *)changeUserName:(NSString *)userName {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:userName forKey:@"name"];
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:kCurrentUserName];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [manager PUT:[NSString stringWithFormat:@"users/%@", userID]
          parameters:parameters
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 DDLogVerbose(@"Successfully updated name");
                 TBUser *newUser = [MTLJSONAdapter modelOfClass:[TBUser class]
                                             fromJSONDictionary:responseObject
                                                          error:NULL];
                 [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                     NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
                     MOUser *user = [MOUser findFirstWithId:userID inContext:localContext];
                     if (user) {
                         user.name = newUser.name;
                         user.mobile = newUser.mobile;
                     } else {
                         if (newUser) {
                             user = [MTLManagedObjectAdapter managedObjectFromModel:newUser insertingIntoContext:localContext error:NULL];
                         }
                     }
                 } completion:^(BOOL success, NSError *error) {
                     if (!error) {
                         [[NSNotificationCenter defaultCenter] postNotificationName:kPersonalInfoChangeNotification object:userName];
                         [subscriber sendNext:userName];
                         [subscriber sendCompleted];
                     } else {
                         [subscriber sendError:error];
                     }
                 }];
             }
             failure:^(NSURLSessionDataTask *task, NSError *error) {
                 DDLogError(@"error: %@", error.localizedRecoverySuggestion);
                 [subscriber sendError:error];
             }];
        return Nil;
    }];
    
}

@end
