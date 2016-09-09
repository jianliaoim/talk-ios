//
//  AppDelegate.h
//  Talk
//
//  Created by Shire on 9/17/14.
//  Copyright (c) 2014 jiaoliao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBPresentTransition.h"
#import "constants.h"
#import "MORoom.h"
#import "MOStory.h"
#import "WXApi.h"
#import "ChatViewController.h"
#import <AMPopTip/AMPopTip.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate , WXApiDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ChatViewController *currentChatViewController;
@property (strong, nonatomic) AMPopTip *popTip;

@property (strong, nonatomic) MORoom *currentRoom;      //current inter room ,it is nil if talk one-one
@property (strong, nonatomic) MOStory *currentStory;
@property (strong, nonatomic) NSString *inviteCode;
@property (strong, nonatomic) TBPresentTransition *presentTransition;    //custom VC animator
@property (strong, nonatomic) NSMutableArray *allNewTeamIdArray;         // all new team id
@property (strong, nonatomic) NSDictionary *remoteNotificationObject;
@property (strong, nonatomic) NSMutableDictionary *timedEvents;
@property (strong, nonatomic) NSArray *currentTeamTagArray;

@property (nonatomic) BOOL isChangeTeam;
@property (nonatomic) BOOL isLogout;
@property (nonatomic) BOOL netWorkConnect;
@property (nonatomic) BOOL isEnterBackGroud;
@property (nonatomic) int  otherTeamUnreadNo;
@property (nonatomic) BOOL otherTeamHasMuteUnread;

@property (nonatomic) BOOL isFetchingBroadcastHistory;

- (void)cleanAndResetupDB;
- (void)openRemoteNotification;
- (BOOL)isVersionUpdate;
- (AMPopTip *)getPopTipWithContainerView:(UIView *)containerView;
@end

