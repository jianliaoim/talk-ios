//
//  RootViewController.m
//  Talk
//
//  Created by Shire on 9/18/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import "RootViewController.h"
#import "constants.h"
#import "SSKeychain.h"
#import "TBHTTPSessionManager.h"
#import "CoreData+MagicalRecord.h"
#import "TBMessage.h"
#import "SVProgressHUD.h"
#import "TBUtility.h"
#import "TBSocketManager.h"
#import "Reachability.h"
#import "ShareToTableViewController.h"
#import "JoinTeamAfterScanQRCodeViewController.h"
#import "RecentMessagesViewController.h"
#import "TeamActivityTableViewController.h"
#import "MoreTableViewController.h"

#import "TBTeam.h"
#import "MOUser.h"
#import "MORoom.h"
#import "MOTeam.h"
#import "TBUser.h"
#import "TBRoom.h"
#import "TBInvitation.h"
#import "MOInvitation.h"
#import "TBNotification.h"
#import "MONotification.h"
#import "TBStory.h"
#import "MOStory.h"
#import "TBGroup.h"
#import "MOGroup.h"
#import "MOMessage.h"

#import <FastEasyMapping/FastEasyMapping.h>
#import "MappingProvider.h"
#import "TeamLoadingView.h"
#import "NSString+Emoji.h"
#import "AddMenuView.h"
#import "AddTopicMemberViewController.h"
#import "TWPhotoPickerController.h"
#import "UIImage+Orientation.h"
#import "MembersViewController.h"
#import "TopicsViewController.h"
#import "JLStoryEditorViewController.h"
#import "TBMessage.h"
#import "JLSpotlightHelper.h"
#import "UIColor+TBColor.h"
#import "UITabBar+JLTabbar.h"
#import "NSString+TBUtilities.h"
#import "ContactRecommendViewController.h"

#import "Talk-Swift.h"
#import "TBTag.h"
#import "TBPushSessionManager.h"

static NSTimeInterval kSyncTimeInterval  = 1 * 3600;

@interface RootViewController () <AddMenuViewDelegate, AddTopicMemberViewControllerDelegate, JLStoryEditorViewControllerDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, copy) NSString *teamID;
@property (strong, nonatomic) NSDate *teamSyncMinDate;
@property (strong, nonatomic) NSArray *messagesArray;
@property (nonatomic) BOOL needRefreshData;
@property (nonatomic) NSNumber *badgeNumber;
@property (nonatomic) BOOL isFetchingData;
@property (nonatomic, strong) Reachability *reachability;
@property (strong, nonatomic) TeamLoadingView *teamLoadingview;

@property (strong, nonatomic) UIImageView *addButtonImage;
@property (strong, nonatomic) AddMenuView *addMenuView;

@property (copy, nonatomic) NSString *storyCategory;
@property (strong, nonatomic) NSMutableArray *memberIDArray;
@property (strong, nonatomic) NSDictionary *storyData;

@end

@implementation RootViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTabbar];
    [self initAddButton];
    [self setupNetworkReachability];
    [self setupSoundPlayer];
    [self registerNotifications];
    [self checkApplicationState];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getters

- (TeamLoadingView *)teamLoadingview {
    if (!_teamLoadingview) {
        NSArray *nibView =  [[NSBundle mainBundle] loadNibNamed:@"TeamLoadingView"owner:self options:nil];
        _teamLoadingview = [nibView objectAtIndex:0];
        _teamLoadingview.frame = [[UIScreen mainScreen] bounds];
    }
    return _teamLoadingview;
}

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addButton.frame = CGRectMake(self.tabBar.bounds.size.width/2 - self.tabBar.bounds.size.width/10, 0, self.tabBar.bounds.size.width/5, self.tabBar.bounds.size.height);
        _addButton.backgroundColor = [UIColor clearColor];
        [_addButton addTarget:self action:@selector(tapAddButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

- (UIImageView *)addButtonImage {
    if (!_addButtonImage) {
        _addButtonImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.tabBar.bounds.size.width/2 - 18, self.tabBar.bounds.size.height/2 - 18, 36, 36)];
        [_addButtonImage setImage:[UIImage imageNamed:@"AddStoryItem"]];
    }
    return _addButtonImage;
}

- (AddMenuView *)addMenuView {
    if (!_addMenuView) {
        _addMenuView = [[AddMenuView alloc] initWithFrame:self.view.frame];
        _addMenuView.delegate = self;
    }
    return _addMenuView;
}

#pragma mark - Private Methods

- (void)setupTabbar {
    [self.tabBar setTintColor:[UIColor whiteColor]];
}

- (void)initAddButton {
    [self.tabBar addSubview:self.addButtonImage];
    [self.tabBar addSubview:self.addButton];
}

