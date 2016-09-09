//
// Created by Shire on 9/18/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//


#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import "TBHTTPSessionManager.h"
#import "JSONResponseSerializerWithData.h"
#import "constants.h"
#import "SSKeychain.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "TBUtility.h"
#import "TBPushSessionManager.h"

#import "TBUser.h"
#import "MOUser.h"

/**************URL Related *******/

/*beta.custom.com
  account.beta.custom.com
 */

//Restful API Define

#ifdef DEBUG

//TPS (Talk push service) key 已经被替换掉，没有推送服务(可以自己搭建推送服务)
NSString * const kTPSAppKey                                 = @"fejfhejfuf";
NSString * const kTPSAppSecret                              = @"fkjefbrejkrejrkj";
NSString * const kTPSBaseURLString                          = @"http://tps.custom.com/v1/";
NSString * const kTPSSocketURLString                        = @"ws://tps.custom.com/engine.io/?transport=websocket&userId=%@&deviceToken=%@";

//base url
NSString * const kAPIBaseURLString                          = @"http://192.168.0.35:7001/v2/"; //setup your custom server

//socket connect url


//file upload
NSString * const kUploadURLString                           = @"替换成自己的文件服务器";

//privacy
NSString * const kPrivacyURLString                          = @"http://custom.com/site/items";

//account
NSString * const kAccountBaseURLString                      = @"http://192.168.0.35:7001/account/v1/"; //setup your custom server

//容联云通信
NSString * const kYTXCallURLString                          = @"https://sandboxapp.cloopen.com:8883/2013-12-26/SubAccounts/%@/Calls/Callback?sig=%@";
NSString * const kYTXCancelCallURLString                    = @"https://sandboxapp.cloopen.com:8883/2013-12-26/SubAccounts/%@/Calls/CallCancel?sig=%@";
NSString * const kYTXCreateConferenceURLString              = @"https://sandboxapp.cloopen.com:8883/2013-12-26/Accounts/%@/ivr/createconf?sig=%@&maxmember=20";
NSString * const kYTXCancelConferenceURLString              = @"https://sandboxapp.cloopen.com:8883/2013-12-26/Accounts/%@/ivr/conf?sig=%@&confid=%@";
NSString * const kYTXInviteMemberURLString                  = @"https://sandboxapp.cloopen.com:8883/2013-12-26/Accounts/%@/ivr/conf?sig=%@&confid=%@";

//Feedback Path
NSString * const kFeedbackPath                              = @"services/webhook/8630a7df81bfcbfa99a96ba1815420975e5f628d";

// Image valid
NSString * const KImageValidURLString                       = @"http://captcha.custom.com/captcha";

#else
// release 环境需要配置 Debug 对应的地址
#endif

/**************URL Path Related *******/

//device token
NSString * const kDeviceTokenURLString                      = @"devicetokens";

//acoount
NSString * const kEmailSignUpPath                           = @"email/signup";
NSString * const kEmailSignInPath                           = @"email/signin";
NSString * const kEmailSendVerifyCodePath                   = @"email/sendverifycode";
NSString * const kEmailCheckVerifyCodePath                  = @"email/signinbyverifycode";
NSString * const KEmailResetPasswordpath                    = @"email/resetpassword";
NSString * const kEmailBindPath                             = @"email/bind";
NSString * const kEmailForceBindPath                        = @"email/forcebind";
NSString * const kEmailChangePath                           = @"email/change";

NSString * const kMobileSignUpPath                          = @"mobile/signup";
NSString * const kMobileSignInPath                          = @"mobile/signin";
NSString * const kMobileSendVerifyCodePath                  = @"mobile/sendverifycode";
NSString * const kMobileCheckVerifyCodePath                 = @"mobile/signinbyverifycode";
NSString * const KMobileResetPasswordpath                   = @"mobile/resetpassword";
NSString * const kMobileBindPath                            = @"mobile/bind";
NSString * const kMobileUnbindPath                          = @"mobile/unbind";
NSString * const kMobileForceBindPath                       = @"mobile/forcebind";
NSString * const kMobileChangePath                          = @"mobile/change";

NSString * const kLoginWithTeambitionPath                   = @"union/signin/teambition";
NSString * const kBindTeambitionPath                        = @"union/bind/teambition";
NSString * const kForceBindTeambitionPath                   = @"union/forcebind/teambition";
NSString * const kUnbindTeambitionPath                      = @"union/unbind/teambition";
NSString * const kCheckAllBindAccountsPath                  = @"user/accounts";

//user
NSString * const kGetUserInfoWithPhoneURLString             = @"users";
NSString * const kLogoutURLString                           = @"users/signout";
NSString * const kMeInfoURLString                           = @"users/me";
NSString * const kSyncMeInfoURLString                       = @"users/me?syncAccount=1";
NSString * const kBadgeURLString                            = @"users/badge";
NSString * const kUserSubscribeString                       = @"users/subscribe";

