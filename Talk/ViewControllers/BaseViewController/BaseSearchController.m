//
//  BaseSearchController.m
//  Talk
//
//  Created by Suric on 15/5/4.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "BaseSearchController.h"
#import "ChangeTeamViewController.h"
#import "constants.h"
#import "ChooseTeamViewController.h"
#import "TBUtility.h"
#import "MOTeam.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "TBSnoozeRevealAnimator.h"
#import "MoreTableViewController.h"
#import "NSString+Emoji.h"
#import "TBHTTPSessionManager.h"
#import "ChatViewController.h"
#import "MoreTableViewController.h"
#import "NewTeamViewController.h"
#import "TeamSettingViewController.h"
#import "TBTeam.h"
#import "SyncTeamsViewController.h"
#import "SCViewController.h"
#import "MeTableViewController.h"
#import <SDWebImage/UIButton+WebCache.h>

#import "Reachability.h"
#import "ReachabilityView.h"
#import <Masonry/Masonry.h>

#import "AddTopicMemberViewController.h"
#import "CallingViewController.h"
#import "Talk-Swift.h"

#import "SwitchTeamTableViewController.h"
#import "TeamActivityTableViewController.h"
#import "AppSettingViewController.h"

@interface BaseSearchController ()<UIViewControllerTransitioningDelegate,UISearchBarDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, SyncTeamsDelegate, MultiplePhoneCallDelegate>
@property (strong, nonatomic) UIView *dotView;
@property(nonatomic, strong) TBSnoozeRevealAnimator *snoozeRevealAnimator;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic, strong) ReachabilityView *reachabilityView;
@end

@implementation BaseSearchController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBar];
    [self renderNavigationBar];
    self.navigationController.delegate = self;
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    self.reachabilityView = [[ReachabilityView alloc] initReachabilityView];
    [self configureReachability:self.internetReachability];
    
    self.snoozeRevealAnimator = [TBSnoozeRevealAnimator new];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = NSLocalizedString(@"Search everything", @"Search everything");
    [self.searchBar setValue:[UIColor grayColor] forKeyPath:@"_searchField.textColor"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOtherTeamUnread) name:kUpdateOtherTeamUnread object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectSuccess) name:kTeamDataStored object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedFetchRemoteData) name:kFailedFetchTeamData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAvatar:) name:kAvatarChangeNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navigation-shadow"]];
    
    if (self.transitionCoordinator) {
        [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
            [self.navigationController.navigationBar setTranslucent:NO];
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
            [self.navigationController.navigationBar setTranslucent:NO];
        }];
    } else {
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setTranslucent:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
    if (self.navigationController.viewControllers.count > 1) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        if (self.transitionCoordinator) {
            [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                if (![[context viewControllerForKey:UITransitionContextToViewControllerKey] isKindOfClass:[MeTableViewController class]]) {
                    [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
                }
            } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
            }];
        } else {
            [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Reachability

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* reachability = [note object];
    NSParameterAssert([reachability isKindOfClass:[Reachability class]]);
    [self configureReachability:reachability];
}

- (void)configureReachability:(Reachability *)reachability {
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    switch (netStatus) {
        case NotReachable: {
            DDLogDebug(@"===========LOST==============");
            [self.reachabilityView networkNotConnectedView];
            [UIView beginAnimations:nil context:NULL];
            self.tableView.tableHeaderView = self.reachabilityView;
            [UIView commitAnimations];
            connectionRequired = NO;
            break;
        }
            
        case ReachableViaWWAN: {
            DDLogDebug(@"===========WWAN==============");
            if (self.tableView.tableHeaderView) {
                [self.reachabilityView networkConnectingView];
                [self.tableView beginUpdates];
                self.tableView.tableHeaderView = self.reachabilityView;
                [self.tableView endUpdates];
            
            break;
        }
        case ReachableViaWiFi: {
            DDLogDebug(@"===========WiFi==============");
            if (self.tableView.tableHeaderView) {
                [self.reachabilityView networkConnectingView];
                [self.tableView beginUpdates];
                self.tableView.tableHeaderView = self.reachabilityView;
                [self.tableView endUpdates];
            }
            
            break;
        }
    }
    }
}

- (void)connectSuccess {
    [self renderNavigationBar];
    
    if ([self.tableView.tableHeaderView isKindOfClass:[ReachabilityView class]]) {
        [self.reachabilityView networkConnectedView];
        [self.tableView beginUpdates];
        self.tableView.tableHeaderView = self.reachabilityView;
        [self.tableView endUpdates];
        
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC);
        dispatch_after(delayTime,dispatch_get_main_queue(),^(void){
            [self.tableView beginUpdates];
            self.tableView.tableHeaderView = nil;
            [self.tableView endUpdates];
        });
    }
}

