//
//  RecentMessagesViewController.m
//  Talk
//
//  Created by Shire on 10/22/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <NSDate+TimeAgo/NSDate+TimeAgo.h>
#import "CoreData+MagicalRecord.h"
#import "SVProgressHUD.h"
#import "UIImage+ImageEffects.h"
#import "UIView+TBSnapshotView.h"

#import "NSDate+TBUtilities.h"
#import "UIColor+TBColor.h"
#import "TBUtility.h"
#import "constants.h"
#import "TBHTTPSessionManager.h"

#import "ChatViewController.h"
#import "RecentMessagesViewController.h"
#import "AddTeamMembersViewController.h"
#import "TBRecentCell.h"
#import "ChangeTeamViewController.h"
#import "TBSnoozeRevealAnimator.h"

#import "TBQuote.h"
#import "TBMessage.h"
#import "TBRoom.h"
#import "MOMessage.h"
#import "MOUser.h"
#import "MORoom.h"
#import "MOTeam.h"
#import "MOHidenMessage.h"
#import "MONotification.h"
#import "TBNotification.h"
#import "TBStory.h"
#import "MOStory.h"
#import "MODraft.h"

#import "TBSocketManager.h"
#import "UIActionSheet+SHActionSheetBlocks.h"
#import "MeInfoViewController.h"
#import "AddTopicMemberViewController.h"
#import "ChooseTeamViewController.h"
#import "NSString+Emoji.h"
#import "TBUser.h"
#import "TBSearchBar.h"

#import "AddMemberMethodsTableViewController.h"
#import "MessageSendEngine.h"
#import <MGSwipeTableCell/MGSwipeTableCell.h>
#import <MGSwipeTableCell/MGSwipeButton.h>

#import "Reachability.h"
#import "ReachabilityView.h"
#import <Masonry/Masonry.h>
#import "TBMemberInfoView.h"
#import "Talk-Swift.h"
#import "CallingViewController.h"
#import "MJRefresh.h"
#import "Talk-Swift.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "RootViewController.h"
#import "NotificationSettingTableViewController.h"
#import "JLWebOnlineView.h"
#import "MeTableViewController.h"

static NSTimeInterval webOnlineInterval = 60;

@interface RecentMessagesViewController ()<MGSwipeTableCellDelegate,UIViewControllerTransitioningDelegate,UISearchBarDelegate, UINavigationControllerDelegate, UIViewControllerPreviewingDelegate> {
    BOOL isChinese;
    BOOL shouldCancel;
}
//placeholder
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UIButton *goToGeneralBtn;

@property (strong, nonatomic) TBSnoozeRevealAnimator *snoozeRevealAnimator;
@property (strong, nonatomic) UIImageView *dotView;
@property (strong, nonatomic) NSMutableArray *notificationArray;
@property (strong, nonatomic) NSMutableArray *pinedNotificationArray;
@property (strong, nonatomic) NSString *language;
@property (nonatomic) BOOL isAnimating;
@property (nonatomic) BOOL isEnteringChatVC;
@property (nonatomic) NSUInteger totalUnread;

//internet reachability
@property (nonatomic) Reachability *internetReachability;
@property (strong, nonatomic) ReachabilityView *reachabilityView;
//remind
@property (nonatomic, weak) TBMemberInfoView *remindFreeCallView;
//load
@property (nonatomic) BOOL hasLoadedAll;
@property (nonatomic, copy) NSDate *maxUpdatedDate;
//status
@property (strong, nonatomic) JLWebOnlineView *webOnlineView;
@property (strong, nonatomic) NSTimer *webOnlineTimer;

@end

static NSString *CellIdentifier = @"TBRecentCell";
#define kTopSapce    11
#define kDuration    0.5

@implementation RecentMessagesViewController

#pragma mark - View-lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;
    
    //animation
    self.snoozeRevealAnimator = [TBSnoozeRevealAnimator new];
    //common init
    [self commonInit];
    [self fetchLocalData];
    //add placeholder
    [self addPlacerHolder];
    //add 3d touch
    [self setup3DTouch];
    
    [self setupWebOnlineTimer];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID] == nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotInCurrentTeamNotification object:nil];
        return;
    }
}

- (void)setup3DTouch {
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            [self registerForPreviewingWithDelegate:self sourceView:self.view];
        }
    }
}

- (void)setupWebOnlineTimer {
    self.webOnlineTimer = [NSTimer timerWithTimeInterval:webOnlineInterval target:self selector:@selector(checkWebOnlineOrNot) userInfo:nil repeats:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    [self setShouldCancel:NO];
    [self setWebOnlineViewTitle];
}

- (void)setWebOnlineViewTitle {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kMuteWhenWebOnline]) {
        self.webOnlineView.notificationStatusImageView.image = [UIImage imageNamed:@"icon-online-stop"];
    } else {
        self.webOnlineView.notificationStatusImageView.image = [UIImage imageNamed:@"icon-online-start"];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AMPopTip *popTip = [TBUtility currentAppDelegate].popTip;
    if (popTip.isVisible && !popTip.isAnimating) {
        [UIView animateWithDuration:(popTip.actionAnimationIn / 2) delay:popTip.actionDelayIn options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction) animations:^{
            popTip.transform = CGAffineTransformMakeTranslation(0, popTip.actionFloatOffset/2);
        } completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setShouldCancel:YES];
}

-(void)viewDidDisappear:(BOOL)animated {
    self.isEnteringChatVC = NO;
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getter

- (JLWebOnlineView *)webOnlineView {
    if (_webOnlineView == nil) {
        _webOnlineView = [[JLWebOnlineView alloc]init];
        _webOnlineView.onlineLabel.text = NSLocalizedString(@"Web online", @"Web online");
        [_webOnlineView.tapButton addTarget:self action:@selector(goToNotificationSetting:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _webOnlineView;
}

#pragma mark - IBActions

- (IBAction)gToGeneral:(id)sender {
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    NSPredicate *generalTopicFilter = [NSPredicate predicateWithFormat:@"isQuit = NO AND teams.id = %@ AND isGeneral = YES", currentTeamID];
    MORoom *generalRoom = [MORoom MR_findFirstWithPredicate:generalTopicFilter];
    
    ChatViewController *tempChatVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    tempChatVC.refreshWhenViewDidLoad = YES;
    tempChatVC.roomType = ChatRoomTypeForRoom;
    [TBUtility currentAppDelegate].currentRoom = generalRoom;
    [tempChatVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:tempChatVC animated:YES];
}

- (void)goToNotificationSetting:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Web online", @"Web online") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    BOOL mute = [[NSUserDefaults standardUserDefaults] boolForKey:kMuteWhenWebOnline];
    NSString *muteTitle;
    if (mute) {
        muteTitle = NSLocalizedString(@"Unmute phone notification", @"Unmute phone notification");
    } else {
        muteTitle = NSLocalizedString(@"Mute phone notification", @"Mute phone notification");
    }
    UIAlertAction *muteAction = [UIAlertAction actionWithTitle:muteTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self muteWhenWebOnline];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:muteAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    alertController.view.tintColor = [UIColor blackColor];
}

- (void)muteWhenWebOnline {
    BOOL mute = [[NSUserDefaults standardUserDefaults] boolForKey:kMuteWhenWebOnline];
    NSDictionary *params = @{kMuteWhenWebOnline : [NSNumber numberWithBool:!mute]};
    [[TBHTTPSessionManager sharedManager] PUT:kPreferencesURLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [[NSUserDefaults standardUserDefaults] setBool:!mute forKey:kMuteWhenWebOnline];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self setWebOnlineViewTitle];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        }
    }];
}