- (void)setupNetworkReachability {
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    NetworkStatus netStatus = [self.reachability currentReachabilityStatus];
    if (netStatus == NotReachable) {
        [TBUtility currentAppDelegate].netWorkConnect = NO;
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserHaveLogin]) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NetWork connect fault,Please check!", @"NetWork connect fault,Please check!")];
        }
    } else {
        [TBUtility currentAppDelegate].netWorkConnect = YES;
    }
}

- (void)setupSoundPlayer {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[JLSoundPlayer sharedSoundPlayer] setSoundWithName:@"bubble" andExtension:@"wav"];
    });
}

- (void)registerNotifications {
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectTeam:) name:kDidSelectTeamKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:kDidLogoutKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:app];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshRecentData) name:kRefreshRecentData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teamLinkInviteAction:) name:kTeamLinkInviteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterChatFromRemoteNotification:) name:kEnterChatFromRemoteNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapRecentButton) name:kShareForTopic object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapRecentButton) name:kShareForMember object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTabbarViewController) name:kLanguageDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reCalculateOtherTeamUnread) name:kTeamDataStored object:nil];
}

- (void)checkApplicationState {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserHaveLogin]) {
        return;
    }
    // Check access token existence
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    if (!accessToken) {
        UINavigationController *loginVC = (UINavigationController *) [[UIStoryboard storyboardWithName:kLoginStoryboard bundle:nil] instantiateInitialViewController];
        [self presentViewController:loginVC animated:YES completion:nil];
    } else {
        // Check if team is selected
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.teamID = [defaults valueForKey:kCurrentTeamID];
        if ([TBUtility currentAppDelegate].remoteNotificationObject) {
            self.teamID = [TBUtility currentAppDelegate].remoteNotificationObject[kRemoteNotificationTeamId];
        }
        if (!self.teamID) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserHaveLogin];
                [[NSUserDefaults standardUserDefaults] synchronize];
                UINavigationController *loginVC = (UINavigationController *) [[UIStoryboard storyboardWithName:kLoginStoryboard bundle:nil] instantiateInitialViewController];
                [self presentViewController:loginVC animated:YES completion:^{
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"No Team", @"No Team")];
                }];
            });
        } else {
            MOTeam *selectedTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:self.teamID];
            TBTeam *team = [MTLManagedObjectAdapter modelOfClass:[TBTeam class] fromManagedObject:selectedTeam error:NULL];
            if (team) {
                [self startTeamLoadingWithTeam:team isViewDidLoad:YES];
            }
            [self fetchTeamDataForChangeTeam:NO];
        }
    }
}

- (void)fetchTeamDataForChangeTeam:(BOOL)isChangeTeam {
    [self fetchTeamDataWithIsRefreshRecent:NO ForChangeTeam:isChangeTeam];
}

- (void)refreshRecentData {
    [self fetchTeamDataWithIsRefreshRecent:YES ForChangeTeam:NO];
}

- (void)fetchTeamDataWithIsRefreshRecent:(BOOL)isRefresh ForChangeTeam:(BOOL)isChangeTeam {
    BOOL haveLogined = [[NSUserDefaults standardUserDefaults] boolForKey:kUserHaveLogin];
    if (!haveLogined || self.isFetchingData) {
        return;
    }
    self.isFetchingData = YES;
    if (!isRefresh) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kBeginFetchTeamData object:nil];
    }
    
    // if team has sync,just get BroadcastHistoryMessage,or Sync team
    MOTeam *team = [MOTeam MR_findFirstByAttribute:@"id" withValue:self.teamID];
    if (team.minDate) {
        NSTimeInterval syncInterVal = [[NSDate date] timeIntervalSinceDate:team.minDate];
        if (syncInterVal < kSyncTimeInterval) {
            [self fetchBroadcastHistoryMessageForChangeTeam:isChangeTeam];
        } else {
            [MOMessage removeOneTeamMessagesWithTeamId:team.id];
            [self updateAllData];
        }
    } else {
        [self updateAllData];
    }
}

- (void)fetchBroadcastHistoryMessageForChangeTeam:(BOOL)isChangeTeam {
    self.isFetchingData = NO;
    [self stopTeamLoading];
    if ([TBSocketManager sharedManager].webSocket.readyState != SR_OPEN) {
        [[TBSocketManager sharedManager] openSocket];
    } else {
        if (isChangeTeam) {
            //Subscribe for accepting message about team
            [[TBHTTPSessionManager sharedManager] subscribeForAcceptTeamMessageWithIsSubscribe:YES];
        } else {
            [[TBPushSessionManager sharedManager] fetchBroadcastHistoryMessage];
        }
    }
}

