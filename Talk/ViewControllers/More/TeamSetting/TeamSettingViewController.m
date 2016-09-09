//
//  TeamSettingViewController.m
//  Talk
//
//  Created by 史丹青 on 15/4/24.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TeamSettingViewController.h"
#import "SVProgressHUD.h"
#import "TBHTTPSessionManager.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "MOTeam.h"
#import "constants.h"
#import <UIActionSheet+SHActionSheetBlocks.h>
#import "ChangeNameViewController.h"
#import "TopicColorTableViewController.h"
#import "TBTopicColorCell.h"
#import "UIColor+TBColor.h"
#import "TBUtility.h"
#import "ChooseTeamViewController.h"
#import "JLActionSheetViewController.h"
#import "JLSpotlightHelper.h"
#import "TeamQRCodeViewController.h"

@interface TeamSettingViewController () <TopicColorTableViewControllerDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *teamSettingTableView;
@property (strong,nonatomic) NSString *teamName;
@property (strong,nonatomic) NSString *colorStr;
@property (strong,nonatomic) NSString *currentUserID;
@property (strong,nonatomic) MOUser *currentMOMembe;
@property(nonatomic) BOOL couldEditTeam;

@end

@implementation TeamSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Team Settings", @"Team Settings");
    _teamSettingTableView.delegate = self;
    _teamSettingTableView.dataSource = self;
    _teamSettingTableView.backgroundColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1];

    _teamName = self.currentTeam.name;
    _colorStr = self.currentTeam.color;
    _currentUserID = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentUserKey];
    _currentMOMembe = [MOUser findFirstWithId:_currentUserID];
    
    _couldEditTeam = [TBUtility isManagerForCurrentAccount];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTeamName:) name:kEditTeamNameNotification object:nil];
}

#pragma Private Methods

- (void)changeTeamName {
    if (!self.couldEditTeam) {
        return;
    }
    ChangeNameViewController *changeNameVC = [[UIStoryboard storyboardWithName:kMeInfoStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChangeNameViewController"];
    changeNameVC.isEditTeamName = YES;
    changeNameVC.name = _teamName;
    changeNameVC.title = NSLocalizedString(@"Team name", @"Team name");
    [self.navigationController pushViewController:changeNameVC animated:YES];
}

- (void)teamQRcode {
    UIStoryboard *teamStoryboard = [UIStoryboard storyboardWithName:@"AddMemberMethods" bundle:nil];
    TeamQRCodeViewController *teamQRVC = [teamStoryboard instantiateViewControllerWithIdentifier:@"TeamQRCodeViewController"];
    teamQRVC.currentTeamId = _currentTeam.id;
    [self.navigationController pushViewController:teamQRVC animated:YES];
}

- (void)sendTeamInvite {
    NSString *inviteString = [NSString stringWithFormat:NSLocalizedString(@"Team invite text", @"Team invite text"),self.currentTeam.name, self.currentTeam.inviteURL, self.currentTeam.inviteCode];
    JLActionSheetViewController *actionSheet = [[JLActionSheetViewController alloc]init];
    [actionSheet showTeamInviteActionWithMessage:inviteString];
}

//edit Team Name Notification
-(void)updateTeamName:(NSNotification *)notification{
    self.teamName = notification.object;
    [self.teamSettingTableView reloadData];
}

//Alert Leave Team
- (void)AlertLeaveTeam {
    UIActionSheet *actionSheet = [UIActionSheet SH_actionSheetWithTitle:NSLocalizedString(@"Sure exit Team", @"Sure exit Team")];
    [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:nil];
    [actionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Sure", @"Sure") withBlock:^(NSInteger theButtonIndex) {
        [self deleteAndExitTeam];
    }];
    [actionSheet showInView:self.view];
}

/**
 *  delete And exit Team
 */
-(void)deleteAndExitTeam
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Exiting", @"Exiting")];
    
    MOTeam *deleteTBTeam = self.currentTeam;
    
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
                      [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kCurrentTeamID];
                      [[NSUserDefaults standardUserDefaults] synchronize];
                      [JLSpotlightHelper refreshIndexInCurrentTeam];//delete spotlight
                      
                      NSUserDefaults *groupDeafaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
                      [groupDeafaults setValue:nil forKey:kCurrentTeamID];
                      [groupDeafaults synchronize];
                      
                      ChooseTeamViewController *teamsViewController = [[UIStoryboard storyboardWithName:kLoginStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChooseTeamViewController"];
                      [self.navigationController pushViewController:teamsViewController animated:YES];
                  } else {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([self.currentTeam.nonJoinable boolValue]) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellIdentifier1 = @"teamNameSettingCell";
        if (indexPath.row == 0) {
            UITableViewCell *teamNameCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
            if ([_currentMOMembe.role isEqualToString:@"owner"] || [_currentMOMembe.role isEqualToString:@"admin"] ||[self.currentTeam.creatorID isEqualToString:_currentUserID]){
                teamNameCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                teamNameCell.selectionStyle = UITableViewCellSelectionStyleDefault;
            } else{
                teamNameCell.accessoryType = UITableViewCellAccessoryNone;
                teamNameCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            teamNameCell.textLabel.text = NSLocalizedString(@"Team", @"Team");
            teamNameCell.detailTextLabel.text = self.teamName;
            return teamNameCell;
        } else if (indexPath.row == 1) {
            UITableViewCell *teamQRCodeCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
            teamQRCodeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            teamQRCodeCell.textLabel.text = NSLocalizedString(@"QR Code", @"QR Code");
            teamQRCodeCell.detailTextLabel.text = @"";
            return teamQRCodeCell;
        } else {
            UITableViewCell *shareTeamCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
            shareTeamCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            shareTeamCell.textLabel.text = NSLocalizedString(@"Team invite", @"Team invite");
            shareTeamCell.detailTextLabel.text = @"";
            return shareTeamCell;
        }
    }  else {
        static NSString *cellIdentifier =  @"leaveTeamCell";
        UITableViewCell *leaveTeamCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        leaveTeamCell.textLabel.text = NSLocalizedString(@"Exit Team", @"Exit Team");
        return leaveTeamCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.teamSettingTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self changeTeamName];
        } else if (indexPath.row == 1){
            [self teamQRcode];
        } else {
            [self sendTeamInvite];
        }
    } else {
        [self AlertLeaveTeam];
    }
}

#pragma mark - TopicColorTableViewControllerDelegate

-(void)didChangedColor:(NSString *)color
{
    _colorStr = color;
    [self.teamSettingTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