#pragma mark - Helper

- (void)commonInit {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back") style:UIBarButtonItemStylePlain target:nil action:nil];
    self.welcomeLabel.text = NSLocalizedString(@"Welcome to Talk", @"Welcome to Talk");
    self.commentLabel.attributedText = [TBUtility getAttributedStringWith:NSLocalizedString(@"New Begin", @"New Begin") andLineSpace:4.0 andFont:13.0];
    [self.goToGeneralBtn setTitle:NSLocalizedString(@"Go to General", @"Go to General") forState:UIControlStateNormal];
    UIImage *backgoundImage = [[UIImage imageNamed:@"icon-button-border"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.goToGeneralBtn setBackgroundImage:backgoundImage forState:UIControlStateNormal];
    self.goToGeneralBtn.tintColor = [UIColor jl_redColor];
    
    self.language = [TBUtility getPreferredLanguage];
    isChinese = [TBUtility systemLanguageIsChinese];
    
    self.isAnimating = NO;
    self.notificationArray = [NSMutableArray array];
    self.pinedNotificationArray = [NSMutableArray array];

    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [UIView new];
    UINib *nib = [UINib nibWithNibName:CellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    self.tableView.separatorColor = [UIColor tb_tableViewSeperatorColor];
    
    [self setMJRefresh];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successFetchTeamData) name:kTeamDataStored object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginFetchTeamData) name:kBeginFetchTeamData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedFetchRemoteData) name:kFailedFetchTeamData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(badgeNumberChanged:) name:kBadgeNumberKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBadgeNumber:) name:kHaveReadMessage object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketMessageUnread:) name:kSocketMessageUnread object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotificationData:) name:kSocketNotificationUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDidDelete:) name:kSocketNotificationDelete object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealForSendingMessage:) name:kSendingMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealForSendMessageSucceed:) name:kSendMessageSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealForSendFailedMessage:) name:kSendMessageFailedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOtherTeamUnread) name:kUpdateOtherTeamUnread object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchTeam:) name:kNotInCurrentTeamNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kPersonalInfoChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNotificationSucceed:) name:kLeaveStorySucceedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editTopicInfo:) name:kEditTopicInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editTopicInfo:) name:kEditTopicColorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNotificationSucceed:) name:kLeaveRoomSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNotificationSucceed:) name:kArchiveRoomSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNotificationSucceed:) name:kSocketRoomArchive object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNotificationSucceed:) name:kDeleteRoomSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteNotificationSucceed:) name:kSocketRoomRemove object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealforUpdateRoomMute:) name:kUpdateRoomMuteNotification object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editTeamNonjoinableAction:) name:kEditTeamNonJoinableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealForSocketPin:) name:kPinTeamColorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealForSocketPin:) name:kUnpinTeamColorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealForMute:) name:kMuteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealForHide:) name:kHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterStoryChatWithNotification:) name:kCreateStorySucceedNotification object:nil];
    
    //share extension or search
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareForRecentMessage:) name:kShareForRecentMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareForTopic:) name:kShareForTopic object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareForMember:) name:kShareForMember object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterChatForSearchMessage:) name:KEnterChatForSearchMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealForDraftUpdate:) name:kDraftUpdate object:nil];
}

- (void)willResignActive {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.totalUnread];
}

- (void)setMJRefresh {
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreNotifications)];
    // Forbid automatical refresh
    self.tableView.footer.automaticallyRefresh = YES;
    // Set title
    [self.tableView.footer setTitle:NSLocalizedString(@"Load more", @"Load more") forState:MJRefreshFooterStateIdle];
    [self.tableView.footer setTitle:NSLocalizedString(@"Loading more items...", @"Loading more items...") forState:MJRefreshFooterStateRefreshing];
    [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateNoMoreData];
}

- (void)setShouldCancel:(BOOL)isCancel {
    shouldCancel = isCancel;
    if (isCancel) {
        [self.webOnlineTimer invalidate];
    } else {
        if (self.webOnlineTimer) {
            [self.webOnlineTimer invalidate];
            self.webOnlineTimer = nil;
            self.webOnlineTimer = [NSTimer scheduledTimerWithTimeInterval:webOnlineInterval target:self selector:@selector(checkWebOnlineOrNot) userInfo:nil repeats:YES];
        }
    }
}

- (void)checkWebOnlineOrNot {
    NSDictionary *param = @{@"scope":@"onlineweb"};
    [[TBHTTPSessionManager sharedManager] GET:kCheckStatusURLString parameters:param success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nonnull responseObject) {
        if ([responseObject[@"onlineweb"] boolValue]) {
            if (self.tableView.tableHeaderView == nil) {
                [self.tableView beginUpdates];
                self.tableView.tableHeaderView = self.webOnlineView;
                [self.tableView endUpdates];
            }
        } else {
            if (self.tableView.tableHeaderView == self.webOnlineView) {
                [self.tableView beginUpdates];
                self.tableView.tableHeaderView = nil;
                [self.tableView endUpdates];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
    }];
}

- (void)successFetchTeamData {
    [TBUtility sendAnalyticsEventWithCategory:kAnalyticsCategoryTeam action:kAnalyticsActionEnterTeam label:@"" value:nil];

    [self showTip];
    [self renderNewTeamData];
    [self updateTabBarBadge];
    
    [self checkWebOnlineOrNot];
    [self setShouldCancel:NO];
}

- (void)showTip {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kHasShowAddStoryTip]) {
        return;
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasShowAddStoryTip];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    RootViewController *rootVC = (RootViewController *)[TBUtility currentAppDelegate].window.rootViewController;
    UIView *topView = rootVC.view;
    CGRect frame = [rootVC.tabBar convertRect:rootVC.addButton.frame toView:topView];
    AMPopTip *poptip = [[TBUtility currentAppDelegate] getPopTipWithContainerView:topView];
    [poptip showText:NSLocalizedString(@"Add story tip", nil) direction:AMPopTipDirectionUp maxWidth:200 inView:topView fromFrame:frame];
}

