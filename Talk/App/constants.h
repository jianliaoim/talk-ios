
#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

#define kBgQueue         dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0UL)

#define EMPTY_STRING(a)  (!a || [[a stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])

#define APP_NAME         [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"]

#define CACHE_POLICY     (SDWebImageRetryFailed | SDWebImageLowPriority | SDWebImageProgressiveDownload | SDWebImageRefreshCached)

#define kScreenWidth     [UIScreen mainScreen].bounds.size.width
#define kScreenHeight    [UIScreen mainScreen].bounds.size.height
#define kNavigationBarHeight  64
#define iOS8             ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

static BOOL const isGAVersion = NO;

static CGFloat const TBDefaultCellHeight = 60.0;

typedef NS_ENUM(NSInteger, DeviceScreenHeight) {
    iPhone4 = 480,
    iphone5 = 568,
    iPhone6 = 667,
    iphone6Plus = 736,
};

typedef NS_ENUM(NSInteger, TBCellType) {
    TBCellTypeTop,
    TBCellTypeCommon,
    TBCellTypeBottom,
    TBCellTypeOnly
};

//User related key
#define kCurrentUserKey                         @"userID"
#define kCurrentUserName                        @"userName"
#define kCurrentUserAvatar                      @"userAvatar"
#define kCurrentUserEmail                       @"userEmail"
#define kCurrentUserPhone                       @"userPhone"
#define kCurrentUserWechat                      @"userWechat"
#define kBadgeNumberKey                         @"badgeCount"
#define kDeviceToken                            @"deviceToken"
#define kAccessToken                            @"accessToken"

//TPS(Talk Push Service)
#define KTPSUSerId                              @"tpsUserId"
#define KTPSUserChannelId                       @"tpsUserChannelId"
#define KTPSCurrentTeamChannelId                @"tpsCurrentTeamChannelId"
#define kFetchBroadcastHistorySuccess           @"FetchBroadcastHistorySuccess"                  

#pragma mark - Preference settting for NSUserDefaults
//preference settting for NSUserDefaults
#define kCloseRemoteNotification                @"closeRemoteNotification"
#define kEmailNOtification                      @"emialNotification"
#define kNotifyOnRelated                        @"notifyOnRelated"
#define kMuteWhenWebOnline                      @"muteWhenWebOnline"
#define kPushOnWorkTime                         @"pushOnWorkTime"

#define kDidLoginKey                            @"didLogin"
#define kDidLogoutKey                           @"didLogout"
#define kCurrentTeamID                          @"currentTeamID"
#define kCurrentTeamName                        @"currentTeamName"

#define kDidSelectTeamKey                       @"didSelectTeam"
#define kBeginFetchTeamData                     @"beginFetchTeamData"
#define kFailedFetchTeamData                    @"failedFetchTeamData"
#define kTeamDataStored                         @"teamDataStored"
#define kUpdateOtherTeamUnread                  @"updateOtherTeamUnread"

#define kDidFinishLaunchKey                     @"didFinishLaunch"
#define kPersonalInfoChangeNotification         @"personalInfoChanged"
#define kMemberInfoChangeNotification           @"memberInfoChange"
#define kAvatarChangeNotification               @"avatarChangeNotification"

#define KCancelAt                               @"cancelAt"
#define KSelectedAtMember                       @"selectedAtMember"
#define kTapOtherMedia                          @"TapOtherMedia"
#define kUserHaveLogin                          @"userHaveLogin"
#define kHaveReadMessage                        @"kHaveReadMessage"

#define kSendMessageSucceedNotification         @"sendMessageSucceed"
#define kSendingMessageNotification             @"sendingMessage"
#define kSendMessageFailedNotification          @"sendMessageFailed"

#define kResendMessageNotification              @"resendMessage"
#define kResendImageNotification                @"resendImage"
#define kResendVoiceNotification                @"resendVoice"

#define kLeaveRoomSucceedNotification           @"leaveRoomSucceed"
#define kLeftPrivateRoomNotification            @"leftPrivateRoom"
#define kArchiveRoomSucceedNotification         @"archiveRoomSucceed"
#define kResumeRoomSucceedNotification          @"resumeRoomSucceed"
#define kDeleteRoomSucceedNotification          @"deleteRoomSucceed"
#define kTeamCreateNotification                 @"teamCreate"
#define kEditTopicInfoNotification              @"editTopicSuccess"
#define kEditTopicColorNotification             @"editTopicColorSuccess"
#define kUpdateRoomMuteNotification             @"updateRoomMuteSuccess"

