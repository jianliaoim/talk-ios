//
//  ChooseTeamViewController.m
//  Talk
//
//  Created by 史丹青 on 15/4/30.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "ChooseTeamViewController.h"
#import "TBHTTPSessionManager.h"
#import "TBTeam.h"
#import "constants.h"
#import "MOTeam.h"
#import "CoreData+MagicalRecord.h"
#import "UIColor+TBColor.h"
#import "RootViewController.h"
#import "SVProgressHUD.h"
#import "TBUtility.h"
#import "TBTeamCell.h"
#import "UIView+TBSnapshotView.h"
#import "UIImage+ImageEffects.h"
#import <M13BadgeView.h>
#import "MOUser.h"
#import "TBUser.h"
#import "NewTeamViewController.h"
#import "NSString+Emoji.h"
#import "AppSettingViewController.h"
#import "UIActionSheet+SHActionSheetBlocks.h"
#import "TalkGuideView.h"
#import "AddTeamCell.h"
#import "JLAccountHelper.h"
#import "SyncTeamsViewController.h"

static NSString *CellIdentifier = @"TBTeamCell";
static NSString *AddTeamIdentifier = @"AddTeamCell";

@interface ChooseTeamViewController () <UIActionSheetDelegate,UIScrollViewDelegate,SyncTeamsDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UIView *userInfoView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation ChooseTeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kCurrentTeamID] == nil) {
        [self.navigationItem setHidesBackButton:YES animated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataForCreateTeam) name:kTeamCreateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataForNewTeam) name:kNewTeamSavedNotification object:nil];
    
    [self commonInit];
    
    [self.refreshControl setTintColor:[UIColor blackColor]];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"please wait...", @"please wait...")];
    [self syncData];
    
    self.userInfoView.backgroundColor = [UIColor jl_redColor];
    self.userAvatar.layer.masksToBounds = YES;
    self.userAvatar.layer.cornerRadius = 40;
    self.userAvatar.layer.borderWidth = 2;
    self.userAvatar.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    //tap
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvator:)];
    [self.userAvatar addGestureRecognizer:singleTap];
    [self.userAvatar setUserInteractionEnabled:YES];
    
    UINib *nib = [UINib nibWithNibName:CellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    self.userName.text = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentUserName];
    [self.userAvatar sd_setImageWithURL:[[NSUserDefaults standardUserDefaults]objectForKey:kCurrentUserAvatar] placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    //check invite code
    [self checkInviteCode];
}

- (void)checkInviteCode {
    NSString *inviteCode = [TBUtility currentAppDelegate].inviteCode;
    if (inviteCode.length > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTeamLinkInviteNotification object:inviteCode];
        [TBUtility currentAppDelegate].inviteCode = @"";
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //self.navigationController.navigationBar.barTintColor = [UIColor tb_defaultColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.shadowImage = nil;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBAction

- (IBAction)tapAvator:(id)sender {
    AppSettingViewController *settingVC = [[UIStoryboard storyboardWithName:kAppSettingStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"AppSettingViewController"];
    [settingVC setHasTeamInfo:NO];
    [self.navigationController pushViewController:settingVC animated:YES];
}

#pragma mark - Private Methods

- (void)commonInit {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UINib *nib = [UINib nibWithNibName:CellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    tableViewController.refreshControl = self.refreshControl;
    [self.refreshControl addTarget:self action:@selector(syncData) forControlEvents:UIControlEventValueChanged];
    
}

- (void)fetchLocalData {
    self.dataArray = [NSMutableArray arrayWithArray:[MOTeam MR_findAllSortedBy:@"unread,updatedAt" ascending:NO]];

}

- (void)syncData {
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:kTeamURLString
      parameters:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             DDLogVerbose(@"teams data: %@", responseObject);
             if ([SVProgressHUD isVisible]) {
                 [SVProgressHUD dismiss];
             }
             [self processData:responseObject];
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             DDLogError(@"error: %@", error.localizedRecoverySuggestion);
             if ([SVProgressHUD isVisible]) {
                 [SVProgressHUD dismiss];
             }
             [self executeCompleteOperation];
             [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
         }];
    
    [manager GET:kMeInfoURLString parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        DDLogVerbose(@"user data: %@", responseObject);
        [JLAccountHelper updateUserDataWithResponse:responseObject];
        self.userName.text = responseObject[@"name"];
        [[NSUserDefaults standardUserDefaults] setValue:responseObject[@"name"] forKey:kCurrentUserName];
        [self.userAvatar sd_setImageWithURL:responseObject[@"avatarUrl"] placeholderImage:[UIImage imageNamed:@"avatar"]];
        [[NSUserDefaults standardUserDefaults] setValue:responseObject[@"avatarUrl"] forKey:kCurrentUserAvatar];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

- (void)processData:(NSArray *)responseObject {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *oldMOTeamArray = [MOTeam MR_findAllInContext:localContext];
        NSArray *newTBTeamArray = [MTLJSONAdapter modelsOfClass:[TBTeam class] fromJSONArray:responseObject error:NULL];
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
        
    } completion:^(BOOL success, NSError *error) {
        [self fetchLocalData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self executeCompleteOperation];
        });
    }];
}