// update unread for other team and update current team data
-(void)updateAllData {
    self.teamSyncMinDate = [NSDate date];

    dispatch_group_t group = dispatch_group_create();
    // all teams
    [self updateAllTeamsInDispatchGroup:group];
    
    //fetch current team related data
    if (self.teamID) {
        //Subscribe for accepting message for current team
        [[TBHTTPSessionManager sharedManager]subscribeForAcceptTeamMessageWithIsSubscribe:YES];
        
        NSString *dataTeamId = [self.teamID mutableCopy];
        //fetch rooms
        __block NSArray *roomsArray;
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_group_enter(group);
            TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
            [manager GET:[NSString stringWithFormat:kGetRoomsURLString,dataTeamId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                roomsArray = (NSArray *)responseObject;
                dispatch_group_leave(group);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                dispatch_group_leave(group);
                self.isFetchingData = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:kFailedFetchTeamData object:nil];
                [self stopTeamLoading];
                [self dealForTokenInvialidWithError:error];
            }];
        });
        
        //fetch  members
        __block NSArray *membersArray;
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_group_enter(group);
            TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
            [manager GET:[NSString stringWithFormat:kGetMembersURLString,dataTeamId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                membersArray = (NSArray *)responseObject;
                dispatch_group_leave(group);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                dispatch_group_leave(group);
            }];
        });
        
        //fetch left members
        __block NSArray *leftMembersArray;
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_group_enter(group);
            TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
            [manager GET:[NSString stringWithFormat:kLeftMembersURLString, dataTeamId] parameters:Nil success:^(NSURLSessionDataTask *task, NSArray *responseObject) {
                dispatch_group_leave(group);
                leftMembersArray = responseObject;
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                dispatch_group_leave(group);
            }];
        });
        
        //fetch invitations members
        __block NSArray *invitationsArray;
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_group_enter(group);
            TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
            [manager GET:kInvitationURLString parameters:@{@"_teamId": dataTeamId} success:^(NSURLSessionDataTask *task, NSArray *responseObject) {
                dispatch_group_leave(group);
                invitationsArray = responseObject;
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                dispatch_group_leave(group);
            }];
        });
        
        
        //fetch all group
        __block NSArray *groupsArray;
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_group_enter(group);
            TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
            [manager GET:[NSString stringWithFormat:kGetGroupsURLString, dataTeamId] parameters:Nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                dispatch_group_leave(group);
                groupsArray = responseObject;
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                dispatch_group_leave(group);
            }];
        });
        
        //fetch notifications
        __block NSArray *notificationsArray;
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_group_enter(group);
            TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
            NSDictionary *param = @{@"_teamId":dataTeamId};
            [manager GET:kNotificationsURLString parameters:param success:^(NSURLSessionDataTask *task, NSArray *responseObject) {
                dispatch_group_leave(group);
                notificationsArray = responseObject;
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                dispatch_group_leave(group);
            }];
        });
        
        //fetch tags
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_group_enter(group);
            NSDictionary *param = @{@"_teamId":dataTeamId};
            TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
            [manager GET:kTagsURLString parameters:param success:^(NSURLSessionDataTask *task, NSArray *responseObject) {
                dispatch_group_leave(group);
                [TBUtility currentAppDelegate].currentTeamTagArray = [MTLJSONAdapter modelsOfClass:[TBTag class] fromJSONArray:responseObject error:NULL];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                dispatch_group_leave(group);
            }];
        });
        
        dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (roomsArray) {
                DDLogDebug(@"****begin process data");
                [self processDataForTeam:dataTeamId withRooms:roomsArray members:membersArray leftMembersArray:leftMembersArray invitations:invitationsArray groups:groupsArray notifications:notificationsArray];
            }
        });
    }
}

- (void)updateAllTeamsInDispatchGroup:(dispatch_group_t)group {
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_enter(group);
        NSString *currentTeamId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
        TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
        [manager GET:kTeamURLString parameters:nil
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                     NSArray *oldMOTeamArray = [MOTeam MR_findAllInContext:localContext];
                     NSArray *newTBTeamArray = [MTLJSONAdapter modelsOfClass:[TBTeam class] fromJSONArray:responseObject error:NULL];
                     for (MOTeam *oldTeam in oldMOTeamArray) {
                         BOOL findInNew = NO;
                         for (TBTeam *team in newTBTeamArray) {
                             if ([team.id isEqualToString:oldTeam.id]) {
                                 team.minDate = oldTeam.minDate;
                                 findInNew = YES;
                                 break;
                             }
                         }
                         if (!findInNew) {
                             [oldTeam MR_deleteInContext:localContext];
                         }
                     }
                     [newTBTeamArray enumerateObjectsUsingBlock:^(TBTeam *team, NSUInteger idx, BOOL *stop) {
                         [MTLManagedObjectAdapter managedObjectFromModel:team insertingIntoContext:localContext error:NULL];
                         if ([team.id isEqualToString:currentTeamId]) {
                             self.badgeNumber = team.unread;
                         }
                     }];
                 } completion:^(BOOL success, NSError *error) {
                     dispatch_group_leave(group);
                 }];
             }
             failure:^(NSURLSessionDataTask *task, NSError *error) {
                 dispatch_group_leave(group);
                 self.isFetchingData = NO;
                 [[NSNotificationCenter defaultCenter] postNotificationName:kFailedFetchTeamData object:nil];
                 [self stopTeamLoading];
                 [TBUtility showMessageInError:error];
             }];
    });
}