- (void)beginFetchTeamData {
    [self fetchLocalData];
    [self.tableView reloadData];
    
    //add placeholder
    [self addPlacerHolder];
}

- (void)failedFetchRemoteData {
    [self renderNavigationBar];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self endRefreshingLoading];
        [self renderNewTeamData];
    });
}

- (void)sortForPin {
    //deal for pin
    [self.pinedNotificationArray removeAllObjects];
    for (TBNotification *notification in self.notificationArray)
    {
        if (notification.isPinned) {
            [self.pinedNotificationArray addObject:notification];
        }
    }
    
    if (self.pinedNotificationArray.count > 0) {
        [self.notificationArray removeObjectsInArray:self.pinedNotificationArray];
        NSArray *notPinedArray = [NSArray arrayWithArray:self.notificationArray];
        
        [self.notificationArray removeAllObjects];
        [self.notificationArray addObjectsFromArray:self.pinedNotificationArray];
        [self.notificationArray addObjectsFromArray:notPinedArray];
    }
}

- (void)fetchLocalData {
    //Fetch notifications from local storage
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    NSPredicate *notificationFilter = [NSPredicate predicateWithFormat:@"teamID=%@", currentTeamID];
    NSArray *MONotificationArray = [MONotification MR_findAllWithPredicate:notificationFilter];
    for (MONotification *moNotification in MONotificationArray) {
        [moNotification.managedObjectContext refreshObject:moNotification mergeChanges:NO];
        if (moNotification.draft && [moNotification.updatedAt compare:moNotification.draft.updatedAt] == NSOrderedAscending) {
            moNotification.updatedAt = moNotification.draft.updatedAt;
        }
    }
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO];
    NSArray *reorderArray = [MONotificationArray sortedArrayUsingDescriptors:@[descriptor]];
    NSMutableArray *array = [NSMutableArray array];
    for (MONotification *moNotification in reorderArray) {
        TBNotification *notification = [MTLManagedObjectAdapter modelOfClass:[TBNotification class] fromManagedObject:moNotification error:NULL];
        [array addObject:notification];
    }
    self.notificationArray = [NSMutableArray arrayWithArray:array];
    
    [self sortForPin];
    
    TBNotification *lastNotification = self.notificationArray.lastObject;
    self.maxUpdatedDate = lastNotification.updatedAt;
    
    if (self.notificationArray.count < 10) {
        [self.tableView.footer noticeNoMoreData];
    } else {
        [self.tableView.footer resetNoMoreData];
    }
}

-(IBAction)pullDownRefreshData:(id)sender {
    [self.refreshControl beginRefreshing];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshRecentData object:nil];
}

-(void)loadMoreNotifications {
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *teamID = [defaults valueForKey:kCurrentTeamID];
    NSDictionary *param = @{
                            @"_teamId":teamID,
                            @"maxUpdatedAt":self.maxUpdatedDate,
                            @"limit":@20
                            };
    [manager GET:kNotificationsURLString parameters:param success:^(NSURLSessionDataTask *task, NSArray *responseObject) {
        if (responseObject.count == 0) {
            [self.tableView.footer noticeNoMoreData];
            [self.tableView reloadData];
        } else {
            NSArray *loadedNotificationArray = [MTLJSONAdapter modelsOfClass:[TBNotification class] fromJSONArray:responseObject error:nil];
            for (TBNotification *loadedNotification in loadedNotificationArray) {
                [self.notificationArray addObject:loadedNotification];
            }
            TBNotification *lastNotification = [loadedNotificationArray lastObject];
            self.maxUpdatedDate = lastNotification.updatedAt;
            [self.tableView reloadData];
            [self setMJRefresh];
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                for (TBNotification *loadedNotification in loadedNotificationArray) {
                    MONotification *moNotification = [MTLManagedObjectAdapter managedObjectFromModel:loadedNotification insertingIntoContext:localContext error:NULL];
                    if ([moNotification.type isEqualToString:kNotificationTypeStory]) {
                        TBStory *tbStory = [MTLJSONAdapter modelOfClass:[TBStory class] fromJSONDictionary:moNotification.target error:nil];
                        MOStory *moStory = [MTLManagedObjectAdapter managedObjectFromModel:tbStory insertingIntoContext:localContext error:nil];
                        DDLogDebug(@"moStory.text:%@",moStory.data);
                    }
                    DDLogDebug(@"moNotification.text:%@",moNotification.text);
                }
            }];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)renderNewTeamData {
    [self renderNavigationBar];
    
    [self fetchLocalData];
    [self.tableView reloadData];
    
    //add placeholder
    [self addPlacerHolder];
    [self endRefreshingLoading];
}

- (void)endRefreshingLoading {
    [self.refreshControl endRefreshing];
}

-(void)updateOtherTeamUnread {
    if ([TBUtility currentAppDelegate].otherTeamUnreadNo > 0 || [TBUtility currentAppDelegate].allNewTeamIdArray.count > 0 || [TBUtility currentAppDelegate].otherTeamHasMuteUnread) {
        self.dotView.hidden = NO;
        [self.customTeamButton bringSubviewToFront:self.dotView];
    } else {
        self.dotView.hidden = YES;
    }
}

- (void)badgeNumberChanged:(NSNotification *)notification {
    [self updateTabBarBadge];
}

-(void)refreshBadgeNumber:(NSNotification *)notification {
    NSDictionary *paramsDic = notification.object;
    NSString *targetId = paramsDic[@"id"];
    NSPredicate *predict = [TBUtility notificationPredictForCurrentTeamWithTargetId:targetId];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MONotification *thisNotification = [MONotification MR_findFirstWithPredicate:predict inContext:localContext];
        thisNotification.unreadNum = @0;
    } completion:^(BOOL success, NSError *error) {
        MONotification *thisNotification = [MONotification MR_findFirstWithPredicate:predict];
        NSIndexPath *thisIndexPath;
        TBNotification *tempNotification;
        for (int i = 0; i < self.notificationArray.count; i++) {
            tempNotification = self.notificationArray[i];
            if ([thisNotification.targetID isEqualToString:tempNotification.targetID]) {
                thisIndexPath = [NSIndexPath indexPathForRow:0 inSection:i];
                break;
            }
        }
        if (thisIndexPath) {
            [self clearBadgeWithTBNotification:tempNotification atIndex:thisIndexPath];
        }
    }];
}