- (void)executeCompleteOperation {
    [self.refreshControl endRefreshing];
}

-(void)refreshDataForCreateTeam
{
    [self fetchLocalData];
    [self.tableView reloadData];
    //self.navigationController.navigationBarHidden = YES;
}

- (void)refreshDataForNewTeam {
    [self fetchLocalData];
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

/**
 *  delete And exit Team
 */
-(void)deleteAndExitTeamWithIndexPath:(NSIndexPath *)indexPath
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Exiting", @"Exiting")];
    MOTeam *moTeam = self.dataArray[(NSUInteger) indexPath.row];
    TBTeam *deleteTBTeam = [MTLManagedObjectAdapter modelOfClass:[TBTeam class] fromManagedObject:moTeam error:NULL];
    
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager POST:[NSString stringWithFormat:@"teams/%@/leave",deleteTBTeam.id]
       parameters:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              DDLogVerbose(@"Successfully leave topic");
              [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                  MOTeam *deleleMOTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:deleteTBTeam.id inContext:localContext];
                  [deleleMOTeam MR_deleteInContext:localContext];
              } completion:^(BOOL success, NSError *error) {
                  if (success) {
                      DDLogDebug(@"success delete Team");
                      [SVProgressHUD dismiss];
                      
                      [self.dataArray removeObject:moTeam];
                      [self.tableView beginUpdates];
                      [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                      [self.tableView endUpdates];
                  }
                  else
                  {
                      DDLogDebug(error.localizedDescription);
                      [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
                  }
              }];
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              DDLogError(@"Error: %@", error.localizedRecoverySuggestion);
              [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
          }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.dataArray.count > 0) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray.count > 0) {
        if (section == 0) {
            return self.dataArray.count;
        } else {
            return 3;
        }
    } else {
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return 0;
    } else {
        return 10;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 5)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
        [footerView setBackgroundColor:[UIColor clearColor]];
        
        if (self.dataArray.count > 0) {
            UIView *footerAboveView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, tableView.bounds.size.width, 1)];
            [footerAboveView setBackgroundColor:[UIColor colorWithRed:238/255.f green:238/255.f blue:238/255.f alpha:1]];
            [footerView addSubview:footerAboveView];
        }
        
        return footerView;
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 || self.dataArray.count == 0) {
        
        AddTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:AddTeamIdentifier forIndexPath:indexPath];
        
        switch (indexPath.row) {
            case 0:
                [cell setCellWithImageName:@"icon-team-add" andTitle:NSLocalizedString(@"Create a new team", @"Create a new team") andDescription:NSLocalizedString(@"Create a team for you" , @"Create a team for you" )];
                break;
                
            case 1:
                [cell setCellWithImageName:@"icon-scan" andTitle:NSLocalizedString(@"Scan to join a team", @"Scan to join a team") andDescription:NSLocalizedString(@"Scan to join a existing team", @"Scan to join a existing team")];
                break;
                
            case 2:
                [cell setCellWithImageName:@"icon-sync" andTitle:NSLocalizedString(@"Sync from Teambition", @"Sync from Teambition") andDescription:NSLocalizedString(@"Sync Teambition team", @"Sync Teambition team")];
                break;
                
            default:
                break;
        }

        return cell;
    }
    
    TBTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.badgeButton.hidden = YES;
    cell.dotView.hidden = YES;
    // Get object at indexPath
    MOTeam *team = self.dataArray[(NSUInteger) indexPath.row];
    cell.nameLabel.text = team.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    cell.cellImageView.image = [UIImage imageNamed:@"icon-teamlogo-gray"];
    cell.InitialNameLabel.hidden = YES;
    cell.teambitionLogo.hidden = YES;
    
    //unread
    if (team.unread.intValue > 0 ) {
        NSString *unreadNumber = [NSString stringWithFormat:@"%@",team.unread];
        [cell.badgeButton setTitle:unreadNumber forState:UIControlStateNormal];
        cell.badgeButton.hidden = NO;
        cell.badgeButton.enabled = NO;
    }
    else
    {
        if ([[TBUtility currentAppDelegate].allNewTeamIdArray containsObject:team.id] || team.hasUnreadValue) {
            cell.dotView.hidden = NO;
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.dataArray.count > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIActionSheet *deleteActionSheet = [UIActionSheet SH_actionSheetWithTitle:NSLocalizedString(@"Sure exit Team", @"Sure exit Team")];
    [deleteActionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Sure", @"Sure") withBlock:^(NSInteger theButtonIndex) {
        [self deleteAndExitTeamWithIndexPath:indexPath];
    }];
    [deleteActionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:^(NSInteger theButtonIndex) {
        [self.tableView setEditing:NO animated:YES];
    }];
    [deleteActionSheet showInView:self.view];
}

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Exit Team", @"Exit Team");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 || self.dataArray.count == 0) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"addNewTeam" sender:self];
        } else if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"scanQRCode" sender:self];
        } else if (indexPath.row == 2) {
            SyncTeamsViewController *syncVC = [[UIStoryboard storyboardWithName:kLoginStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"SyncTeamsViewController"];
            syncVC.delegate = self;
            [self.navigationController pushViewController:syncVC animated:YES];
        }
    }
    if (indexPath.section == 0 && self.dataArray.count > 0) {
        TBTeam *team = self.dataArray[(NSUInteger) indexPath.row];
        [self enterTeam:team];
    }
}