- (void)reCalculateOtherTeamUnread {
    int allTeamUnread = 0;
    NSArray *allTeamArray = [MOTeam MR_findAll];
    [TBUtility currentAppDelegate].otherTeamHasMuteUnread = NO;
    for (MOTeam *tempTeam in allTeamArray) {
        if (![tempTeam.id isEqualToString:self.teamID]) {
            allTeamUnread +=tempTeam.unread.intValue;
            if (!([TBUtility currentAppDelegate].otherTeamHasMuteUnread) && tempTeam.hasUnreadValue) {
                [TBUtility currentAppDelegate].otherTeamHasMuteUnread = YES;
            }
        }
    }
    [TBUtility currentAppDelegate].otherTeamUnreadNo = allTeamUnread;
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateOtherTeamUnread object:nil];
    [self dealForNotInCurrentTeam];
}

- (void)dealForTokenInvialidWithError:(NSError *)error {
    NSDictionary *errorInfo = [TBUtility errorInfoDictionaryInError:error];
    if ([errorInfo[@"code"] intValue] == 220) {
        [self didLogout:nil];
        if (errorInfo[@"message"]) {
            [SVProgressHUD showErrorWithStatus:errorInfo[@"message"]];
        }
    } else {
        [self dealForNotInCurrentTeam];
        if (error.localizedRecoverySuggestion) {
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }
}

- (void)dealForNotInCurrentTeam {
    MOTeam *currentTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:self.teamID];
    if (!currentTeam) {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kCurrentTeamID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSUserDefaults *groupDeafaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
        [groupDeafaults setValue:nil forKey:kCurrentTeamID];
        [groupDeafaults synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotInCurrentTeamNotification object:nil];
    }
}

- (void)processDataForTeam:(NSString *)teamId
                 withRooms:(NSArray *)roomArray
                   members:(NSArray *)memberArray
          leftMembersArray:(NSArray *)leftMembersArray
               invitations:(NSArray *)invitationArray
                    groups:(NSArray *)groupsArray
             notifications:(NSArray *)notificationArray {
    NSString *currentteamId = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    if (![currentteamId isEqualToString:teamId]) {
        return;
    }
    
    CFTimeInterval before = CFAbsoluteTimeGetCurrent();
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        // Get current team data
        MOTeam *moTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:currentteamId inContext:localContext];
        moTeam.minDate = self.teamSyncMinDate;
        
        /***** Process topics data *****/
        NSArray *newMORoomArray = [FEMManagedObjectDeserializer collectionFromRepresentation:roomArray mapping:[MappingProvider roomMapping] context:localContext];
        for (MORoom *tempMORoom in newMORoomArray) {
            [moTeam addRoomsObject:tempMORoom];
        }
        NSPredicate *deleteFilter = [NSPredicate predicateWithFormat:@"teams.id = nil"];
        [MORoom MR_deleteAllMatchingPredicate:deleteFilter inContext:localContext];
        
        /***** Process users data *****/
        NSPredicate *deleteUserFilter = [NSPredicate predicateWithFormat:@"teams.id = nil"];
        [MOUser MR_deleteAllMatchingPredicate:deleteUserFilter inContext:localContext];
        NSArray *MOUserArray = [FEMManagedObjectDeserializer collectionFromRepresentation:memberArray mapping:[MappingProvider userMapping] context:localContext];
        for (MOUser *tempMOUser in MOUserArray) {
            tempMOUser.isQuitValue = NO;
            [moTeam addUsersObject:tempMOUser];
        }
        
        /***** Left process users data *****/
        if (leftMembersArray) {
            NSArray *MOLeftUserArray = [FEMManagedObjectDeserializer collectionFromRepresentation:leftMembersArray mapping:[MappingProvider userMapping] context:localContext];
            for (MOUser *tempMOUser in MOLeftUserArray) {
                tempMOUser.isQuitValue = YES;
                [moTeam addUsersObject:tempMOUser];
            }
        }
        
        /***** Process invitation data *****/
        NSArray *tbInviationArray = [MTLJSONAdapter modelsOfClass:[TBInvitation class] fromJSONArray:invitationArray error:NULL];
        [tbInviationArray enumerateObjectsUsingBlock:^(TBInvitation *obj, NSUInteger idx, BOOL *stop) {
            MOInvitation *moInvitation = [MTLManagedObjectAdapter managedObjectFromModel:obj insertingIntoContext:localContext error:NULL];
            DDLogDebug(@"moInvitation.name:%@",moInvitation.name);
        }];
        
        /***** Process group data *****/
        NSArray *currentGroups = [MOGroup MR_findAllInContext:localContext];
        for (MOGroup *group in currentGroups) {
            [group MR_deleteInContext:localContext];
        }
        NSArray *tbGroupArray = [MTLJSONAdapter modelsOfClass:[TBGroup class] fromJSONArray:groupsArray error:NULL];
        [tbGroupArray enumerateObjectsUsingBlock:^(TBGroup *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MOGroup *moGroup = [MTLManagedObjectAdapter managedObjectFromModel:obj insertingIntoContext:localContext error:NULL];
            DDLogDebug(@"moGroup.name:%@", moGroup.name);
        }];
    } completion:^(BOOL success, NSError *error) {
        self.isFetchingData = NO;
        if (!error) {
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                // Process notifications
                [self processNewRecentNotifications:notificationArray inContext:localContext];
            } completion:^(BOOL success, NSError *error) {
                CFTimeInterval after = CFAbsoluteTimeGetCurrent() - before;
                DDLogDebug(@"successfully saved team takes: %f", after);
                [self stopTeamLoading];
                [SVProgressHUD dismiss];
                [self allDataSaved];
            }];
        } else if (error) {
            [self stopTeamLoading];
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Fetch data failed", @"Fetch data failed")];
            [[NSNotificationCenter defaultCenter] postNotificationName:kFailedFetchTeamData object:nil];
        }
    }];
}