- (void)reCalculateTotalUnread {
    self.totalUnread = 0;
    [self.notificationArray enumerateObjectsUsingBlock:^(TBNotification *notification, NSUInteger idx, BOOL *stop) {
        if (!notification.isMute) {
            NSUInteger messageBadge = notification.unreadNum.integerValue;
            self.totalUnread = self.totalUnread + messageBadge;
        }
    }];
}

- (void)updateTabBarBadge {
    [self reCalculateTotalUnread];

    UITabBarItem *tabBarItem = (self.tabBarController.tabBar.items)[0];
    
    // If team unread number is larger than 0, show tab bar item badge. Otherwise hide the badge.
    NSInteger currentTeamUnread;
    NSString *badgeValueStr = [NSString stringWithFormat:@"%d", (int)self.totalUnread];
    if (badgeValueStr.intValue <= 0)
    {
        tabBarItem.badgeValue = nil;
        currentTeamUnread = 0;
    } else {
        NSString *badgeValue = [NSString stringWithFormat:@"%d", (int)self.totalUnread];
        tabBarItem.badgeValue = badgeValue;
        currentTeamUnread = self.totalUnread;
    }
    
    NSString *currentTeamID   = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentTeamID];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MOTeam *currentTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:currentTeamID inContext:localContext];
        currentTeam.unread = [NSNumber numberWithInteger:currentTeamUnread];
        if (currentTeamUnread <= 0) {
            currentTeam.hasUnreadValue = NO;
        }
    } completion:^(BOOL success, NSError *error) {
        DDLogDebug(@"Update current team unread successfully");
    }];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = self.totalUnread;
}

-(void)editTopicInfo:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchLocalData];
        [self.tableView reloadData];
    });
}

/**
 *  add plaerholder if no data
 */

-(void)addPlacerHolder
{
    if (self.notificationArray.count == 0)
    {
        self.tableView.tableFooterView = self.headerView;
    } else {
        self.tableView.tableFooterView = [UIView new];
    }
}

/**
 *  get IndexPath In RecentMessageArray With TargetID(roomID or UserID)
 *
 *  @param targetID (roomID or UserID)
 *
 *  @return NSIndexPath
 */
- (NSIndexPath *)getIndexPathInNotificationArrayWithID:(NSString *)notificationID {
    NSInteger indexNumber = -1;
    
    for (TBNotification *notification in self.notificationArray) {
        if ([notification.id isEqualToString:notificationID]) {
            indexNumber = [self.notificationArray indexOfObject:notification];
            break;
        }
    }
    
    if (indexNumber == -1) {
        return nil;//not found
    } else {
        return [NSIndexPath indexPathForRow:indexNumber inSection:0];
    }
}

#pragma mark - pop chat ViewController

- (void)popChatViewController {
    [self.tabBarController setSelectedIndex:0];
    [self.tabBarController.viewControllers enumerateObjectsUsingBlock:^(UINavigationController *nc, NSUInteger idx, BOOL *stop) {
        if (nc.viewControllers.count > 2) {
            [nc popToViewController:nc.viewControllers[1] animated:NO];
        }
        [nc popViewControllerAnimated:NO];
    }];
}

#pragma mark - enter chat 

- (void)enterChatWithStory:(MOStory *)selectedMOStory {
    ChatViewController *tempChatVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    tempChatVC.currentStory = selectedMOStory;
    tempChatVC.refreshWhenViewDidLoad = YES;
    tempChatVC.roomType = ChatRoomTypeForStory;
    [TBUtility currentAppDelegate].currentStory = selectedMOStory;
    [self.navigationController pushViewController:tempChatVC animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateTabBarBadge];
    });
}

- (void)enterChatWithRoom:(MORoom *)selectedMORoom {
    ChatViewController *tempChatVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    tempChatVC.refreshWhenViewDidLoad = YES;
    tempChatVC.roomType = ChatRoomTypeForRoom;
    if (selectedMORoom.isQuitValue) {
        tempChatVC.isPreView = YES;
    }
    [TBUtility currentAppDelegate].currentRoom = selectedMORoom;
    [self.navigationController pushViewController:tempChatVC animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateTabBarBadge];
    });
}

- (void)enterChatWithMember:(MOUser *)tempMOUser {
    ChatViewController *tempChatVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    tempChatVC.refreshWhenViewDidLoad = YES;
    tempChatVC.title = [TBUtility getFinalUserNameWithMOUser:tempMOUser];
    tempChatVC.roomType = ChatRoomTypeForTeamMember;
    if (tempMOUser.isQuitValue) {
        tempChatVC.chatStyle = ChatStyleLeft;
    }
    tempChatVC.currentToMember = tempMOUser;
    [TBUtility currentAppDelegate].currentRoom = nil;
    [self.navigationController pushViewController:tempChatVC animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateTabBarBadge];
    });
}

- (void)enterChatWithModel:(TBMessage *)message {
    ChatViewController *tempChatVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    tempChatVC.refreshWhenViewDidLoad = NO;
    tempChatVC.chatStyle = ChatStyleSearch;
    tempChatVC.searchedMessage = message;
    if (message.roomID) {
        NSPredicate *predacate = [TBUtility roomPredicateForCurrentTeamWithRoomId:message.roomID];
        MORoom *selectedMORoom = [MORoom MR_findFirstWithPredicate:predacate];
        tempChatVC.roomType = ChatRoomTypeForRoom;
        if (selectedMORoom.isQuitValue) {
            tempChatVC.isPreView = YES;
        }
        [TBUtility currentAppDelegate].currentRoom = selectedMORoom;
        // when click one cell update tab bar badge and clear cell badge
        self.totalUnread = self.totalUnread - (NSUInteger) [selectedMORoom.unread integerValue];
    } else if (message.storyID) {
        NSPredicate *predicate = [TBUtility storyPredicateForCurrentTeamWithRoomId:message.storyID];
        MOStory *selectedMOStory = [MOStory MR_findFirstWithPredicate:predicate];
        if (selectedMOStory) {
            tempChatVC.roomType = ChatRoomTypeForStory;
            tempChatVC.currentStory = selectedMOStory;
            [TBUtility currentAppDelegate].currentStory = selectedMOStory;
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"No this story", @"No this story")];
            return;
        }
    } else {
        NSString *targetUserID = nil;
        NSString *currentUserID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
        if (message.toID) {
            if ([message.toID isEqualToString:currentUserID]) {
                targetUserID =message.creatorID;
            } else {
                targetUserID = message.toID;
            }
        }
        MOUser *tempMOUser= [MOUser findFirstWithId:targetUserID];
        tempChatVC.title = [TBUtility getFinalUserNameWithMOUser:tempMOUser];
        tempChatVC.roomType = ChatRoomTypeForTeamMember;
        tempChatVC.currentToMember = tempMOUser;
        if (tempMOUser.isQuitValue) {
            tempChatVC.chatStyle = ChatStyleLeft;
        }
        [TBUtility currentAppDelegate].currentRoom = nil;
        
        // when click one cell update tab bar badge and clear cell badge
        self.totalUnread = self.totalUnread - (NSUInteger) [tempMOUser.unread integerValue];
    }
    [self updateTabBarBadge];
    [self.navigationController pushViewController:tempChatVC animated:YES];
}

