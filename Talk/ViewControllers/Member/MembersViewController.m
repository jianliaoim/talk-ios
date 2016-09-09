 //
//  MembersViewController.m
//  Talk
//
//  Created by Shire on 9/26/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import "MembersViewController.h"
#import "CoreData+MagicalRecord.h"
#import "constants.h"
#import "TBMemberCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+TBColor.h"
#import "ChatViewController.h"
#import "AddTeamMembersViewController.h"
#import <Hanzi2Pinyin.h>
#import "TBUtility.h"
#import "MeInfoViewController.h"
#import "NSString+Emoji.h"
#import "TBHTTPSessionManager.h"
#import "LeftMembersViewController.h"
#import "ContactTableViewController.h"

#import "TBUser.h"
#import "MOUser.h"
#import "MOTeam.h"
#import "SVProgressHUD.h"
#import "MOInvitation.h"
#import "TBInvitationCell.h"
#import "Talk-Swift.h"
#import "TBMemberInfoView.h"
#import "CallingViewController.h"
#import <SDWebImage/UIButton+WebCache.h>

#import "AddMemberMethodsTableViewController.h"
#import "TopicsViewController.h"
#import "MeTableViewController.h"

static NSString *CellIdentifier = @"TBMemberCell";
static NSString *OnlyCellIdentifier = @"TBMemberOnlyCell";
static NSString *InvitationCellIdentifier = @"TBInvitationCell";

@interface MembersViewController () <RemindViewDelegate, TBMemberInfoViewDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableDictionary*allMembersDic;
@property (strong, nonatomic)NSMutableArray*arrayDictKey;
@property (nonatomic) BOOL isEnteringChatVC;

@property (strong, nonatomic) NSMutableArray *leftMemberArray;
@property (nonatomic) BOOL hasLeftMembers;

@property (strong, nonatomic) RemindView *invitationRemindView;
@property (strong, nonatomic) TBMemberInfoView *memberInfoView;

@property (strong, nonatomic) NSString *chosenInvitationId;
@property (strong, nonatomic) NSIndexPath *chosenInvitationIndexPath;

@property (strong, nonatomic) MOUser *chosenUser;

@end

@implementation MembersViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set navigationBar
    [self.rightClickRegion addTarget:self action:@selector(barButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightItemBtn addTarget:self action:@selector(barButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self commonInit];
    self.leftMemberArray = [NSMutableArray new];
    [self fetchCurrentTeamData];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sortWithName];
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    });
    
    self.tableView.separatorColor = [UIColor tb_tableViewSeperatorColor];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.isEnteringChatVC = NO;
}

- (IBAction)refreshEvent:(id)sender {
    [self.refreshControl beginRefreshing];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshRecentData object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBActions

- (IBAction)barButtonPressed:(UIBarButtonItem *)sender {
    /* TODO: personal page */
}

#pragma mark - Private Methods

- (void)commonInit {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back") style:UIBarButtonItemStylePlain target:nil action:nil];
    self.tableView.rowHeight = TBDefaultCellHeight;
    self.tableView.tableFooterView = [UIView new];
    UINib *nib = [UINib nibWithNibName:CellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    
    self.memberInfoView = (TBMemberInfoView *)[[[NSBundle mainBundle] loadNibNamed:@"TBMemberInfoView" owner:self options:nil] objectAtIndex:0];
    self.memberInfoView.delegate = self;

    // Customise index title style
    self.tableView.sectionIndexColor = [UIColor jl_redColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kBeginFetchTeamData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kTeamDataStored object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kSocketTeamJoin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kSocketTeamLeave object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kSocketInvitationCreate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kSocketInvitationRemove object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editTeamNonjoinableAction:) name:kEditTeamNonJoinableNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kPersonalInfoChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kMemberInfoChangeNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOtherTeamUnread) name:kUpdateOtherTeamUnread object:nil];
}