- (void)processNewRecentNotifications:(NSArray *)notificationArray  inContext:(NSManagedObjectContext *)localContext {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sendStatus = %d", sendStatusFailed];
    NSArray *localFailedNotification = [MONotification MR_findAllWithPredicate:predicate inContext:localContext];
    NSArray *tbNotificationArray = [MTLJSONAdapter modelsOfClass:[TBNotification class] fromJSONArray:notificationArray error:nil];
    [tbNotificationArray enumerateObjectsUsingBlock:^(TBNotification *obj, NSUInteger idx, BOOL *stop) {
        BOOL isFailed = NO;
        for (MONotification *failedNotification in localFailedNotification) {
            if ([failedNotification.targetID isEqualToString:obj.targetID] && [failedNotification.updatedAt compare: obj.updatedAt] == NSOrderedDescending) {
                isFailed = YES;
                break;
            }
        }
        if (!isFailed) {
            MONotification *moNotification = [MTLManagedObjectAdapter managedObjectFromModel:obj insertingIntoContext:localContext error:NULL];
            if ([moNotification.type isEqualToString:kNotificationTypeStory]) {
                TBStory *tbStory = [MTLJSONAdapter modelOfClass:[TBStory class] fromJSONDictionary:moNotification.target error:nil];
                MOStory *moStory = [MTLManagedObjectAdapter managedObjectFromModel:tbStory insertingIntoContext:localContext error:nil];
                DDLogDebug(@"moStory.category:%@",moStory.category);
            }
            DDLogDebug(@"moNotification.text:%@",moNotification.text);
        }
    }];
}

- (void)allDataSaved {
    [self spotlightIndexing];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTeamDataStored object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBadgeNumberKey object:self.badgeNumber];
    if ([TBSocketManager sharedManager].webSocket.readyState != SR_OPEN) {
        [[TBSocketManager sharedManager] openSocket];
    }
    if ([TBUtility currentAppDelegate].remoteNotificationObject) {
        [self enterChatForMessageInfo:[TBUtility currentAppDelegate].remoteNotificationObject];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *teamContactRecommendKey = [NSString stringWithFormat:@"%@+%@", kContactRecommendDisplayed, self.teamID];
        NSInteger numOfTeamMember = [MOUser findAllInCurrentTeamWithContainRobot:NO].count;
        if (![[NSUserDefaults standardUserDefaults] boolForKey:teamContactRecommendKey] && numOfTeamMember <= 5) {
            ContactRecommendViewController *viewController = [ContactRecommendViewController new];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
            [self presentViewController:navigationController animated:YES completion:^{
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:teamContactRecommendKey];
            }];
        }
    });
}

- (void)startTeamLoadingWithTeam:(TBTeam *)team isViewDidLoad:(BOOL)isViewDidLoad {
    self.teamLoadingview.teamNameLabel.text = team.name;
    NSString *imageName = [team.name getTalkTeamImageName];
    self.teamLoadingview.teamNameImageView.image = [UIImage imageNamed:imageName];
    self.tabBar.hidden = YES;
    if ([TBUtility currentAppDelegate].remoteNotificationObject) {
        isViewDidLoad = YES;
    }
    if (isViewDidLoad) {
        [self.view addSubview:self.teamLoadingview];
    } else {
        UIWindow *topWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        [topWindow addSubview:self.teamLoadingview];
    }
    [self.teamLoadingview.loadingView startAnimation:NO];
}

- (void)stopTeamLoading {
    if (!self.teamLoadingview.loadingView.isSpinning) {
        return;
    }
    self.tabBar.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.teamLoadingview.alpha = 0;
        } completion:^(BOOL finished) {
            [self.teamLoadingview.loadingView stopAnimation:YES completion:nil];
            [self.teamLoadingview removeFromSuperview];
            self.teamLoadingview.alpha = 1.0;
        }];
    });
}

- (void)spotlightIndexing {
    [JLSpotlightHelper refreshIndexInCurrentTeam];
}

