//
//  AppDelegate.m
//  Talk
//
//  Created by Shire on 9/17/14.
//  Copyright (c) 2014 jiaoliao. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkActivityLogger.h"
#import "MobClick.h"
#import "JLRoutes.h"
#import "constants.h"
#import "TBHTTPSessionManager.h"
#import "SSKeychain.h"
#import "CoreData+MagicalRecord.h"
#import <SDWebImage/SDWebImageManager.h>
#import "TBSocketManager.h"
#import "UIColor+TBColor.h"
#import "WelcomeView.h"
#import "MOMessage.h"
#import "SVProgressHUD.h"
#import "MORoom.h"
#import "MOTeam.h"
#import "TBTeam.h"
#import "TBSearchBar.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "WXApi.h"
#import "RootViewController.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <Mixpanel/Mixpanel.h>
#import "TBUtility.h"
#import "JLGuideViewController.h"

static NSString *const kRetationTime = @"retationTime";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    #ifdef DEBUG
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    #else
    [self setAnalytics];
    #endif
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [self setSDWebImage];
    [self setupDB];
    [self registerRoutes];
    
    _presentTransition = [[TBPresentTransition alloc]init];
    _allNewTeamIdArray = [NSMutableArray array];
    [self setCustomAppearance];
    
    //judge have login or not ,then go to diff viewController
    BOOL haveLogined = [[NSUserDefaults standardUserDefaults] boolForKey:kUserHaveLogin];
    UINavigationController *loginNavigationController;
    [self.window makeKeyAndVisible];
    if (haveLogined) {
        [self setGroupDeafaults];
        [self openRemoteNotification];
        if (launchOptions) {
            NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
            [self handleRemoteNotificaitons:userInfo];
        }
    } else {
        loginNavigationController = [[UIStoryboard storyboardWithName:kLoginStoryboard bundle:nil] instantiateInitialViewController];
        [self.window.rootViewController presentViewController:loginNavigationController animated:NO completion:nil];
        __weak AppDelegate *weakSelf = self;
        [self setWelcomeView:^{
        }];
    }
    
    return YES;
}

- (void)setAnalytics {
    //Crashlytics
    [Fabric with:@[[Crashlytics class]]];
    //Mixpanel
    //[Mixpanel sharedInstanceWithToken:kMixpanelToken];
    
    [Mixpanel sharedInstance].showNetworkActivityIndicator = NO;
    self.timedEvents = [NSMutableDictionary dictionary];
}

- (void)setSDWebImage {
    [SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Talk" forHTTPHeaderField:@"Talk"];
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    SDWebImageManager.sharedManager.cacheKeyFilter = ^(NSURL *url) {
        if (url.scheme && url.host && url.path) {
            url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
            return [url absoluteString];
        } else {
            return [url absoluteString];
        }
    };
    [SDWebImageManager setIsDecodeGIFImage:NO];
}

- (void)setCustomAppearance {
    // Customize navigation bar stye
    [[UINavigationBar appearance] setBarTintColor:[UIColor jl_redColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UITextField appearanceWhenContainedIn:[TBSearchBar class], nil] setTintColor:[UIColor whiteColor]];
    [[UITextField appearanceWhenContainedIn:[TBSearchBar class], nil] setTextColor:[UIColor whiteColor]];
}

- (void)setGroupDeafaults {
    NSUserDefaults *standarddeafaults = [NSUserDefaults standardUserDefaults];
    NSUserDefaults *groupDeafaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
    [groupDeafaults setBool:YES forKey:kUserHaveLogin];
    [groupDeafaults setObject:[standarddeafaults objectForKey:kAccessToken] forKey:kAccessToken];
    [groupDeafaults setObject:[standarddeafaults objectForKey:kCurrentTeamID] forKey:kCurrentTeamID];
    [groupDeafaults setObject:[standarddeafaults objectForKey:kCurrentUserKey] forKey:kCurrentUserKey];
    [groupDeafaults synchronize];
}

- (void)setWelcomeView:(void(^)(void))complection {
    WelcomeView *launchView = (WelcomeView *)[[[NSBundle mainBundle]loadNibNamed:@"WelcomeView" owner:self options:nil] objectAtIndex:0];
    launchView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.window addSubview:launchView];
    [self.window bringSubviewToFront:launchView];
    [self.window addConstraint:[NSLayoutConstraint constraintWithItem:launchView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.window attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.window addConstraint:[NSLayoutConstraint constraintWithItem:launchView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.window attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.window addConstraint:[NSLayoutConstraint constraintWithItem:launchView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.window attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.window addConstraint:[NSLayoutConstraint constraintWithItem:launchView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.window attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self.window layoutIfNeeded];
    
    launchView.imageVerticalSpace.constant +=50;
    [UIView animateWithDuration:1.2 animations:^{
        [launchView layoutIfNeeded];
        launchView.imageView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            launchView.imageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
            launchView.alpha = 0;
        } completion:^(BOOL finished) {
            [launchView removeFromSuperview];
            complection();
        }];
    }];
}

- (BOOL)isVersionUpdate {
    NSString *appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSInteger appBuildNumber = [appBuildString intValue];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger currentBuildNumber = [[defaults valueForKey:@"build"] intValue];
    
    if (currentBuildNumber < appBuildNumber) {
        [defaults setValue:appBuildString forKey:@"build"];
        [defaults synchronize];
        return YES;
    } else {
        return NO;
    }
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    [self handleShortcutItem:shortcutItem];
    completionHandler(true);
}

- (void)handleShortcutItem:(UIApplicationShortcutItem *)shortcutItem {
    if ([shortcutItem.type isEqualToString:kShortcutShareSearch]) {
        UINavigationController *searchNavigationController = [[UIStoryboard storyboardWithName:kSearchStoryboard bundle:nil] instantiateInitialViewController];
        searchNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        searchNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.window.rootViewController presentViewController:searchNavigationController animated:YES completion:nil];
    } else if ([shortcutItem.type isEqualToString:kShortcutShareImage]) {
        [(RootViewController *)self.window.rootViewController addImage];
    } else if ([shortcutItem.type isEqualToString:kShortcutShareIdea]) {
        [(RootViewController *)self.window.rootViewController addIdea];
    } else if ([shortcutItem.type isEqualToString:kShortcutShareLink]) {
        [(RootViewController *)self.window.rootViewController addLink];
    }
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    NSString *idString;
    if ([userActivity.activityType isEqualToString:CSSearchableItemActionType]) {
        idString = userActivity.userInfo[@"kCSSearchableItemActivityIdentifier"];
    } else {
        return false;
    }
    
    MOUser *user = [MOUser findFirstWithId:idString];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShareForMember object:user];
    
    return true;
}
    
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if ([TBSocketManager sharedManager].webSocket.readyState != SR_CLOSED) {
         [[TBSocketManager sharedManager] closeSocket];
    }
    self.isEnterBackGroud = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    self.isEnterBackGroud = NO;
    [self sendRetationAnalytic];
}