- (void)fetchCurrentTeamData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentTeamID = [defaults valueForKey:kCurrentTeamID];
    self.dataArray = [NSMutableArray arrayWithArray:[MOUser findAllInTeamWithTeamId:currentTeamID containRobot:YES]];
    
    NSPredicate *invitationFilter = [NSPredicate predicateWithFormat:@"teamId=%@", currentTeamID];
    NSArray *invitationArray = [MOInvitation MR_findAllWithPredicate:invitationFilter];
    [invitationArray enumerateObjectsUsingBlock:^(MOInvitation *obj, NSUInteger idx, BOOL *stop) {
        TBUser *user = [[TBUser alloc] init];
        user.name = obj.name;
        user.id = obj.id;
        [self.dataArray addObject:user];
    }];
    [self renderNavigationBar];
}

- (void)renderNewTeamData {
    [self fetchCurrentTeamData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sortWithName];
        [self.tableView reloadData];
        [self endRefreshingLoading];
    });
}

- (void)failedFetchRemoteData {
    [super failedFetchRemoteData];
    [self renderNewTeamData];
    [self endRefreshingLoading];
}

- (void)endRefreshingLoading {
    [self.refreshControl endRefreshing];
}

-(void)sortWithName {
    DDLogDebug(@"***Sort member data begin");
    //init data and sort
    NSMutableArray *tempAllArray = [NSMutableArray arrayWithArray:self.dataArray];
    [tempAllArray sortUsingFunction:UserNameSort context:NULL];
    
    //deal for manager and self
    NSMutableArray *managerArray = [[NSMutableArray alloc]init];
    
    _arrayDictKey = [[NSMutableArray alloc] init];
    _allMembersDic = [[NSMutableDictionary alloc] init];
    [self.leftMemberArray removeAllObjects];
    
    for (MOUser *contact in tempAllArray) {
        if ([contact isKindOfClass:[MOUser class]]) {
            if (contact.isQuitValue) {
                [self.leftMemberArray addObject:contact];
                continue;
            }
            if ([contact.role isEqualToString:@"owner"] || [contact.role isEqualToString:@"admin"]) {
                [managerArray addObject:contact];
            }
        }
        
        NSString *string = [NSString getFirstWordWithEmojiForString:[Hanzi2Pinyin convertToAbbreviation:[TBUtility getFinalUserNameWithMOUser:contact]]];
        if (![_arrayDictKey containsObject:string]) {
            [_arrayDictKey addObject:string];
            [_allMembersDic setObject:[NSMutableArray arrayWithObject:contact] forKey:string];
        }  else {
            NSMutableArray *newArray = [_allMembersDic objectForKey:string];
            [newArray addObject:contact];
            [_allMembersDic setObject:newArray forKey:string];
        }
    }
    
    //[tempAllArray removeObjectsInArray:meArray];
    [_arrayDictKey sortUsingSelector:@selector(localizedCompare:)];
    
    //add robot "Talkai"
    MOUser *talkAi = [MOUser TalkAI];
    if (talkAi) {
        if (managerArray.count > 0 ) {
            [managerArray insertObject:talkAi atIndex:0];
        } else {
            [managerArray addObject:talkAi];
        }
    }

    [_arrayDictKey insertObject:NSLocalizedString(@"Manage", @"Manage") atIndex:0];
    
    if (managerArray.count > 0) {
        [_arrayDictKey insertObject:NSLocalizedString(@"Admin", @"Admin") atIndex:1];
        [_allMembersDic setObject:managerArray forKey:NSLocalizedString(@"Admin", @"Admin")];
    }
    
    if (self.leftMemberArray.count > 0) {
        self.hasLeftMembers = YES;
    } else {
        self.hasLeftMembers = NO;
    }
    
    DDLogDebug(@"***Sort member data end");
}

- (void)editTeamNonjoinableAction:(NSNotification *)notification {
    BOOL nonjoinable = [notification.object boolValue];
    if (nonjoinable) {
        //nonjoinable
    } else {
        //joinable
    }
}

#pragma mark-cell selected method