#pragma mark - Add


- (void)tapAddButton {
    [self showMenu];
}

- (void)showMenu {
    [[JLSoundPlayer sharedSoundPlayer] playSound];
    self.addButtonImage.hidden = YES;
    [self.view insertSubview:self.addMenuView belowSubview:self.tabBar];
    [self.view addSubview:self.addMenuView];
    self.addButton.selected = !self.addButton.selected;
}

- (void)hideMenu {
    [[JLSoundPlayer sharedSoundPlayer] playSound];
    [self.addMenuView removeAddMenu:^{
        self.addButtonImage.hidden = NO;
        self.addButton.selected = !self.addButton.selected;
    }];
}

- (void)addChatWithChatType:(TBContactType)type {
    ContactTableViewController *contactViewController = [[ContactTableViewController alloc] init];
    contactViewController.contactType = type;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:contactViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)addIdea {
    JLStoryEditorViewController *storyEditorViewController = [[JLStoryEditorViewController alloc] initWithStory:nil];
    storyEditorViewController.category = kStoryCategoryTopic;
    storyEditorViewController.delegate= self;
    UINavigationController *temNav = [[UINavigationController alloc] initWithRootViewController:storyEditorViewController];
    [self presentViewController:temNav animated:YES completion:nil];
}

- (void)addImage {
    //pick photo
    TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
    __weak TWPhotoPickerController *weakPhotoPicker = photoPicker;
    __weak RootViewController *weakSelf = self;
    photoPicker.cropBlock = ^(UIImage *image) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Uploading", @"Uploading")];
        [[TBFileSessionManager sharedManager] POST:kUploadURLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            [formData appendPartWithFileData:imageData name:@"file" fileName:NSLocalizedString(@"Share Image", @"Share Image") mimeType:[NSString stringWithFormat:@"image/%@",@"jpg"]];
        } success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
            DDLogDebug(@"JSON: %@", responseObject);
            weakSelf.storyData = responseObject;
            weakSelf.storyCategory = kStoryCategoryFile;
            [SVProgressHUD dismiss];
            [weakPhotoPicker dismissViewControllerAnimated:YES completion:^{
                [weakSelf addMemberToStory];
            }];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DDLogDebug(@"Error: %@", error);
            //tell recentMessageView fail to send a message
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        }];
    };
    [self presentViewController:photoPicker animated:YES completion:nil];
}

- (void)addLink {
    JLStoryEditorViewController *storyEditorViewController = [[JLStoryEditorViewController alloc] init];
    storyEditorViewController.category = kStoryCategoryLink;
    storyEditorViewController.delegate = self;
    UINavigationController *temNav = [[UINavigationController alloc] initWithRootViewController:storyEditorViewController];
    [self presentViewController:temNav animated:YES completion:nil];
}

- (void)addMemberToStory {
    UINavigationController *temNav = (UINavigationController *)[[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"addMemberToTopicNav"];
    [temNav setTransitioningDelegate:[TBUtility currentAppDelegate].presentTransition];
    AddTopicMemberViewController *tempVC = (AddTopicMemberViewController *)[temNav.viewControllers objectAtIndex:0];
    tempVC.isCreatingStory = YES;
    tempVC.delegate = self;
    MOUser *user = [MOUser currentUser];
    tempVC.currentRoomMembersArray = [NSMutableArray arrayWithArray:@[user]];
    [self presentViewController:temNav animated:YES completion:^{}];
}

#pragma mark - Notification Selector

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    if (curReach.currentReachabilityStatus == ReachableViaWiFi || curReach.currentReachabilityStatus ==
        ReachableViaWWAN) {
        if (![TBUtility currentAppDelegate].netWorkConnect) {
            [self refreshRecentData];
            [TBUtility currentAppDelegate].netWorkConnect = YES;
            if ([[NSUserDefaults standardUserDefaults]boolForKey:kUserHaveLogin]) {
                if ([TBSocketManager sharedManager].webSocket.readyState != SR_OPEN) {
                    [[TBSocketManager sharedManager] openSocket];
                }
            } else {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"NetWork connected", @"NetWork connected")];
            }
        }
    } else {
        if ([TBUtility currentAppDelegate].netWorkConnect) {
            [TBUtility currentAppDelegate].netWorkConnect = NO;
            if (![[NSUserDefaults standardUserDefaults] boolForKey:kUserHaveLogin]) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"NetWork connect fault,Please check!", @"NetWork connect fault,Please check!")];
            }
        }
    }
}