#pragma mark - Private Methods

- (void)setNavigationBar {
    // set click region button
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.showsTouchWhenHighlighted = YES;
    leftButton.adjustsImageWhenHighlighted = YES;
    [leftButton setBackgroundColor:[UIColor clearColor]];
    [leftButton addTarget:self action:@selector(switchTeam:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:leftButton];
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_top).with.offset(padding.top); //with is an optional semantic filler
        make.left.equalTo(self.titleView.mas_left).with.offset(padding.left);
        make.bottom.equalTo(self.titleView.mas_bottom).with.offset(-padding.bottom);
        make.width.equalTo(@40);
    }];
    
    //switch team BarButtonItem
    self.customTeamButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.customTeamButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.customTeamButton.showsTouchWhenHighlighted = YES;
    self.customTeamButton.adjustsImageWhenHighlighted = YES;
    [self.customTeamButton setFrame:CGRectMake(0, 0, 28, 28)];
    [self.customTeamButton setBackgroundImage:[UIImage imageNamed:@"SwitchTeam"] forState:UIControlStateNormal];
    [self.customTeamButton addTarget:self action:@selector(switchTeam:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat dotViewHeight = 14.0;
    self.dotView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon-unread"]];
    [self.dotView setFrame:CGRectMake(28-dotViewHeight, -5, dotViewHeight, dotViewHeight)];
    self.dotView.hidden = YES;
    self.dotView.layer.masksToBounds = YES;
    self.dotView.layer.cornerRadius = self.dotView.frame.size.height/2.0;
    [self.customTeamButton addSubview:self.dotView];
    
    self.customTeamButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titleView addSubview:self.customTeamButton];
    [self.customTeamButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleView.mas_centerY);
        make.leading.equalTo(self.titleView.mas_leading).with.offset(padding.left);
    }];
    
    self.rightClickRegion = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightClickRegion.showsTouchWhenHighlighted = YES;
    self.rightClickRegion.adjustsImageWhenHighlighted = YES;
    [self.rightClickRegion setBackgroundColor:[UIColor clearColor]];
    [self.titleView addSubview:self.rightClickRegion];
    [self.rightClickRegion mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_top).with.offset(padding.top); //with is an optional semantic filler
        make.right.equalTo(self.titleView.mas_right).with.offset(padding.left);
        make.bottom.equalTo(self.titleView.mas_bottom).with.offset(-padding.bottom);
        make.width.equalTo(@30);
    }];
    [self.rightClickRegion addTarget:self action:@selector(rightBarButtonItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //me button
    self.rightItemBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.rightItemBtn.layer.masksToBounds = YES;
    self.rightItemBtn.layer.cornerRadius = 14.5;
    self.rightItemBtn.showsTouchWhenHighlighted = YES;
    self.rightItemBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titleView addSubview:self.rightItemBtn];
    [self.rightItemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleView.mas_centerY);
        make.trailing.equalTo(self.titleView.mas_trailing).with.offset(3);
        make.width.equalTo(@29);
        make.height.equalTo(@29);
    }];
    [self.rightItemBtn addTarget:self action:@selector(rightBarButtonItemClick:) forControlEvents:UIControlEventTouchUpInside];
    MOUser *user = [MOUser currentUser];
    if (user) {
        [self.rightItemBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:user.avatarURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avator"] completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            DDLogDebug(@"Success donwload image");
        }];
    }
    
    //set frame
    CGFloat searchBarWidth = kScreenWidth - 30;
    CGRect titleViewFrame = self.titleView.frame;
    titleViewFrame.size.width = searchBarWidth;
    self.titleView.frame = titleViewFrame;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.titleView];
}