#define kEditTeamNameNotification               @"editTeamNameSuccess"
#define kEditTeamNonJoinableNotification        @"editNonJoinableSuccess"
#define kPinTeamColorNotification               @"pinTeamColorSuccess"
#define kUnpinTeamColorNotification             @"unpinTeamColorSuccess"
#define kMuteNotification                       @"muteSuccess"
#define kHideNotification                       @"hideSuccess"
#define kNotInCurrentTeamNotification           @"notInCurrentTeam"
#define kNewTeamSavedNotification               @"newTeamSaved"

#define kEditStoryNotification                  @"editStory"
#define kLeaveStorySucceedNotification          @"leaveStorySucceed"
#define kCreateStorySucceedNotification         @"createStorySucceed"
#define kRemoveStorySucceedNotification         @"removeStorySucceed"

#define kEditMemberGroupInfoNotification        @"editMemberGroupSucceed"

#define kRefreshRecentData                      @"refreshRecentData"
#define kDraftUpdate                            @"chatDraftUpdate"
#define kContactRecommendDisplayed              @"contactRecommendDisplayed"

#pragma mark - Tag
//tag
#define kAddTagSucceedNotification              @"addTagSucceedNotification"
#define kEditTagSuccessNotification             @"editTagSuccessNotification"

#pragma mark - Socket event
//Socket event
#define kSocketTeamJoin                         @"socketTeamJoin"
#define kSocketTeamLeave                        @"socketTeamLeave"
#define kSocketTeamUpdate                       @"socketTeamUpdate"

#define kSocketInvitationCreate                 @"socketInvitationCreate"
#define kSocketInvitationRemove                 @"socketInvitationRemove"

#define kSocketRoomCreate                       @"socketRoomCreate"
#define kSocketRoomCreateBySelf                 @"socketRoomCreateBySelf"
#define kSocketRoomJoin                         @"socketRoomJoin"
#define kSocketRoomLeave                        @"socketRoomLeave"
#define kSocketRoomUpdate                       @"socketRoomUpdate"
#define kSocketRoomArchive                      @"socketRoomArchive"
#define kSocketRoomRemove                       @"socketRoomRemove "

#define kSocketUserUpdate                       @"socketUserUpdate"

#define kSocketMessageCreate                    @"socketMessageCreate"
#define kSocketMessageUnread                    @"socketMessageUnread"
#define kSocketMessageUpdate                    @"socketMessageUpdate"
#define kSocketMessageRemove                    @"socketMessageRemove"

#define kSocketFileCreate                       @"socketFileCreate"
#define kSocketFileUpdate                       @"socketFileUpdate"

#define kSocketMemberUpdate                     @"socketMemberUpdate"

#define kSocketIntegrationCreate                @"socketIntegrationCreate"
#define kSocketIntegrationUpdate                @"socketIntegrationUpdate"
#define kSocketIntegrationRemove                @"socketIntegrationRemove"
#define kSocketIntegrationGetToken              @"socketIntegrationGetToken"

#define kSocketNotificationCreate               @"socketNotificationCreate"
#define kSocketNotificationUpdate               @"socketNotificationUpdate"
#define kSocketNotificationDelete               @"socketNotificationDelete"

#define kSocketStoryCreate                      @"socketStoryCreate"
#define kSocketStoryUpdate                      @"socketStoryUpdate"

#define kSocketActivityCreate                   @"socketActivityCreate"
#define kSocketActivityUpdate                   @"socketActivityUpdate"
#define kSocketActivityRemove                   @"socketActivityRemove"

#pragma mark - wechat related
#define kGetWechatCodeNotification              @"Notification_GetWechatCode"

#pragma mark - app groups
//app groups
static NSString * const kTalkGroupID = @"group.com.jianliao.Talk";
static NSString * const kShareImage = @"shareImage";
static NSString * const kShareURL = @"shareURL";
static NSString * const kshareText = @"shareText";

#pragma mark - share extension
//share extension
#define kShowShareViewNOtification              @"showShareViewNOtification"
#define kShareForRecentMessage                  @"shareForRecentMessage"
#define kShareForTopic                          @"shareForTopic"
#define kShareForMember                         @"shareForMemeber"
#define kIsSharingExtension                     @"isSharingExtension"