- (void)tapRecentButton {
    if (self.selectedIndex == 0) {
        UINavigationController *recentNavigation = self.viewControllers.firstObject;
        RecentMessagesViewController *recentMessagesViewController = recentNavigation.viewControllers.firstObject;
        [recentMessagesViewController.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        return;
    }
    [self setSelectedIndex:0];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)setTabbarViewController {
    UINavigationController *recentNavigation = self.viewControllers.firstObject;
    RecentMessagesViewController *recentMessagesViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([RecentMessagesViewController class])];
    [recentNavigation setViewControllers:@[recentMessagesViewController]];
    
    UINavigationController *membersNavigation = [self.viewControllers objectAtIndex:1];
    MembersViewController *membersViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([MembersViewController class])];
    [membersNavigation setViewControllers:@[membersViewController]];
    
    UINavigationController *teamActivityNavigation = [self.viewControllers objectAtIndex:3];
    MembersViewController *teamActivityViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TeamActivityTableViewController class])];
    [teamActivityNavigation setViewControllers:@[teamActivityViewController]];
    
    UINavigationController *moreNavigation = [self.viewControllers objectAtIndex:4];
    MembersViewController *moreViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([MoreTableViewController class])];
    [moreNavigation setViewControllers:@[moreViewController]];
}

- (void)tapMemberButton {
    if (self.selectedIndex == 1) {
        UINavigationController *membersNavigation = [self.viewControllers objectAtIndex:1];
        MembersViewController *membersViewController = membersNavigation.viewControllers.firstObject;
        [membersViewController.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        return;
    }
    [self setSelectedIndex:1];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)didSelectTeam:(NSNotification *)notification {
    //unSubscribe for accepting message about team
    [[TBHTTPSessionManager sharedManager] subscribeForAcceptTeamMessageWithIsSubscribe:NO];
    
    // store current team info to userDefaults
    TBTeam *team = notification.object;
    self.teamID = team.id;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.teamID forKey:kCurrentTeamID];
    [defaults setValue:team.name forKey:kCurrentTeamName];
    [defaults synchronize];
    NSUserDefaults *groupDeafaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
    [groupDeafaults setValue:self.teamID forKey:kCurrentTeamID];
    [groupDeafaults synchronize];
    
    // switch to first tab view
    [self tapRecentButton];
    [self.viewControllers enumerateObjectsUsingBlock:^(UINavigationController *nc, NSUInteger idx, BOOL *stop) {
        [nc popToRootViewControllerAnimated:NO];
    }];
    
    //loading
    [self startTeamLoadingWithTeam:team isViewDidLoad:NO];

    //fetch new selected  team data
    if ([TBUtility currentAppDelegate].isChangeTeam) {
        [TBUtility currentAppDelegate].isChangeTeam = NO;
        self.isFetchingData = NO;
        [self fetchTeamDataForChangeTeam:YES];
    }
}

- (void)didLogout:(NSNotification *)notification {
    [TBUtility currentAppDelegate].isLogout = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:kUserHaveLogin];
    [defaults synchronize];
    NSUserDefaults *groupDeafaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
    [groupDeafaults setBool:NO forKey:kUserHaveLogin];
    [groupDeafaults synchronize];
    
    UINavigationController *loginVC = (UINavigationController *) [[UIStoryboard storyboardWithName:kLoginStoryboard bundle:nil] instantiateInitialViewController];
    [loginVC setTransitioningDelegate:[TBUtility currentAppDelegate].presentTransition];
    [self presentViewController:loginVC animated:YES completion:nil];
}

- (void)enterForeground {
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.teamID = [defaults valueForKey:kCurrentTeamID];
    if (accessToken && self.teamID) {
        if (!self.isFetchingData) {
            [self refreshRecentData];
        }
    }
}

- (void)teamLinkInviteAction:(NSNotification *)notification {
    NSString *inviteCode = notification.object;
    NSDictionary *params = @{@"inviteCode": inviteCode};
    [[TBHTTPSessionManager sharedManager] GET:KTeamReadByInviteCodePath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *teamInfo = responseObject;
        if (teamInfo) {
            [self showJoinTeamWithInfo:teamInfo];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [TBUtility showMessageInError:error];
    }];
}

- (void)showJoinTeamWithInfo:(NSDictionary *)teamInfo {
    JoinTeamAfterScanQRCodeViewController *teamVC = [[UIStoryboard storyboardWithName:kLoginStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"JoinTeamAfterScanQRCodeViewController"];
    teamVC._id = teamInfo[@"_id"];
    teamVC.name = teamInfo[@"name"];
    teamVC.color = teamInfo[@"color"];
    teamVC.inviteCode = teamInfo[@"inviteCode"];
    teamVC.isInvite = YES;
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:teamVC];
    if (self.teamID) {
        [self.viewControllers enumerateObjectsUsingBlock:^(UINavigationController *navigationVC, NSUInteger idx, BOOL *stop) {
            if (navigationVC.presentedViewController) {
                [navigationVC dismissViewControllerAnimated:YES completion:nil];
            }
        }];
        [self presentViewController:navigationController animated:NO completion:nil];
    } else {
        [self.presentedViewController presentViewController:navigationController animated:NO completion:nil];
    }
}