- (void)sendRetationAnalytic {
    NSDate *retationDate = [[NSUserDefaults  standardUserDefaults] objectForKey:kRetationTime];
    if (retationDate) {
        NSTimeInterval  interval = [[NSDate date] timeIntervalSinceDate:retationDate];
        if (interval > 60*60) {
            [self sendAliveEvent];
        }
    } else {
        [self sendAliveEvent];
    }
}

- (void)sendAliveEvent {
    [[NSUserDefaults  standardUserDefaults] setObject:[NSDate date] forKey:kRetationTime];
    [[NSUserDefaults  standardUserDefaults] synchronize];
    [TBUtility sendAnalyticsEventWithCategory:kAnalyticsCategoryRetention action:kAnalyticsActionAlive label:@"" value:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   
    // Open Socket
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kUserHaveLogin]) {
        if ([TBSocketManager sharedManager].webSocket.readyState != SR_OPEN && [TBSocketManager sharedManager].webSocket.readyState != SR_CONNECTING){
            [[TBSocketManager sharedManager] openSocket];
        }
    }

    // Check for inviteCode in paste
    [self checkForInviteCode];
}

- (void)checkForInviteCode {
    BOOL copyBySelf = [[NSUserDefaults standardUserDefaults] boolForKey:kTeamInviteIsCopyBySelf];
    if (copyBySelf) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTeamInviteIsCopyBySelf];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[UIPasteboard generalPasteboard] setString:@""];
        return;
    }
    
    NSString *pasteString = [UIPasteboard generalPasteboard].string;
    if (pasteString) {
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\🎈(.*?)\\🎈" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *array = [regex matchesInString:pasteString options:0 range:NSMakeRange(0, [pasteString length])];
        if (array.count > 0) {
            NSTextCheckingResult *b = array.firstObject;
            NSString *regularStr = [pasteString substringWithRange:b.range];
            NSInteger length = regularStr.length;
            if (length > 2 && [regularStr hasPrefix:@"🎈"] && [regularStr hasSuffix:@"🎈"]) {
                NSString *inviteCode = [regularStr stringByReplacingOccurrencesOfString:@"🎈" withString:@""];
                [self jumpToTeamWithInviteCode:inviteCode];
                [[UIPasteboard generalPasteboard] setString:@""];
            }
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   [MagicalRecord cleanUp];
}

#pragma mark - Wechat & Open From Third AppLication

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [JLRoutes routeURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    return  [JLRoutes routeURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {

    return  [JLRoutes routeURL:url];
}

-(void)onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *temp = (SendAuthResp*)resp;
        if (temp.errCode == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_GetWechatCode" object:temp.code userInfo:nil];
        }
    }
}

#pragma mark - url scheme

- (void)registerRoutes {
#if DEBUG
    [JLRoutes setVerboseLoggingEnabled:YES];
#endif
 //add route for team invite
    [JLRoutes addRoute:@"/team_invite" handler:^BOOL(NSDictionary *parameters) {
        DDLogVerbose(@"team_invite: %@", parameters);
        NSString *inviteCode = parameters[@"inviteCode"];
        [self jumpToTeamWithInviteCode:inviteCode];
        return YES;
    }];
    
    //add route for today extension
    [JLRoutes addRoute:@"/createTopicFromToday" handler:^BOOL(NSDictionary *parameters) {
        [(RootViewController *)self.window.rootViewController addChatWithChatType:TBContactTypeMember];
        return YES;
    }];
    
    [JLRoutes addRoute:@"/createPrivateChatFromToday" handler:^BOOL(NSDictionary *parameters) {
        [(RootViewController *)self.window.rootViewController addChatWithChatType:TBContactTypeTopic];
        return YES;
    }];
    
    [JLRoutes addRoute:@"/createImageFromToday" handler:^BOOL(NSDictionary *parameters) {
        [(RootViewController *)self.window.rootViewController addImage];
        return YES;
    }];
    
    [JLRoutes addRoute:@"/createIdeaFromToday" handler:^BOOL(NSDictionary *parameters) {
        [(RootViewController *)self.window.rootViewController addIdea];
        return YES;
    }];
    
    [JLRoutes addRoute:@"/createLinkFromToday" handler:^BOOL(NSDictionary *parameters) {
        [(RootViewController *)self.window.rootViewController addLink];
        return YES;
    }];
    
}

//jump to invited team
- (void)jumpToTeamWithInviteCode:(NSString *)inviteCode {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserHaveLogin]) {
        if (inviteCode.length > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTeamLinkInviteNotification object:inviteCode];
        }
    } else {
        self.inviteCode = inviteCode;
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Please login first", @"Please login first")];
    }
}