- (void)addMember{
    AddMemberMethodsTableViewController *addVC = [[UIStoryboard storyboardWithName:@"AddMemberMethods" bundle:nil] instantiateViewControllerWithIdentifier:@"addMemberMethods"];
    [addVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)checkMemberGroup {
    ContactTableViewController *viewController = [[ContactTableViewController alloc] init];
    viewController.contactType = TBContactTypeMemberGroup;
    viewController.isCancelButtonNeedHide = YES;
    [viewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)checkLeftMembers{
    LeftMembersViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftMembersViewController"];
    vc.leftMembers = self.leftMemberArray;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)checkMeInfo {
    MeInfoViewController *temMeInfoVC = (MeInfoViewController *)[[UIStoryboard storyboardWithName:kMeInfoStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"MeInfoViewController"];
    temMeInfoVC.user = self.chosenUser;
    temMeInfoVC.isFromSetting = YES;
    temMeInfoVC.renderColor = [UIColor jl_redColor];
    [self.navigationController pushViewController:temMeInfoVC animated:YES];
}

- (void)enterChatWithUser:(MOUser *)selectedUser {
    ChatViewController *tempChatVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    tempChatVC.title = [TBUtility getFinalUserNameWithMOUser:selectedUser];
    tempChatVC.roomType = ChatRoomTypeForTeamMember;
    tempChatVC.currentToMember = selectedUser;
    [TBUtility currentAppDelegate].currentRoom = nil;
    tempChatVC.refreshWhenViewDidLoad = YES;
    [tempChatVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:tempChatVC animated:YES];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    if (self.hasLeftMembers) {
        return [self.allMembersDic count] + 2;
    } else {
        return [self.allMembersDic count] + 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2; //add member & my groups
    }
    if (self.hasLeftMembers && section == tableView.numberOfSections - 1) {
        return 1;
    } else {
        NSInteger i =  [(self.allMembersDic)[(self.arrayDictKey)[(NSUInteger) section]] count];
        return i;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TBDefaultCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == tableView.numberOfSections - 1) {
        return 30;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == tableView.numberOfSections - 1) {
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 30)];
    } else {
        return nil;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *noMeAndManagerKeyArray = [NSMutableArray arrayWithArray:self.arrayDictKey];
    [noMeAndManagerKeyArray removeObject:NSLocalizedString(@"Manage", @"Manage")];
    [noMeAndManagerKeyArray removeObject:NSLocalizedString(@"Admin", @"Admin")];
    [noMeAndManagerKeyArray removeObject:NSLocalizedString(@"Left members", @"Left members")];
    
    return noMeAndManagerKeyArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger count = 0;
    for(NSString *character in self.arrayDictKey)
    {
        if([character isEqualToString:title])
        {
            return count;
        }
        count ++;
    }
    return count + 2;
}

//fix iOS 8.3 bug
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.hasLeftMembers && section == tableView.numberOfSections - 1) {
        return NSLocalizedString(@"Left members", @"Left members");
    } else {
        return (self.arrayDictKey)[(NSUInteger) section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBInvitationCell *invitationCell;
    TBMemberCell *cell;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:OnlyCellIdentifier forIndexPath:indexPath];
            cell.nameLabel.text = NSLocalizedString(@"Member", @"Member");
            cell.cellImageView.contentMode = UIViewContentModeCenter;
            cell.cellImageView.backgroundColor = [UIColor whiteColor];
            [cell.cellImageView setImage:[UIImage imageNamed:@"AddButtonWhite"]];
            return cell;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:OnlyCellIdentifier forIndexPath:indexPath];
            cell.nameLabel.text = NSLocalizedString(@"Member Groups", @"Member Groups");
            cell.cellImageView.contentMode = UIViewContentModeCenter;
            cell.cellImageView.backgroundColor = [UIColor whiteColor];
            [cell.cellImageView setImage:[UIImage imageNamed:@"icon-member-group"]];
            return cell;
        }
    }
    
    if (self.hasLeftMembers && indexPath.section == tableView.numberOfSections - 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:OnlyCellIdentifier forIndexPath:indexPath];
        cell.nameLabel.text = NSLocalizedString(@"Check all left members", @"Check all left members");
        cell.cellImageView.contentMode = UIViewContentModeCenter;
        cell.cellImageView.backgroundColor = [UIColor whiteColor];
        [cell.cellImageView setImage:[UIImage imageNamed:@"icon-leave"]];
        return cell;
    }
    
    // get object with indexPath
    NSString *currentIndex = [self.arrayDictKey objectAtIndex:indexPath.section];
    NSArray *sectionUserArray = [self.allMembersDic objectForKey:currentIndex];
    MOUser *user = [sectionUserArray objectAtIndex:indexPath.row];
    
    if (user.avatarURL) {
        //not invitation
        cell = [tableView dequeueReusableCellWithIdentifier:OnlyCellIdentifier forIndexPath:indexPath];
        cell.cellImageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.cellImageView.backgroundColor = [UIColor tb_imageBorderColor];
        
        NSString *nameString = [TBUtility getFinalUserNameWithMOUser:user];
        if (nameString == nil) {
            nameString = @"";
        }
        NSMutableAttributedString *nameAttrString = [[NSMutableAttributedString alloc] initWithString:nameString
                                                                                           attributes:@{ NSForegroundColorAttributeName : [UIColor tb_otherFileColor],
                                                                                                         NSFontAttributeName : [UIFont systemFontOfSize:17]
                                                                                                         }];
        NSString *roleString = @"";
        if ([user.role isEqualToString:@"owner"]) {
            roleString = NSLocalizedString(@"・Owner", @"・Owner");
        } else if ([user.role isEqualToString:@"admin"]) {
            roleString = NSLocalizedString(@"・Admin", @"・Admin");
        }
        NSAttributedString *roleAttrString = [[NSAttributedString alloc]
                                              initWithString:roleString
                                              attributes:@{
                                                           NSForegroundColorAttributeName : [UIColor tb_textGray],
                                                           NSFontAttributeName : [UIFont systemFontOfSize:14]
                                                           }];
        [nameAttrString appendAttributedString:roleAttrString];
        
        cell.nameLabel.attributedText = nameAttrString;
        [cell.cellImageView  sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:user.avatarURL] andPlaceholderImage:[UIImage imageNamed:@"avatar"] options:0 progress:nil completed:nil];
    } else {
        invitationCell = [tableView dequeueReusableCellWithIdentifier:InvitationCellIdentifier forIndexPath:indexPath];;
        [invitationCell setupCellWithName:user.name];
        return invitationCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor tb_tableHeaderGrayColor];
    header.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    //add member
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self addMember];
        return;
    }
    //member group
    if (indexPath.section == 0 && indexPath.row == 1) {
        [self checkMemberGroup];
        return;
    }
    //left members
    if (self.hasLeftMembers && indexPath.section == tableView.numberOfSections - 1) {
        [self checkLeftMembers];
        return;
    }
    
    // enter chat
    NSString *currentIndex = [self.arrayDictKey objectAtIndex:indexPath.section];
    NSArray *sectionUserArray = [self.allMembersDic objectForKey:currentIndex];
    self.chosenUser = [sectionUserArray objectAtIndex:indexPath.row];
    if (self.chosenUser.avatarURL) {
        if (self.isEnteringChatVC) {
            return;
        }
        NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        if ([self.chosenUser.id isEqualToString:currentUserID]) {
            [self checkMeInfo];
            return;
        }
        [self enterChatWithUser:self.chosenUser];
        self.isEnteringChatVC = YES;
    } else {
        self.invitationRemindView = (RemindView *)[[[NSBundle mainBundle] loadNibNamed:@"RemindView" owner:self options:nil] objectAtIndex:0];
        [self.invitationRemindView showWithTitle:NSLocalizedString(@"This member hasn't sign in Jianliao yet", @"This member hasn't sign in Jianliao yet") reminder:NSLocalizedString(@"You cannot chat to him now, please remind him to use Jianliao first.", @"You cannot chat to him now, please remind him to use Jianliao first.") rightButtonName:NSLocalizedString(@"Delete", @"Delete") color:[UIColor jl_redColor]];
        self.invitationRemindView.delegate = self;
        [self.invitationRemindView setFrame:self.tabBarController.view.frame];
        [self.tabBarController.view addSubview:self.invitationRemindView];
        // get object with indexPath
        NSString *currentIndex = [self.arrayDictKey objectAtIndex:indexPath.section];
        NSArray *sectionUserArray = [self.allMembersDic objectForKey:currentIndex];
        MOUser *user = [sectionUserArray objectAtIndex:indexPath.row];
        self.chosenInvitationId = user.id;
        self.chosenInvitationIndexPath = indexPath;

        self.invitationRemindView.alpha = 0;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.invitationRemindView.alpha = 1;
        } completion:^(BOOL finished) {
            self.invitationRemindView.alpha = 1;
        }];
    }
    
}