- (void)enterChatFromRemoteNotification:(NSNotification *)notification {
    NSDictionary *messageInfo = notification.object;
    NSString *teamId = messageInfo[kRemoteNotificationTeamId];
    
    NSString *currentTeamId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    if ([teamId isEqualToString:currentTeamId]) {
        [self tapRecentButton];
        [self enterChatForMessageInfo:messageInfo];
    } else {
        MOTeam *moTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:teamId];
        if (moTeam) {
            [TBUtility currentAppDelegate].isChangeTeam = YES;
            TBTeam *tbTeam = [MTLManagedObjectAdapter modelOfClass:[TBTeam class] fromManagedObject:moTeam error:NULL];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeamKey object:tbTeam];
        }
    }
}

- (void)enterChatForMessageInfo:(NSDictionary *)messageInfo {
    NSString *teamId = messageInfo[kRemoteNotificationTeamId];
    NSString *targetId = messageInfo[kRemoteNotificationTargetId];
    NSString *messageType = messageInfo[kRemoteNotificationMessageType];
    
    [self setSelectedIndex:0];
    [self.viewControllers enumerateObjectsUsingBlock:^(UINavigationController *nc, NSUInteger idx, BOOL *stop) {
        [nc dismissViewControllerAnimated:NO completion:nil];
        [nc popToRootViewControllerAnimated:NO];
    }];
    
    UINavigationController *recentNav = [self.viewControllers objectAtIndex:0];
    RecentMessagesViewController *recentVC = (RecentMessagesViewController *)[recentNav.viewControllers objectAtIndex:0];
    if ([messageType isEqualToString:kRemoteNotificationMessageTypeDirectMessage]) {
        MOUser *targetUser = [MOUser findFirstWithId:targetId teamId:teamId];
        if (targetUser) {
            [recentVC enterChatWithMember:targetUser];
            [TBUtility currentAppDelegate].remoteNotificationObject = nil;
        }
    } else if ([messageType isEqualToString:kRemoteNotificationMessageTypeRoom]) {
        NSPredicate *roomFilter = [NSPredicate predicateWithFormat:@"id = %@ AND teams.id = %@", targetId, teamId];
        MORoom *targetRoom = [MORoom MR_findFirstWithPredicate:roomFilter];
        if (targetRoom) {
            [recentVC enterChatWithRoom:targetRoom];
            [TBUtility currentAppDelegate].remoteNotificationObject = nil;
        }
    } else if ([messageType isEqualToString:kRemoteNotificationMessageTypeStory]) {
        //handle story notification
        NSPredicate *userFilter = [NSPredicate predicateWithFormat:@"id = %@ AND teamID = %@", targetId, teamId];
        MOStory *targetStory = [MOStory MR_findFirstWithPredicate:userFilter];
        if (targetStory) {
            [recentVC enterChatWithStory:targetStory];
            [TBUtility currentAppDelegate].remoteNotificationObject = nil;
        }
    }
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (self.addButton.selected) {
        [self hideMenu];
    }
}

#pragma mark - AddMenuViewDelegate

- (void)onTapCancel {
    [self hideMenu];
}

- (void)onTapButtonAtIndex:(NSInteger)index {
    [self hideMenu];
    switch (index) {
        case 0: {
            [self addChatWithChatType:TBContactTypeMember];
            break;
        }
        case 1: {
            [self addChatWithChatType:TBContactTypeTopic];
            break;
        }
        case 2:
            [self addIdea];
            break;
        case 3: {
            
            [self addImage];
            break;
        }
        case 4:
            [self addLink];
            break;
        default:
            break;
    }
}

#pragma mark - AddTopicMemberViewControllerDelegate

-(void)addMemberForNewTopicWith:(NSMutableArray *)tbMemeberArray {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.teamID = [defaults valueForKey:kCurrentTeamID];
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    NSDictionary *param = @{
                            @"_teamId":self.teamID,
                            @"category":self.storyCategory,
                            @"data":self.storyData,
                            @"_memberIds":tbMemeberArray
                            };
    [manager POST:kStoryCreateURLString parameters:param success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            MOStory *tempMOStory = [MOStory MR_findFirstByAttribute:@"id" withValue:responseObject[@"_id"] inContext:localContext];
            if (!tempMOStory) {
                TBStory *tempTBStory = [MTLJSONAdapter modelOfClass:[TBStory class] fromJSONDictionary:responseObject error:nil];
                tempMOStory = [MTLManagedObjectAdapter managedObjectFromModel:tempTBStory insertingIntoContext:localContext error:nil];
            }
        } completion:^(BOOL success, NSError *error) {
            MOStory *tempMOStory = [MOStory MR_findFirstByAttribute:@"id" withValue:responseObject[@"_id"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kCreateStorySucceedNotification object:tempMOStory];
            [self tapRecentButton];
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

#pragma mark - JLStoryEditorViewControllerDelegate

- (void)hasCreateStoryWithCategory:(NSString *)category StoryData:(NSDictionary *)storyData{
    self.storyCategory = category;
    self.storyData = [storyData copy];
    [self addMemberToStory];
};

@end