- (void)rightBarButtonItemClick:(id)sender {
//    MeTableViewController *viewController = [[UIStoryboard storyboardWithName:@"MeInfo" bundle:nil] instantiateViewControllerWithIdentifier:@"MeTableViewController"];
//    viewController.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:viewController animated:YES];
    AppSettingViewController *viewController = [[UIStoryboard storyboardWithName:@"AppSetting" bundle:nil] instantiateViewControllerWithIdentifier:@"AppSettingViewController"];
    viewController.hasTeamInfo = YES;
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

-(IBAction)switchTeam:(id)sender {
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    MOTeam *currentTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:currentTeamID];
    if ([sender isKindOfClass:[UIButton class]]) {
        SwitchTeamTableViewController *viewController = [[SwitchTeamTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        viewController.currentTeam = currentTeam;
        viewController.currentTeamID = currentTeamID;
        viewController.delegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navigationController.transitioningDelegate = [TBUtility currentAppDelegate].presentTransition;
        [self presentViewController:navigationController animated:YES completion:nil];
    } else {
        ChooseTeamViewController *teamsViewController = [[UIStoryboard storyboardWithName:kLoginStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChooseTeamViewController"];
        UINavigationController *tempNav = [[UINavigationController alloc]initWithRootViewController:teamsViewController];
        [self presentViewController:tempNav animated:YES completion:nil];
    }
}

/**
 *  update avatar
 *
 *  @return nil
 */

- (void)updateAvatar:(NSNotification *)notification {
    NSString *avatarString = [[NSUserDefaults standardUserDefaults]  objectForKey:kCurrentUserAvatar];
    [self.rightItemBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:avatarString] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avator"]];
}

- (void)renderNavigationBar {
    //[self setTeamButtonTitle];
    NSString *avatarString = [[NSUserDefaults standardUserDefaults]  objectForKey:kCurrentUserAvatar];
    [self.rightItemBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:avatarString] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avator"]];
    [self updateOtherTeamUnread];
}

#pragma mark - SyncTeamsDelegate

- (void)finishSyncTeamsWithTeamArray:(NSArray *)teamArray {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *oldMOTeamArray = [MOTeam MR_findAllInContext:localContext];
        NSArray *newTBTeamArray = [MTLJSONAdapter modelsOfClass:[TBTeam class] fromJSONArray:teamArray error:NULL];
        [newTBTeamArray enumerateObjectsUsingBlock:^(TBTeam *team, NSUInteger idx, BOOL *stop) {
            [MTLManagedObjectAdapter
             managedObjectFromModel:team
             insertingIntoContext:localContext
             error:NULL];
        }];
        
        for (MOTeam *oldTeam in oldMOTeamArray) {
            BOOL findInNew = NO;
            for (TBTeam *team in newTBTeamArray) {
                if ([team.id isEqualToString:oldTeam.id]) {
                    findInNew = YES;
                    break;
                }
            }
            
            if (!findInNew) {
                [oldTeam MR_deleteInContext:localContext];
            }
        }
        
    } completion:nil];
}


-(void)updateOtherTeamUnread {
    if ([TBUtility currentAppDelegate].otherTeamUnreadNo > 0 || [TBUtility currentAppDelegate].allNewTeamIdArray.count > 0 || [TBUtility currentAppDelegate].otherTeamHasMuteUnread) {
        self.dotView.hidden = NO;
        [self.customTeamButton bringSubviewToFront:self.dotView];
    } else {
        self.dotView.hidden = YES;
    }
}

- (void)failedFetchRemoteData {
    [self renderNavigationBar];
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


#pragma mark - UINavigationController Delegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    DDLogDebug(@"did show navigationCotnroller");
    if (navigationController.viewControllers.count == 1) {
        [TBUtility currentAppDelegate].currentChatViewController = nil;
        [[TBHTTPSessionManager sharedManager] cancelAllHTTPOperationsWithPath:kSendMessageURLString exceptMethod:@"POST"];
    }
    
    if ([viewController isKindOfClass:[ChatViewController class]]) {
        [[TBHTTPSessionManager sharedManager] cancelAllHTTPOperationsWithPath:kTopicURLString];
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    UINavigationController *searchNavigationController = [[UIStoryboard storyboardWithName:kSearchStoryboard bundle:nil] instantiateInitialViewController];
    searchNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    searchNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:searchNavigationController animated:YES completion:nil];
    return NO;
}

#pragma mark - MultiplePhoneCallDelegate

-(void)selectUserArray:(NSArray *)userArray {
    CallingViewController *callingVC = [[CallingViewController alloc] initWithNibName:@"CallingViewController" bundle:nil];
    [callingVC callGroup:userArray];
    [self presentViewController:callingVC animated:YES completion:nil];
}

@end