#pragma mark - RemindViewDelegate

- (void)clickFinishButtonInRemindView {
    [self.invitationRemindView removeFromSuperview];
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager DELETE:[NSString stringWithFormat:kDeleteInvitationURLString, self.chosenInvitationId] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate *filter = [NSPredicate predicateWithFormat:@"id = %@",self.chosenInvitationId];
            MOInvitation *deleteInvitation = [MOInvitation MR_findFirstWithPredicate:filter inContext:localContext];
            [deleteInvitation MR_deleteEntity];
        } completion:^(BOOL success, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSocketInvitationRemove object:nil];
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Delete Invitation Failed", @"Delete Invitation Failed")];
    }];
    
}

#pragma mark - TBMemberInfoViewDelegate

- (void)clickLeftButtonInTBMemberInfoView {
    [self.memberInfoView removeFromSuperview];
    ChatViewController *tempChatVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    tempChatVC.title = [TBUtility getFinalUserNameWithMOUser:self.chosenUser];
    tempChatVC.roomType = ChatRoomTypeForTeamMember;
    tempChatVC.currentToMember = self.chosenUser;
    [TBUtility currentAppDelegate].currentRoom = nil;
    tempChatVC.refreshWhenViewDidLoad = YES;
    [tempChatVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:tempChatVC animated:YES];
    self.isEnteringChatVC = YES;
}