#pragma mark - deal for Notification

-(void)deleteNotificationSucceed:(NSNotification *)notification
{
    NSString *deleteNotificationId = [notification object];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
        NSPredicate *storyFilter = [NSPredicate predicateWithFormat:@"targetID = %@ AND teamID = %@",deleteNotificationId, currentTeamID];
        MONotification *deleteNotification = [MONotification MR_findFirstWithPredicate:storyFilter inContext:localContext];
        if (deleteNotification) {
            [deleteNotification MR_deleteInContext:localContext];
        }
    } completion:^(BOOL success, NSError *error) {
        [self renderNewTeamData];
    }];
    
}

- (void)dealForSocketPin:(NSNotification *)notification {
    NSString *targetID = notification.object;
    NSIndexPath *olderIndexPath = [self getIndexPathInNotificationArrayWithID:targetID];
    if (olderIndexPath.row < 0) {
        return;
    }
    TBNotification *newModel = [self.notificationArray objectAtIndex:olderIndexPath.row];
    newModel.isPinned = !newModel.isPinned;
    [self.notificationArray replaceObjectAtIndex:olderIndexPath.row withObject:newModel];
    [self.tableView reloadRowsAtIndexPaths:@[olderIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self fetchLocalData];
    NSIndexPath *newIndexPath = [self getIndexPathInNotificationArrayWithID:targetID];
    if (newIndexPath.row < 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        [self.tableView moveRowAtIndexPath:olderIndexPath toIndexPath:newIndexPath];
        [self.tableView endUpdates];
    });
    
    for (TBRecentCell *tempCell in self.tableView.visibleCells) {
        [self tableView:self.tableView willDisplayCell:tempCell forRowAtIndexPath:[self.tableView indexPathForCell:tempCell]];
    }
}

- (void)dealForMute:(NSNotification *)notification {
    NSString *targetID = notification.object;
    NSIndexPath *olderIndexPath = [self getIndexPathInNotificationArrayWithID:targetID];
    if (olderIndexPath.row < 0) {
        return;
    }
    TBNotification *newModel = [self.notificationArray objectAtIndex:olderIndexPath.row];
    newModel.isMute = !newModel.isMute;
    [self.notificationArray replaceObjectAtIndex:olderIndexPath.row withObject:newModel];
    [self.tableView reloadRowsAtIndexPaths:@[olderIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    for (TBRecentCell *tempCell in self.tableView.visibleCells) {
        [self tableView:self.tableView willDisplayCell:tempCell forRowAtIndexPath:[self.tableView indexPathForCell:tempCell]];
    }
    
    [self updateTabBarBadge];
}

- (void)dealForHide:(NSNotification *)notification {
    NSString *targetID = notification.object;
    NSIndexPath *deleteIndexPath = [self getIndexPathInNotificationArrayWithID:targetID];
    [self.notificationArray removeObjectAtIndex:deleteIndexPath.row];
    [self.tableView reloadData];
}

- (void)dealForDraftUpdate:(NSNotification *)notification {
    [self fetchLocalData];
    [self.tableView reloadData];
}

- (void)enterStoryChatWithNotification:(NSNotification *)notification {
    [self enterChatWithStory:notification.object];
}

#pragma mark - UITableView swipe Actions

- (void)muteWithRoom:(MORoom *)room {
    NSString *urlString = [NSString stringWithFormat:KRoomPrefsURLString,room.id];
    NSDictionary *params;
    if (room.isMuteValue) {
        params = @{@"prefs": @{@"isMute":@NO}};
    } else {
        params = @{@"prefs": @{@"isMute":@YES}};
    }
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager PUT:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        DDLogDebug(@"Success pin or unpin :%@",responseDic);
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:responseDic[@"_id"]];
            MORoom *mutedRoom  = [MORoom MR_findFirstWithPredicate:predicate inContext:localContext];
            if (mutedRoom) {
                mutedRoom.isMuteValue = [[responseDic[@"prefs"] objectForKey:@"isMute"] boolValue];
            }
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateRoomMuteNotification object:responseDic[@"_id"]];
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"error: %@", error.localizedRecoverySuggestion);
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];}

- (void)pinForNotification:(TBNotification *)model {
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    NSDictionary *param;
    if (model.isPinned) {
        param = @{
                  @"isPinned":@NO
                  };
    } else {
        param = @{
                  @"isPinned":@YES
                  };
    }
    [manager PUT:[NSString stringWithFormat:kNotificationUpdateURLString, model.id] parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        DDLogDebug(@"Success pin or unpin :%@",responseDic);
        if (!model.isPinned) {
            [[TBSocketManager sharedManager] teamPinWith:responseDic];
        } else {
            [[TBSocketManager sharedManager] teamUnpinWith:responseDic];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"error: %@", error.localizedRecoverySuggestion);
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

- (void)removeNotification:(TBNotification *)notification withIndexPath:(NSIndexPath *)indexPath {
    [self clearBadgeWithTBNotification:notification atIndex:indexPath];
    [self removeNotification:notification];
}

- (void)removeNotification:(TBNotification *)notification {
    MONotification *removeNotification = [MONotification MR_findFirstByAttribute:@"id" withValue:notification.id];
    if (!removeNotification) {
        return;
    }
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MONotification *localNotification = [removeNotification MR_inContext:localContext];
        [localNotification MR_deleteInContext:localContext];
    } completion:^(BOOL success, NSError *error) {
        NSIndexPath *deleteIndexPath = [self getIndexPathInNotificationArrayWithID:notification.id];
        if ([self.pinedNotificationArray containsObject:notification]) {
            [self.pinedNotificationArray removeObject:notification];
        }
        [self.notificationArray removeObjectAtIndex:deleteIndexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
        NSDictionary *param = @{
                                @"isHidden":@YES
                                };
        [manager PUT:[NSString stringWithFormat:kNotificationUpdateURLString, notification.id] parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *responseDic = (NSDictionary *)responseObject;
            DDLogDebug(@"Success hide :%@",responseDic);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DDLogError(@"error: %@", error.localizedRecoverySuggestion);
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        }];
        
    }];
}