//group
NSString * const kGetGroupsURLString                        = @"groups?_teamId=%@";
NSString * const kCreateGroupURLString                      = @"groups";
NSString * const kUpdateGroupURLString                      = @"groups/%@";
NSString * const kRemoveGroupURLString                      = @"groups/%@";

//team
NSString * const kTeamURLString                             = @"teams";
NSString * const kGetRoomsURLString                         = @"teams/%@/rooms";
NSString * const kGetMembersURLString                       = @"teams/%@/members";
NSString * const kLeftMembersURLString                      = @"teams/%@/members?isQuit=true";
NSString * const kMemberUpdateURLString                     = @"teams/%@/setmemberrole";
NSString * const kRemoveMemberURLString                     = @"teams/%@/removemember";
NSString * const KTeamPinURLString                          = @"teams/%@/pin/%@";
NSString * const KTeamUnpinURLString                        = @"teams/%@/unpin/%@";
NSString * const kTeamRefreshURLString                      = @"teams/%@/refresh";
NSString * const kTeamInviteURLString                       = @"teams/%@/invite";
NSString * const KTeamReadByInviteCodePath                  = @"teams/readbyinvitecode";
NSString * const KTeamJoinByInviteCodepath                  = @"teams/joinbyinvitecode";
NSString * const KTeamJoinBySignCodepath                    = @"teams/%@/joinbysigncode";
NSString * const kTeamReadThirdsPath                        = @"teams/thirds";
NSString * const KTeamSyncOneFromThirdPath                  = @"teams/syncone";

//Invitation
NSString * const kInvitationURLString                       = @"invitations";
NSString * const kDeleteInvitationURLString                 = @"invitations/%@";

//subscribe team
NSString * const kSubscribeURLString                        = @"subscribe";
NSString * const kUnSubscribeURLString                      = @"unsubscribe";

//room
NSString * const kTopicURLString                            = @"rooms";
NSString * const KRoomPrefsURLString                        = @"rooms/%@/prefs";
NSString * const KRoomRemoveMemberURLString                 = @"rooms/%@/removemember";

//message
NSString * const kSendMessageURLString                      = @"messages";
NSString * const kSearchURLString                           = @"messages/search";
NSString * const kForwardMessageURLString                   = @"messages/reposts";
NSString * const kClearMessageURLString                     = @"messages/clear";
NSString * const kAtMeMessageURLString                      = @"messages/mentions";
NSString * const kMessagesTagsURLString                     = @"messages/tags";
NSString * const kMessageReceiptURLString                   = @"messages/%@/receipt";

//common
NSString * const kAddTopicMemberURLString                   = @"batchinvite";
NSString * const kPreferencesURLString                      = @"preferences";


//favorite
NSString * const kFavoritesURLString                        = @"favorites";
NSString * const kFavoritesSearchURLString                  = @"favorites/search";
NSString * const kFavoritesForwardURLString                 = @"favorites/reposts";
NSString * const kFavoritesDeleteURLString                  = @"favorites/%@";

//tag
NSString * const kTagsURLString                             = @"tags";

//notification
NSString * const kNotificationsURLString                    = @"notifications";
NSString * const kNotificationUpdateURLString               = @"notifications/%@";
NSString * const kNotificationRemoveURLString               = @"notifications/%@";

//status
NSString * const kCheckStatusURLString                      = @"state";

//story
NSString * const kStoryCreateURLString                      = @"stories";
NSString * const kStoryReadURLString                        = @"stories";
NSString * const kStoryReadOneURLString                     = @"stories/%@";
NSString * const kStoryJoinURLString                        = @"stories/%@/join";
NSString * const kStoryLeaveURLString                       = @"stories/%@/leave";
NSString * const kStoryRemoveURLString                      = @"stories/%@";
NSString * const kStoryUpdateURLString                      = @"stories/%@";
NSString * const kDiscoverLinkURLString                     = @"discover/urlmeta";

//Activity
NSString * const kTeamActivityPath                          = @"activities";
NSString * const kTeamActivityRemovePath                    = @"activities/%@";

//TPS(Talk Push Service)
NSString * const kTPSUserRegisterPath                       = @"users/register";
NSString * const KTPSMessageBroadcastHistoryPath            = @"messages/broadcasthistory";

@implementation TBHTTPSessionManager

+ (TBHTTPSessionManager *)sharedManager {
    static TBHTTPSessionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TBHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
    });

    return sharedManager;
}

- (id)initWithBaseURL:(NSURL *)url {
    DDLogVerbose(@"URL_ROOT: %@", url);
    self = [super initWithBaseURL:url];
    if (self) {
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [JSONResponseSerializerWithData serializerWithReadingOptions:NSJSONReadingAllowFragments];

        // for oauth token
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
        DDLogVerbose(@"token: %@", accessToken);
        if (accessToken) {
            [self.requestSerializer setValue:[NSString stringWithFormat:@"aid %@", accessToken] forHTTPHeaderField:@"Authorization"];
        }
        if ([TBUtility systemLanguageIsChinese]) {
            [self.requestSerializer setValue:@"zh" forHTTPHeaderField:@"X-Language"];
        } else {
            [self.requestSerializer setValue:@"en" forHTTPHeaderField:@"X-Language"];
        }
        [self.requestSerializer setValue:@"ios" forHTTPHeaderField:@"X-Client-Type"];
        NSString *UUIDString = [TBUtility deviceUUID];
        [self.requestSerializer setValue:UUIDString forHTTPHeaderField:@"X-Client-Id"];
        
        #warning For GA
        if (isGAVersion) {
            [self.requestSerializer setValue:@"ga" forHTTPHeaderField:@"X-Release-Version"];
        }
    }
    return self;
}