#pragma mark - team invite
//team invite
#define kTeamLinkInviteNotification             @"teamLinkInviteNotification"
#define kTeamCodeInviteNotification             @"teamCodeInviteNotification"
#define kTeamInviteIsCopyBySelf                 @"teamInviteIsCopyBySelf" 

#pragma mark - Search
//search
static NSString * const kSearchHistory = @"searchHistory";
static NSString * const KEnterChatForSearchMessage = @"enterChatForSearchMessage";
static NSString * const kHistory = @"History";
static NSString * const kMembers = @"Members";
static NSString * const kTopics = @"Topics";
static NSString * const kConversations = @"Conversations";
static NSString * const kPrivateChat = @"Private Conversation";

#pragma mark - Language
//set in-app language
#define kLanguageDidChangeNotification          @"languageDidChangeNotification"

#pragma mark - 容联云通信
//容联云通信
#define kRemindFreeCall                         @"remindFreeCall"
#define kYTXAccountSid                          @"替换成自己的 Sid"
#define kYTXAccountToken                        @"替换成自己的 Token"
#define KYTXSubAccountSid                       @"KYTXSubAccountSid"
#define kYTXSubAccountToken                     @"kYTXSubAccountToken"
#define kYTXCallSid                             @"kYTXCallSid"
#define kYTXShowPhoneNumber                     @"替换成自己的号码"
#ifdef DEBUG
#define kYTXAppId                               @"替换成自己的 AppId"
#else
#define kYTXAppId                               @"替换成自己的 AppId"
#endif

#pragma mark - message dispaly mode

static NSString * const kDisplayModeMessage = @"message";
static NSString * const kDisplayModeImage = @"image";
static NSString * const kDisplayModeSystem = @"system";
static NSString * const kDisplayModeIntegration = @"integration";
static NSString * const kDisplayModeWeibo = @"weibo";
static NSString * const kDisplayModeGithub = @"github";
static NSString * const kDisplayModeFile = @"file";
static NSString * const kDisplayModeRtf = @"rtf";
static NSString * const kDisplayModeSpeech = @"speech";
static NSString * const kDisplayModeQuote = @"quote";
static NSString * const kDisplayModeSnippet = @"snippet";

#pragma mark - message send

static NSString * const kAtRegularString = @"<$at|%@|@%@ $>";
static NSString * const kMessageBody = @"body";

#pragma mark - quote key

static NSString * const kQuoteId = @"_id";
static NSString * const kQuoteTitle = @"title";
static NSString * const kQuoteText = @"text";
static NSString * const kQuoteRedirectUrl = @"redirectUrl";
static NSString * const kQuoteCategory = @"category";
static NSString * const kQuoteThumbnailPicUrl = @"thumbnailPicUrl";
static NSString * const kQuoteImageUrl = @"imageUrl";
//quote catagory
static NSString * const kQuoteCategoryURL = @"url";

#pragma mark - file key

static NSString * const kFileCategory = @"fileCategory";
static NSString * const kFileKey = @"fileKey";
static NSString * const kFileName = @"fileName";
static NSString * const kFileSize = @"fileSize";
static NSString * const kFileType = @"fileType";
static NSString * const kImageHeight = @"imageHeight";
static NSString * const kImageWidth = @"imageWidth";
static NSString * const kFileThumbnailUrl = @"thumbnailUrl";
static NSString * const kFileDownloadUrl = @"downloadUrl";
static NSString * const kVoiceDuration = @"duration";
//file Category
static NSString * const kFileCategoryImage = @"image";

#pragma mark - snippet

static NSString * const kCodeType = @"codeType";

#pragma mark - highlightKey

static NSString *const kHighlightKeyBody = @"body";
static NSString *const kHighlightKeyAttachmentTitle = @"attachments.data.title";
static NSString *const kHighlightKeyAttachmentText = @"attachments.data.text";
static NSString *const kHighlightKeyfileName = @"attachments.data.fileName";

#pragma mark - Storyboard Name