- (void)enterTeam:(TBTeam *)team {
    //remove team  from all new team
    if ([[TBUtility currentAppDelegate].allNewTeamIdArray containsObject:team.id]) {
        [[TBUtility currentAppDelegate].allNewTeamIdArray removeObject:team.id];
    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[RootViewController class]]) {
        [TBUtility currentAppDelegate].isChangeTeam = YES;
        [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeamKey object:team];
    }
    else
    {
        [TBUtility currentAppDelegate].isChangeTeam = NO;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:team.id forKey:kCurrentTeamID];
        [defaults setValue:team.name forKey:kCurrentTeamName];
        [defaults synchronize];
        
        NSUserDefaults *groupDeafaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
        [groupDeafaults setValue:team.id forKey:kCurrentTeamID];
        [groupDeafaults synchronize];
        
        UINavigationController *tempMainController = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *navRootViewController = tempMainController.viewControllers.firstObject;
        if (navRootViewController.presentedViewController) {
            [UIApplication sharedApplication].keyWindow.rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"RootViewController"];
            [navRootViewController.presentedViewController dismissViewControllerAnimated:NO completion:^{
            }];
        } else {
            [UIApplication sharedApplication].keyWindow.rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"RootViewController"];
        }
    }
}

#pragma mark - SyncTeamsDelegate

- (void)finishSyncTeamsWithTeamArray:(NSArray *)teamArray {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *newTBTeamArray = [MTLJSONAdapter modelsOfClass:[TBTeam class] fromJSONArray:teamArray error:NULL];
        [newTBTeamArray enumerateObjectsUsingBlock:^(TBTeam *team, NSUInteger idx, BOOL *stop) {
            [MTLManagedObjectAdapter
             managedObjectFromModel:team
             insertingIntoContext:localContext
             error:NULL];
        }];
    } completion:^(BOOL success, NSError *error) {
        [self fetchLocalData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)chooseTeamWithSourceId:(NSString *)sourceId {
    MOTeam *moTeam = [MOTeam MR_findFirstByAttribute:@"sourceId" withValue:sourceId];
    if (moTeam) {
        TBTeam *team = [MTLManagedObjectAdapter modelOfClass:[TBTeam class] fromManagedObject:moTeam error:NULL];
        if (team) {
            [self enterTeam:team];
        }
    }
}

@end