#pragma mark - cancel

- (void)cancelAllHTTPOperationsWithPath:(NSString *)path {
    AFURLSessionManager * yourSessionManager = [TBHTTPSessionManager sharedManager];
    [[yourSessionManager session] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        [self cancelTasksInArray:dataTasks withPath:path andMethod:nil];
        [self cancelTasksInArray:uploadTasks withPath:path andMethod:nil];
        [self cancelTasksInArray:downloadTasks withPath:path andMethod:nil];
    }];
}

- (void)cancelAllHTTPOperationsWithPath:(NSString *)path forMethod:(NSString *)method {
    AFURLSessionManager * yourSessionManager = [TBHTTPSessionManager sharedManager];
    [[yourSessionManager session] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        [self cancelTasksInArray:dataTasks withPath:path andMethod:method];
        [self cancelTasksInArray:uploadTasks withPath:path andMethod:method];
        [self cancelTasksInArray:downloadTasks withPath:path andMethod:method];
    }];
}

- (void)cancelAllHTTPOperationsWithPath:(NSString *)path exceptMethod:(NSString *)method {
    AFURLSessionManager * yourSessionManager = [TBHTTPSessionManager sharedManager];
    [[yourSessionManager session] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        [self cancelTasksInArray:dataTasks withPath:path exceptMethod:method];
        [self cancelTasksInArray:uploadTasks withPath:path exceptMethod:method];
        [self cancelTasksInArray:downloadTasks withPath:path exceptMethod:method];
    }];
}

- (void)cancelTasksInArray:(NSArray *)tasksArray withPath:(NSString *)path andMethod:(NSString *)method {
    for (NSURLSessionTask *task in tasksArray) {
        NSRange range = [[[[task currentRequest]URL] absoluteString] rangeOfString:path];
        if (range.location != NSNotFound) {
            if (method) {
                if ([task.originalRequest.HTTPMethod isEqualToString:method]) {
                    [task cancel];
                }
            } else {
                [task cancel];
            }
        }
    }
}

- (void)cancelTasksInArray:(NSArray *)tasksArray withPath:(NSString *)path exceptMethod:(NSString *)method {
    for (NSURLSessionTask *task in tasksArray) {
        NSRange range = [[[[task currentRequest]URL] absoluteString] rangeOfString:path];
        if (range.location != NSNotFound) {
            if (![task.originalRequest.HTTPMethod isEqualToString:method]) {
                [task cancel];
            }
        }
    }
}

#pragma mark - specific request
//subscribe or unSubscribe for accepting message about team
- (void)subscribeForAcceptTeamMessageWithIsSubscribe:(BOOL)isSubscribe {
    NSString *subscribeURLString;
    if (isSubscribe) {
        subscribeURLString = kSubscribeURLString;
    } else {
        subscribeURLString = kUnSubscribeURLString;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentTeamID = [defaults valueForKey:kCurrentTeamID];
    if (currentTeamID) {
        NSString *urlPath = [NSString stringWithFormat:@"%@/%@/%@",kTeamURLString,currentTeamID,subscribeURLString];
        [[TBHTTPSessionManager sharedManager] POST:urlPath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if (isSubscribe) {
                DDLogVerbose(@"subscribe Team Succeed: %@", responseObject);
                NSString *teamChannelId = responseObject[@"channelId"];
                if (teamChannelId) {
                    [[NSUserDefaults standardUserDefaults] setObject:teamChannelId forKey:KTPSCurrentTeamChannelId];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[TBPushSessionManager sharedManager] fetchBroadcastHistoryMessage];
                }
            } else {
                DDLogVerbose(@"unSubscribe Team Succeed: %@", responseObject);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DDLogError(@"Error: %@", [error localizedRecoverySuggestion]);
        }];
    }
}

- (void)sendDeviceToPushServer:(NSString *)deviceToken {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = deviceToken;
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    params[@"buildNumber"] = buildNumber;
    
    [[TBHTTPSessionManager sharedManager] POST:kDeviceTokenURLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogVerbose(@"deviceToken uploaded successfully");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"deviceToken failed to upload: %@", error);
    }];
}

- (void)updateBadgeNumber {
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:kBadgeURLString
      parameters:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             DDLogVerbose(@"badge count %@", responseObject);

             NSInteger badgeValue = [responseObject[@"badge"] integerValue];

             [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeValue];
             [[NSNotificationCenter defaultCenter] postNotificationName:kBadgeNumberKey object:@(badgeValue)];
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             DDLogError(@"Error: %@", error);
         }];
}

@end
