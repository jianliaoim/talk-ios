//
// Created by Shire on 9/18/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>

/**************URL Related *******/

//TPS (Talk push service) key and secret
extern NSString * const kTPSAppKey;
extern NSString * const kTPSAppSecret;
extern NSString * const kTPSBaseURLString;
extern NSString * const kTPSSocketURLString;

//base url
extern NSString * const kAPIBaseURLString;

//file upload
extern NSString * const kUploadURLString;

//privacy
extern NSString * const kPrivacyURLString;

//account
extern NSString * const kAccountBaseURLString;

/**************URL Path Related *******/

//device token
extern NSString * const kDeviceTokenURLString;

//acoount
extern NSString * const kEmailSignUpPath;
extern NSString * const kEmailSignInPath;
extern NSString * const kEmailSendVerifyCodePath;
extern NSString * const kEmailCheckVerifyCodePath;
extern NSString * const KEmailResetPasswordpath;
extern NSString * const kEmailBindPath;
extern NSString * const kEmailForceBindPath;
extern NSString * const kEmailChangePath;

extern NSString * const kMobileSignUpPath;
extern NSString * const kMobileSignInPath;
extern NSString * const kMobileSendVerifyCodePath;
extern NSString * const kMobileCheckVerifyCodePath;
extern NSString * const KMobileResetPasswordpath;
extern NSString * const kMobileBindPath;
extern NSString * const kMobileUnbindPath;
extern NSString * const kMobileForceBindPath;
extern NSString * const kMobileChangePath;

extern NSString * const kLoginWithTeambitionPath;
extern NSString * const kBindTeambitionPath;
extern NSString * const kForceBindTeambitionPath;
extern NSString * const kUnbindTeambitionPath;
extern NSString * const kCheckAllBindAccountsPath;

//user
extern NSString * const kGetUserInfoWithPhoneURLString;
extern NSString * const kLogoutURLString;
extern NSString * const kMeInfoURLString;
extern NSString * const kSyncMeInfoURLString;
extern NSString * const kBadgeURLString;
extern NSString * const kUserSubscribeString;

//group
extern NSString * const kGetGroupsURLString;
extern NSString * const kCreateGroupURLString;
extern NSString * const kUpdateGroupURLString;
extern NSString * const kRemoveGroupURLString;

//team
extern NSString * const kTeamURLString;
extern NSString * const kTeamInviteURLString;
extern NSString * const kGetRoomsURLString;
extern NSString * const kGetMembersURLString;
extern NSString * const kLeftMembersURLString;
extern NSString * const kMemberUpdateURLString;
extern NSString * const kRemoveMemberURLString;
extern NSString * const KTeamPinURLString;
extern NSString * const KTeamUnpinURLString;
extern NSString * const kTeamRefreshURLString;
extern NSString * const KTeamReadByInviteCodePath;
extern NSString * const KTeamJoinByInviteCodepath;
extern NSString * const KTeamJoinBySignCodepath;
extern NSString * const kTeamReadThirdsPath;
extern NSString * const KTeamSyncOneFromThirdPath;

//Invitation
extern NSString * const kInvitationURLString;
extern NSString * const kDeleteInvitationURLString;

//room
extern NSString * const kTopicURLString;
extern NSString * const KRoomPrefsURLString;
extern NSString * const KRoomRemoveMemberURLString;

//message
extern NSString * const kSendMessageURLString;
extern NSString * const kClearMessageURLString;
extern NSString * const kForwardMessageURLString;
extern NSString * const kSearchURLString;
extern NSString * const kAtMeMessageURLString;
extern NSString * const kMessagesTagsURLString;
extern NSString * const kMessageReceiptURLString;

//common
extern NSString * const kAddTopicMemberURLString;
extern NSString * const kPreferencesURLString;

//favorite
extern NSString * const kFavoritesURLString;
extern NSString * const kFavoritesSearchURLString;
extern NSString * const kFavoritesForwardURLString;
extern NSString * const kFavoritesDeleteURLString;

//tag
extern NSString * const kTagsURLString;

//Feedback Path
NSString * const kFeedbackPath;

//容联云通信
extern NSString * const kYTXCallURLString;
extern NSString * const kYTXCancelCallURLString;
extern NSString * const kYTXCreateConferenceURLString;
extern NSString * const kYTXCancelConferenceURLString;
extern NSString * const kYTXInviteMemberURLString;

//notification
extern NSString * const kNotificationsURLString;
extern NSString * const kNotificationUpdateURLString;
extern NSString * const kNotificationRemoveURLString;

//status
extern NSString * const kCheckStatusURLString;

//story
extern NSString * const kStoryCreateURLString;
extern NSString * const kStoryReadURLString;
extern NSString * const kStoryReadOneURLString;
extern NSString * const kStoryJoinURLString;
extern NSString * const kStoryLeaveURLString;
extern NSString * const kStoryRemoveURLString;
extern NSString * const kStoryUpdateURLString;
extern NSString * const kDiscoverLinkURLString;

// Image valid
extern NSString * const KImageValidURLString;

//Activity
extern NSString * const kTeamActivityPath;
extern NSString * const kTeamActivityRemovePath;

//TPS(Talk Push Service)
extern NSString * const kTPSUserRegisterPath;
extern NSString * const KTPSMessageBroadcastHistoryPath;

typedef void(^tSuccessBlock)(NSURLSessionDataTask *task, id responseObject);
typedef void(^tFailureBlock)(NSURLSessionDataTask *task, NSError *error);

@interface TBHTTPSessionManager : AFHTTPSessionManager

+ (TBHTTPSessionManager *)sharedManager;

- (void)cancelAllHTTPOperationsWithPath:(NSString *)path;
- (void)cancelAllHTTPOperationsWithPath:(NSString *)path forMethod:(NSString *)method;
- (void)cancelAllHTTPOperationsWithPath:(NSString *)path exceptMethod:(NSString *)method;

- (void)sendDeviceToPushServer:(NSString *)deviceToken;
- (void)updateBadgeNumber;
//subscribe or unSubscribe for accepting message about team
-(void)subscribeForAcceptTeamMessageWithIsSubscribe:(BOOL)isSubscribe;

@end