- (void)muteForNotification:(TBNotification *)model {
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    NSDictionary *param;
    if (model.isMute) {
        param = @{
                  @"isMute":@NO
                  };
    } else {
        param = @{
                  @"isMute":@YES
                  };
    }
    
    [manager PUT:[NSString stringWithFormat:kNotificationUpdateURLString, model.id] parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        DDLogDebug(@"Success mute or unmute :%@",responseDic);
        if (!model.isMute) {
            [[TBSocketManager sharedManager] teamMuteWith:responseDic];
        } else {
            [[TBSocketManager sharedManager] teamUnmuteWith:responseDic];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"error: %@", error.localizedRecoverySuggestion);
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

#pragma mark - Deal for accepted message

- (void)updateNotificationData:(NSNotification *)notification {
    TBNotification *newNotification = notification.object;
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
    if ([newNotification.creatorID isEqualToString:currentUserID]) {
        [self updateNotificationWith:newNotification isSend:YES];
    } else {
        [self updateNotificationWith:newNotification isSend:NO];
    }
}

- (void)notificationDidDelete:(NSNotification *)notifcation {
    TBNotification *tbNotification = [TBNotification new];
    NSDictionary *object = notifcation.object;
    tbNotification.id = object[@"id"];
    tbNotification.unreadNum = object[@"unreadNum"];
    tbNotification.emitterID = object[@"emitterID"];
    NSIndexPath *deleteIndexPath = [self getIndexPathInNotificationArrayWithID:tbNotification.id];
    if (deleteIndexPath) {
        [self.notificationArray removeObjectAtIndex:deleteIndexPath.row];
        [self clearBadgeWithTBNotification:tbNotification atIndex:deleteIndexPath];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
    }
}


//sending message
- (void)dealForSendingMessage:(NSNotification *)notification
{
    [self dealForSendFailedMessage:notification];
}

-(void)dealForSendFailedMessage:(NSNotification *)notification
{
    TBMessage *failedMessage;
    if ([notification.object isKindOfClass:[NSArray class]]) {
        NSArray *objectArray = (NSArray *)notification.object;
        failedMessage = objectArray.firstObject;
    } else {
        failedMessage = notification.object;
    }
    
    NSString *targetID;
    if (failedMessage.roomID) {
        targetID = failedMessage.roomID;
    } else if (failedMessage.storyID) {
        targetID = failedMessage.storyID;
    } else if (failedMessage.toID) {
        targetID = failedMessage.toID;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"targetID = %@ AND teamID = %@",targetID,failedMessage.teamID];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MONotification *moNotification = [MONotification MR_findFirstWithPredicate:predicate inContext:localContext];
        if (moNotification) {
            moNotification.text = failedMessage.messageStr;
            moNotification.sendStatus = [NSNumber numberWithInteger:failedMessage.sendStatus];
            moNotification.updatedAt = [NSDate date];
        }
    } completion:^(BOOL success, NSError *error) {
        MONotification *moNotification = [MONotification MR_findFirstWithPredicate:predicate];
        TBNotification *newNotification = [MTLManagedObjectAdapter modelOfClass:[TBNotification class] fromManagedObject:moNotification error:nil];
        [self updateNotificationWith:newNotification isSend:YES];
    }];
}

//send message succeed
-(void)dealForSendMessageSucceed:(NSNotification *)notification
{
//    NSDictionary *messageDic;
//    if ([notification.object isKindOfClass:[NSArray class]]) {
//        NSArray *objectArray = (NSArray *)notification.object;
//        messageDic = objectArray.firstObject;
//    } else {
//        messageDic = notification.object;
//    }
//    TBMessage *newMessage = [MTLJSONAdapter modelOfClass:[TBMessage class] fromJSONDictionary:messageDic error:nil];
//    
//    NSString *targetID;
//    if (newMessage.roomID) {
//        targetID = newMessage.roomID;
//    } else if (newMessage.storyID) {
//        targetID = newMessage.storyID;
//    } else if (newMessage.toID) {
//        targetID = newMessage.toID;
//    }
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"targetID = %@ AND teamID = %@",targetID,newMessage.teamID];
//    
//    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
//        
//        MONotification *moNotification = [MONotification MR_findFirstWithPredicate:predicate inContext:localContext];
//        if (moNotification) {
//            moNotification.sendStatus = newMessage.sendStatus;
//        }
//    } completion:^(BOOL success, NSError *error) {
//        MONotification *moNotification = [MONotification MR_findFirstWithPredicate:predicate];
//        TBNotification *newNotification = [MTLManagedObjectAdapter modelOfClass:[TBNotification class] fromManagedObject:moNotification error:nil];
//        [self updateNotificationWith:newNotification isSend:YES];
//    }];
    
}

- (NSPredicate *)getPredicateWithRecentMessage:(TBRecentMessage *)message isForFailedMessage:(BOOL)isForFailed{
    NSPredicate *predicate;
    if (message.roomID) {
        predicate = [NSPredicate predicateWithFormat:@"roomID = %@",message.roomID];
    } else {
        NSString *currentUserID = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentUserKey];
        NSString *currentTeamID = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentTeamID];
        if (isForFailed) {
            predicate = [NSPredicate predicateWithFormat:@"creatorId IN {%@, %@} AND toID IN {%@, %@} AND teamID = %@",message.toID,currentUserID,message.toID,currentUserID,currentTeamID];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"creatorID IN {%@, %@} AND toID IN {%@, %@} AND teamID = %@",message.toID,currentUserID,message.toID,currentUserID,currentTeamID];
        }
    }
    return predicate;
}

- (NSInteger)indexForNotification:(TBNotification *)newNotification {
    NSInteger indexNumber = -1;
    for (TBNotification *notification in self.notificationArray) {
        if ([notification.targetID isEqualToString:newNotification.targetID]) {
            indexNumber = [self.notificationArray indexOfObject:notification];
            break;
        }
    }
    return indexNumber;
}

-(void)updateNotificationWith:(TBNotification *)newNotification isSend:(BOOL)isSend {
    if (!newNotification) {
        return;
    }
    // Judge if the message is from the current team, if not, do nothing here.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentTeamID = [defaults valueForKey:kCurrentTeamID];
    if (![newNotification.teamID isEqualToString:currentTeamID]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateOtherTeamUnread object:nil];
        return;
    }
    
    NSInteger indexNumber = [self indexForNotification:newNotification];
    if (indexNumber == -1) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            MONotification *moNotification = [MTLManagedObjectAdapter managedObjectFromModel:newNotification insertingIntoContext:localContext error:NULL];
            DDLogDebug(@"moNotification.text:%@",moNotification.text);
        }];
        NSInteger newIndexNumber = [self indexForNotification:newNotification];
        if (newIndexNumber == -1 ) {
            [self refreshTableViewWith:indexNumber andNotification:newNotification];
            [self updateTabBarBadge];
        }
    } else {
        [self refreshTableViewWith:indexNumber andNotification:newNotification];
        [self updateTabBarBadge];
    }
}