#pragma mark - Push notifications

-(void)openRemoteNotification {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kCloseRemoteNotification]) {
        return;
    }
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    DDLogDebug(@"deviceTokenInfo:%@",deviceToken);

    // save token
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:token forKey:kDeviceToken];
    [defaults synchronize];

    // send token to server
    [[TBHTTPSessionManager sharedManager] sendDeviceToPushServer:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogError(@"apns -> error:\n %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        return;
    }
    [self handleRemoteNotificaitons:userInfo];
}

- (void)handleRemoteNotificaitons:(NSDictionary *)userInfo {
    self.remoteNotificationObject = userInfo;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:kEnterChatFromRemoteNotification object:userInfo];
}

#pragma mark - Core Data

- (void)setupDB {
    DDLogDebug([self dbStore]);
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:[self dbStore]];
    
    BOOL shouldUpdate = [self isVersionUpdate];
    if (shouldUpdate) {
        [self cleanAndResetupDB];
    }
}

- (NSString *)dbStore {
    NSString *bundleID = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    return [NSString stringWithFormat:@"%@.sqlite", bundleID];
}

- (void)cleanAndResetupDB {
    NSString *dbStore = [self dbStore];
    NSError *error = nil;
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:dbStore];
    NSString *storePathDirectory = storeURL.path.stringByDeletingLastPathComponent;
    NSURL *storeDirectoryURL = [NSURL fileURLWithPath:storePathDirectory];
    [MagicalRecord cleanUp];
    
    if([[NSFileManager defaultManager] removeItemAtURL:storeDirectoryURL error:&error]){
         DDLogDebug(@"Success deleting %@", dbStore);
        [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:[self dbStore]];
    } else{
        DDLogDebug(@"An error has occurred while deleting %@", dbStore);
        DDLogDebug(@"Error description: %@", error.description);
    }
}

#pragma mark - Getters

- (AMPopTip *)popTip {
    if (!_popTip) {
         _popTip = [AMPopTip popTip];
        _popTip.shouldDismissOnTap = YES;
        _popTip.edgeMargin = 5;
        _popTip.offset = 10;
        _popTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        _popTip.arrowSize = CGSizeMake(10, 6);
        _popTip.radius = 5;
        _popTip.layer.shadowColor = [UIColor blackColor].CGColor;
        _popTip.layer.shadowOpacity = 0.2;
        _popTip.layer.shadowOffset = CGSizeMake(0, 1);
        _popTip.entranceAnimation = AMPopTipEntranceAnimationNone;
        _popTip.actionAnimation = AMPopTipActionAnimationFloat;
        _popTip.popoverColor = [UIColor jl_redColor];
    }
    return _popTip;
}

- (AMPopTip *)getPopTipWithContainerView:(UIView *)containerView {
    AMPopTip *popTip = self.popTip;
    UIView *backgroudView = [[UIView alloc]initWithFrame:containerView.frame];
    backgroudView.backgroundColor = [UIColor clearColor];
    [containerView addSubview:backgroudView];
    popTip.tapHandler = ^{
        [backgroudView removeFromSuperview];
    };
    popTip.dismissHandler = ^{
        [backgroudView removeFromSuperview];
    };
    return popTip;
}

@end