static NSString * const kMainStoryboard = @"Main";
static NSString * const kSearchStoryboard = @"Search";
static NSString * const kShareStoryboard = @"Share";
static NSString * const kLoginStoryboard = @"Login";
static NSString * const kChatStoryboard = @"Chat";
static NSString * const kMeInfoStoryboard = @"MeInfo";
static NSString * const kAppSettingStoryboard = @"AppSetting";
static NSString * const kAddMemberMethodsStoryboard = @"AddMemberMethods";
static NSString * const kNewTopicStoryboard = @"NewTopic";
static NSString * const kItemsStoryboard = @"Items";
static NSString * const kTagsStoryboard = @"Tags";
static NSString * const kTeamActivityStoryBoard = @"TeamActivity";

#pragma mark - Remote notification

#define kEnterChatFromRemoteNotification  @"enterChatFromRemoteNotification"

static NSString *const kRemoteNotificationCategoryComment = @"COMMENT_CATEGORY";

static NSString *const kRemoteNotificationTeamId = @"extra._teamId";
static NSString *const kRemoteNotificationTargetId = @"extra._targetId";
static NSString *const kRemoteNotificationMessageType = @"extra.message_type";

static NSString *const kRemoteNotificationMessageTypeRoom = @"room";
static NSString *const kRemoteNotificationMessageTypeDirectMessage = @"dms";
static NSString *const kRemoteNotificationMessageTypeStory = @"story";

//Notification
static NSString * const kNotificationTypeStory = @"story";
static NSString * const kNotificationTypeRoom = @"room";
static NSString * const kNotificationTypeDMS = @"dms";

//Story
static NSString * const kStoryCategoryTopic = @"topic";
static NSString * const kStoryCategoryFile = @"file";
static NSString * const kStoryCategoryLink = @"link";

//Shortcut
static NSString * const kShortcutShareSearch = @"com.jianliao.search";
static NSString * const kShortcutShareImage = @"com.jianliao.image";
static NSString * const kShortcutShareLink = @"com.jianliao.link";
static NSString * const kShortcutShareIdea = @"com.jianliao.idea";

#pragma mark -  Analytics

static NSString * const kAnalyticsLoginBeginTime = @"login begin time";
static NSString * const kAnalyticsCategoryLogin = @"login";
static NSString * const kAnalyticsCategoryRookie = @"rookie";
static NSString * const kAnalyticsCategoryTeam = @"team";
static NSString * const kAnalyticsCategorySwitchTeams = @"switch teams";
static NSString * const kAnalyticsCategoryPageElements = @"page elements";
static NSString * const kAnalyticsCategoryRetention = @"retention";

static NSString * const kAnalyticsActionLoginReady = @"login ready";
static NSString * const kAnalyticsActionLoginSuccess = @"login succ";
static NSString * const kAnalyticsActionLoginError = @"login error";
static NSString * const kAnalyticsActionRegisterReady = @"register ready";
static NSString * const kAnalyticsActionRegisterSuccess = @"register succ";
static NSString * const kAnalyticsActionRegisterError = @"register error";

static NSString * const kAnalyticsTimingLoginDuration = @"login duration";
static NSString * const kAnalyticsTimingRegisterDuration = @"register duration";

static NSString * const kAnalyticsActionEnterTeam = @"enter team";
static NSString * const kAnalyticsActionCreateTeam = @"create team";
static NSString * const kAnalyticsActionScanTeam = @"scan team";
static NSString * const kAnalyticsActionSyncTeam = @"sync team";

static NSString * const kAnalyticsActionShowStoryDetail = @"show story detail";

static NSString * const kAnalyticsActionAlive = @"alive";

static NSString * const kAnalyticsLabelFromStory = @"from story";
static NSString * const kAnalyticsLabelFromRoom = @"from room";
static NSString * const kAnalyticsLabelFromQuickSearch = @"from search";
static NSString * const kAnalyticsLabelFromRecentList= @"from recent list";
static NSString * const kAnalyticsLabelFromContact = @"from contact";

static NSString * const kAnalyticsLabelWithEmail = @"with email";
static NSString * const kAnalyticsLabelWithPhone = @"with phone";
static NSString * const kAnalyticsLabelWithTeambition = @"with teambition";

#pragma mark -  Tips && GuideView
static NSString * const kHasShowStoryGuideView = @"hasShowStoryGuideView";

static NSString * const kHasShowAddStoryTip = @"hasShowAddStoryTip";
static NSString * const kHasShowStoryDetailTip = @"hasShowStoryDetailTip";
static NSString * const kHasShowGroupTip = @"hasShowGroupTip";