-(void)refreshTableViewWith:(NSInteger)indexNumber andNotification:(TBNotification *)notification
{
    // Replace with the new message in recent message array
    if ( indexNumber >=0 && indexNumber <= self.notificationArray.count) {
        NSMutableArray *array = [self.notificationArray mutableCopy];
        array[(NSUInteger) indexNumber] = notification;
        self.notificationArray = [NSMutableArray arrayWithArray:array];
        NSIndexPath *currentChangedPath = [NSIndexPath indexPathForRow:indexNumber inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[currentChangedPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.notificationArray removeObjectAtIndex:indexNumber];
        
        [self.tableView beginUpdates];
        BOOL isPinned = NO;
        for (TBNotification *pinedNotification in self.pinedNotificationArray) {
            if ([pinedNotification.id isEqualToString:notification.id]) {
                isPinned = YES;
                break;
            }
        }
        if (isPinned) {
            [self.notificationArray insertObject:notification atIndex:0];
            [self.tableView moveRowAtIndexPath:currentChangedPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        } else {
            [self.notificationArray insertObject:notification atIndex:self.pinedNotificationArray.count];
            [self.tableView moveRowAtIndexPath:currentChangedPath toIndexPath:[NSIndexPath indexPathForRow:self.pinedNotificationArray.count inSection:0]];
        }
        [self.tableView endUpdates];
        
        //[self saveNewRecentMessage:newMessage];
    }
    // Add new message to the top position
    else {
        NSMutableArray *array = [self.notificationArray mutableCopy];
        self.notificationArray = [NSMutableArray arrayWithArray:array];
        NSIndexPath *indexPathZero;
        if (self.notificationArray.count == 0) {
            [self.notificationArray addObject:notification];
        } else {
            [self.notificationArray insertObject:notification atIndex:self.pinedNotificationArray.count];
        }
        indexPathZero = [NSIndexPath indexPathForRow:self.pinedNotificationArray.count inSection:0];
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[indexPathZero] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        //add placeholder
        [self addPlacerHolder];
    }
}

#pragma mark - Clear Message Unread


/**
 *  clear unread message for notification
 *
 *  @param notification  TBNotification
 *  @param indexPath  NSIndexPath
 *
 *  @return void
 */

- (void)clearBadgeWithTBNotification:(TBNotification *)notification atIndex:(NSIndexPath *)indexPath {
    if ([notification.unreadNum  isEqual:@0]) {
        [self updateTabBarBadge];
        return;
    }
    if (indexPath) {
        [self clearMessageBadge:indexPath];
    }
    NSMutableDictionary *param = @{@"unreadNum": @0,}.mutableCopy;
    if (notification.emitterID) {
        param[@"_latestReadMessageId"] = notification.emitterID;
    }
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager PUT:[NSString stringWithFormat:kNotificationUpdateURLString, notification.id]
       parameters:param
          success:^(NSURLSessionDataTask *task, id responseObject) {
              DDLogVerbose(@"Successfully cleared messages.");
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              DDLogError(@"Error: %@", error);
          }];
}

/**
 *  clearMessageBadge
 *
 *  @param indexPath  NSIndexPath
 *
 *  @return void
 */

- (void)clearMessageBadge:(NSIndexPath *)indexPath {
    TBRecentCell *cell = (TBRecentCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    TBNotification *notification = self.notificationArray[indexPath.row];
    notification.unreadNum = @0;
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        MONotification *moNotification = [MONotification MR_findFirstByAttribute:@"id" withValue:notification.id inContext:localContext];
        moNotification.unreadNum = @0;
    }];
    [self updateTabBarBadge];
    cell.badge.hidden = YES;
    cell.unreadDotImageView.hidden = YES;
}

#pragma mark - Share extension or search notification methods

- (void)shareForRecentMessage:(NSNotification *)notification {
//    [self popChatViewController];
//    
//    MORecentMessage *extensionMessage = notification.object;
//     NSInteger row = 0;
//    for (TBRecentModel *model in self.recentMessageArray) {
//        TBRecentMessage *tempMessage = model.message;
//        if ([tempMessage.id isEqualToString:extensionMessage.id]) {
//            row = [self.recentMessageArray indexOfObject:model];
//            break;
//        }
//    }
//    NSIndexPath *extensionIndex = [NSIndexPath indexPathForRow:row inSection:0];
//    [self tableView:self.tableView didSelectRowAtIndexPath:extensionIndex];
}

- (void)shareForTopic:(NSNotification *)notification {
    [self popChatViewController];
    
    MORoom *extensionRoom = notification.object;
    [self enterChatWithRoom:extensionRoom];
}

- (void)shareForMember:(NSNotification *)notification {
    [self popChatViewController];
    
    MOUser *extensionUser = notification.object;
    [self enterChatWithMember:extensionUser];
}

- (void)enterChatForSearchMessage:(NSNotification *)notification {
    [self popChatViewController];
    
    TBMessage *message = notification.object;
    [self enterChatWithModel:message];
}

-(void)successCreateRoom:(MORoom *)room
{
    ChatViewController *tempChatVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    tempChatVC.refreshWhenViewDidLoad = YES;
    tempChatVC.roomType = ChatRoomTypeForRoom;
    [TBUtility currentAppDelegate].currentRoom = room;
    [tempChatVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:tempChatVC animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notificationArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBRecentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    // Get Message information like message content, created time and creator
    TBNotification *model = self.notificationArray[(NSUInteger) indexPath.row];
    if (model == nil) {
        return cell;
    }
    [cell setModel:model];
    cell.rightButtons = [self createRightButtonsWithModel:self.notificationArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isEnteringChatVC) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    self.isEnteringChatVC = YES;

    TBNotification *notification = self.notificationArray[(NSUInteger) indexPath.row];
    self.totalUnread = self.totalUnread - (NSUInteger) [notification.unreadNum integerValue];
    [self updateTabBarBadge];
    // Message from a topic
    if ([notification.type isEqualToString:kNotificationTypeRoom]) {
        NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:notification.targetID];
        MORoom *tempMORoom = [MORoom MR_findFirstWithPredicate:predicate];
        [self enterChatWithRoom:tempMORoom];
    }
    // Message from a user
    else if([notification.type isEqualToString:kNotificationTypeDMS]) {
        NSString *currentUserID = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentUserKey];
        NSString *toID;
        if ([notification.creatorID isEqualToString:currentUserID]) {
            toID = notification.targetID;
        } else {
            toID = notification.creatorID;
        } 
        MOUser *tempMOUser = [MOUser findFirstWithId:toID inContext:[NSManagedObjectContext MR_defaultContext]];
        [self enterChatWithMember:tempMOUser];
    } else {
        //story
        MOStory *tempMOStory = [MOStory MR_findFirstByAttribute:@"id" withValue:notification.targetID];
        [self enterChatWithStory:tempMOStory];
    }
    [self clearBadgeWithTBNotification:notification atIndex:indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MGSwipeTableCellDelegate

-(NSArray *)createRightButtonsWithModel:(TBNotification *)notification {
    NSMutableArray * buttons = [NSMutableArray array];
    [buttons addObject:[self hideButtonWithModel:notification]];
    [buttons addObject:[self muteButtonWithModel:notification]];
    [buttons addObject:[self pinButtonWithModel:notification]];
    return buttons;
}

- (MGSwipeButton *)pinButtonWithModel:(TBNotification *)model {
    NSString *imageString = @"cell-pin";
    MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:imageString] backgroundColor:[UIColor clearColor] padding:0 callback:^BOOL(MGSwipeTableCell * sender){
        return YES;
    }];
    [button setButtonWidth:72];
    return button;
}