- (void)clickRightButtonInTBMemberInfoView {
    [self.memberInfoView removeFromSuperview];
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
    MOUser *user = [MOUser findFirstWithId:currentUserID];
    
    if (user.phoneForLogin == nil) {
        BindAccountViewController *bindVC = [[UIStoryboard storyboardWithName:kAppSettingStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"BindAccountViewController"];
        bindVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:bindVC animated:YES];
        return;
    }
    
    if (self.chosenUser.phoneForLogin) {
        CallingViewController *callingVC = [[CallingViewController alloc] initWithNibName:@"CallingViewController" bundle:nil];
        [callingVC callUser:self.chosenUser];
        [self presentViewController:callingVC animated:YES completion:nil];
    } else {
        [self showBindMobileRemindView];
    }
}

#pragma mark - Remind Bind Mobile

- (void)showBindMobileRemindView {
    TBMemberInfoView *remindNoBindPhoneView = (TBMemberInfoView *)[[[NSBundle mainBundle] loadNibNamed:@"TBMemberInfoView" owner:self options:nil] objectAtIndex:0];
    [remindNoBindPhoneView displayOneButton];
    [remindNoBindPhoneView.midButton setTitle:NSLocalizedString(@"Finish", @"Finish") forState:UIControlStateNormal];
    [remindNoBindPhoneView.midButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [remindNoBindPhoneView.dialogView setBackgroundColor:[UIColor tb_blueColor]];
    [remindNoBindPhoneView.midButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
    [remindNoBindPhoneView.userAvator setImage:[UIImage imageNamed:@"bindPhoneRobot"]];
    [remindNoBindPhoneView.userName setTextColor:[UIColor whiteColor]];
    [remindNoBindPhoneView.userName setText:NSLocalizedString(@"No linked mobilephone", @"No linked mobilephone")];
    [remindNoBindPhoneView.userPhone setTextColor:[UIColor whiteColor]];
    [remindNoBindPhoneView.userPhone setText:NSLocalizedString(@"You cannot call him now", @"You cannot call him now")];
    remindNoBindPhoneView.userEmail.hidden = YES;
    [self.tabBarController.view addSubview:remindNoBindPhoneView];
    remindNoBindPhoneView.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        remindNoBindPhoneView.alpha = 1;
    } completion:^(BOOL finished) {
        remindNoBindPhoneView.alpha = 1;
    }];
}

@end