- (MGSwipeButton *)muteButtonWithModel:(TBNotification *)model {
    NSString *imageString = @"cell-mute";
    MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:imageString] backgroundColor:[UIColor clearColor] padding:0 callback:^BOOL(MGSwipeTableCell * sender){
        return YES;
    }];
    [button setButtonWidth:72];
    return button;
}

- (MGSwipeButton *)hideButtonWithModel:(TBNotification *)model {
    NSString *imageString  = @"cell-hide";
    MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:imageString] backgroundColor:[UIColor clearColor] padding:0 callback:^BOOL(MGSwipeTableCell * sender){
        return YES;
    }];
    [button setButtonWidth:72];
    return button;
}

-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction {
    if (direction == MGSwipeDirectionLeftToRight) {
        return NO;
    } else {
        return YES;
    }
}

-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    NSIndexPath * path = [self.tableView indexPathForCell:cell];
    TBNotification *model = self.notificationArray[(NSUInteger) path.row];
    if (index == 0) {
        // Hide this chat
        [self removeNotification:model withIndexPath:path];
        [cell hideSwipeAnimated:NO];
    } else if (index == 1) {
        // Mute this room
        [self muteForNotification:model];
        [cell hideSwipeAnimated:NO];
    } else if (index == 2) {
        // Pin this chat
        [self pinForNotification:model];
        [cell hideSwipeAnimated:NO];
    }

    return NO;
}

#pragma mark - UINavigationController Delegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController.viewControllers.count == 1) {
        [TBUtility currentAppDelegate].currentChatViewController = nil;
        [[TBHTTPSessionManager sharedManager] cancelAllHTTPOperationsWithPath:kSendMessageURLString exceptMethod:@"POST"];
    }
    
    if ([viewController isKindOfClass:[ChatViewController class]]) {
        [[TBHTTPSessionManager sharedManager] cancelAllHTTPOperationsWithPath:[NSString stringWithFormat:@"%@/%@",kTopicURLString,[TBUtility currentAppDelegate].currentRoom.id]];
    }
}

#pragma mark - Animation Controller Delegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    self.snoozeRevealAnimator.presenting = YES;
    return self.snoozeRevealAnimator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.snoozeRevealAnimator.presenting = NO;
    return self.snoozeRevealAnimator;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    UINavigationController *searchNavigationController = [[UIStoryboard storyboardWithName:kSearchStoryboard bundle:nil] instantiateInitialViewController];
    searchNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    searchNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:searchNavigationController animated:YES completion:nil];
    return NO;
}

#pragma mark - UIViewControllerPreviewingDelegate

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    
    if (self.isEnteringChatVC) {
        return nil;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    TBRecentCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    ChatViewController *tempChatVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    tempChatVC.refreshWhenViewDidLoad = YES;
    
    TBNotification *notification = self.notificationArray[(NSUInteger) indexPath.row];
    self.totalUnread = self.totalUnread - (NSUInteger) [notification.unreadNum integerValue];
    [self updateTabBarBadge];
    
    // Message from a room
    if ([notification.type isEqualToString:kNotificationTypeRoom]) {
        NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:notification.targetID];
        MORoom *tempMORoom = [MORoom MR_findFirstWithPredicate:predicate];
        tempChatVC.roomType = ChatRoomTypeForRoom;
        if (tempMORoom.isQuitValue) {
            tempChatVC.isPreView = YES;
        }
        [TBUtility currentAppDelegate].currentRoom = tempMORoom;
    }
    // Message from a user
    else if([notification.type isEqualToString:kNotificationTypeDMS]) {
        NSString *currentUserID = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentUserKey];
        NSString *toID;
        if ([notification.creatorID isEqualToString:currentUserID]) {
            toID = notification.targetID;
        }
        else
        {
            toID = notification.creatorID;
        }
        MOUser *tempMOUser = [MOUser findFirstWithId:toID inContext:[NSManagedObjectContext MR_defaultContext]];
        tempChatVC.roomType = ChatRoomTypeForTeamMember;
        tempChatVC.title = [TBUtility getFinalUserNameWithMOUser:tempMOUser];
        if (tempMOUser.isQuitValue) {
            tempChatVC.chatStyle = ChatStyleLeft;
        }
        tempChatVC.currentToMember = tempMOUser;
    } else {
        //story
        MOStory *tempMOStory = [MOStory MR_findFirstByAttribute:@"id" withValue:notification.targetID];
        if (!tempMOStory) {
            TBStory *tempTBStory = [MTLJSONAdapter modelOfClass:[TBStory class] fromJSONDictionary:notification.target error:nil];
            tempMOStory = [MTLManagedObjectAdapter managedObjectFromModel:tempTBStory insertingIntoContext:[NSManagedObjectContext MR_defaultContext] error:nil];
        }
        tempChatVC.currentStory = tempMOStory;
        tempChatVC.roomType = ChatRoomTypeForStory;
        [TBUtility currentAppDelegate].currentStory = tempMOStory;
    }
    [self clearBadgeWithTBNotification:notification atIndex:indexPath];
    
    tempChatVC.recentMessagesViewController = self;
    
    previewingContext.sourceRect = cell.frame;
    return tempChatVC;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    if (self.isEnteringChatVC) {
        return;
    }
    self.isEnteringChatVC = YES;
    [self showViewController:viewControllerToCommit sender:self];
}

@end
