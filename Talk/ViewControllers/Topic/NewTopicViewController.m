//
//  NewTopicViewController.m
//  Talk
//
//  Created by Shire on 10/20/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import "NewTopicViewController.h"
#import "constants.h"
#import "TBHTTPSessionManager.h"
#import "AddTeamMembersViewController.h"
#import "AddTopicMemberViewController.h"
#import "SVProgressHUD.h"
#import "TBSocketManager.h"
#import "TBTopicColorCell.h"
#import "TBMemberCollectionCell.h"
#import "TBUtility.h"
#import "TBTopicMemberCell.h"
#import "TBTopicOpenCell.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "MOUser.h"
#import "TBTopicOpenCell.h"
#import "TBRoom.h"
#import "MOTeam.h"
#import "MOGroup.h"
#import "TBGroup.h"
#import "Mantle.h"

#define headViewRect     CGRectMake(0, 0, self.tableView.frame.size.width, 50)
static NSString *openCellIdentifier = @"TBTopicOpenCell";
static NSString *memberCellIdentifier = @"TBTopicMemberCell";

@interface NewTopicViewController ()<UIScrollViewDelegate,AddTopicMemberViewControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *topicNameView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property(strong, nonatomic) UIActivityIndicatorView *indicator;
@property(nonatomic,strong) NSMutableArray *currentRoomMembersArray;  // members for  room

- (IBAction)nameChanged:(UITextField *)sender;
- (IBAction)nextPressed:(UIBarButtonItem *)sender;
- (IBAction)cancelPressed:(UIBarButtonItem *)sender;
@end

@implementation NewTopicViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *nib = [UINib nibWithNibName:memberCellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:memberCellIdentifier];
    self.tableView.separatorColor = [UIColor tb_tableViewSeperatorColor];
    self.nameField.delegate = self;
    self.nameField.tintColor = [UIColor jl_redColor];
    [self commonInit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.nameField.text.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.nameField becomeFirstResponder];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions

- (IBAction)nameChanged:(UITextField *)sender {
    self.navigationItem.rightBarButtonItem.enabled = !EMPTY_STRING(sender.text);
}

//create new topic story
- (IBAction)nextPressed:(UIBarButtonItem *)sender {
    [self.nameField resignFirstResponder];
    if (self.isMemberGroup) {
        [self createMemberGroup];
    } else {
        [self createTopic];
    }
}

- (void)createTopic {
    NSPredicate *roomPredicate = [NSPredicate predicateWithFormat:@"topic = %@", self.nameField.text];
    MORoom *existRoom = [MORoom MR_findFirstWithPredicate:roomPredicate];
    if (existRoom) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"topic name exists", @"topic name exists")];
        [self.nameField becomeFirstResponder];
        return;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicator];
    [self.indicator startAnimating];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *teamID = [defaults valueForKey:kCurrentTeamID];
    NSMutableArray *userIdArray = [NSMutableArray array];
    [self.currentRoomMembersArray enumerateObjectsUsingBlock:^(TBUser *tempTBUser, NSUInteger idx, BOOL *stop) {
        if (![tempTBUser.id isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey]]) {
            [userIdArray addObject:tempTBUser.id];
        }
    }];
    TBTopicOpenCell *tempCell = (TBTopicOpenCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    BOOL isPrivate = tempCell.openSwitch.on;
    NSDictionary *param = @{
                            @"_teamId":teamID,
                            @"topic":self.nameField.text,
                            @"_memberIds":userIdArray,
                            @"isPrivate":[NSNumber numberWithBool:isPrivate]
                            };
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager POST:kTopicURLString parameters:param success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        DDLogVerbose(@"Successfully created topic");
        __block NSError *error;
        TBRoom *newTBRoom  =[MTLJSONAdapter modelOfClass:[TBRoom class] fromJSONDictionary:responseObject error:NULL];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            // Get current team data
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *teamID = [defaults valueForKey:kCurrentTeamID];
            MOTeam *moTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:teamID inContext:localContext];
            MORoom *newMORoom = [MTLManagedObjectAdapter managedObjectFromModel:newTBRoom insertingIntoContext:localContext error:&error];
            newMORoom.isQuitValue = NO;
            [moTeam addRoomsObject:newMORoom];
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                [self dismissViewControllerAnimated:YES completion:nil];
                NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:newTBRoom.id];
                MORoom *tempMORoom = [MORoom MR_findFirstWithPredicate:predicate];
                [[NSNotificationCenter defaultCenter] postNotificationName:kSocketRoomCreate object:tempMORoom];
                [[NSNotificationCenter defaultCenter] postNotificationName:kSocketRoomCreateBySelf object:tempMORoom];
            } else if (error) {
                DDLogDebug(@"Error saved socket new room: %@", error.description);
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"error: %@", error.localizedRecoverySuggestion);
        [self.indicator stopAnimating];
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

- (void)createMemberGroup {
    NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"name = %@", self.nameField.text];
    MORoom *existGroup = [MOGroup MR_findFirstWithPredicate:groupPredicate];
    if (existGroup) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"group name exists", @"group name exists")];
        [self.nameField becomeFirstResponder];
        return;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicator];
    [self.indicator startAnimating];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *teamID = [defaults valueForKey:kCurrentTeamID];
    
    NSMutableArray *userIdArray = [NSMutableArray array];
    [self.currentRoomMembersArray enumerateObjectsUsingBlock:^(TBUser *tempTBUser, NSUInteger idx, BOOL *stop) {
        [userIdArray addObject:tempTBUser.id];
    }];
    
    NSDictionary *param = @{
                            @"_teamId":teamID,
                            @"name":self.nameField.text,
                            @"_memberIds":userIdArray
                            };
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager POST:kCreateGroupURLString parameters:param success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        DDLogVerbose(@"Successfully created group:%@", responseObject);
        TBGroup *newGroup = [MTLJSONAdapter modelOfClass:[TBGroup class] fromJSONDictionary:responseObject error:nil];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [MTLManagedObjectAdapter managedObjectFromModel:newGroup insertingIntoContext:localContext error:nil];
        }];
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(didCreateMemberGroup:)]) {
                [self.delegate didCreateMemberGroup:nil];
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"error: %@", error.localizedRecoverySuggestion);
        [self.indicator stopAnimating];
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender {
    [self.nameField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)commonInit {
    if (self.isMemberGroup) {
        self.title = NSLocalizedString(@"Add Member Group", @"Add Member Group");
        self.nameField.placeholder = NSLocalizedString(@"Member Group Name", @"Member Group Name");
    } else {
        self.title = NSLocalizedString(@"Add new topic", @"Add new topic");
        self.nameField.placeholder = NSLocalizedString(@"Topic Name", @"Topic Name");
    }
    
    self.topicNameView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.topicNameView.layer.shadowOpacity = 0.2;
    self.topicNameView.layer.shadowOffset = CGSizeMake(0, 0);
    
    UIView *headerView = [[UIView alloc] initWithFrame:headViewRect];
    [headerView addSubview:self.topicNameView];
    self.tableView.tableHeaderView = headerView;
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    MOUser *currentMoUser = [MOUser currentUser];
    TBUser *currentTBUser = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:currentMoUser error:NULL];
    self.currentRoomMembersArray = [NSMutableArray array];
    if (!self.isMemberGroup) {
        [self.currentRoomMembersArray addObject:currentTBUser];
    }
}


- (void)navToInvitation:(MORoom *)newRoom {
    NSString *roomID = newRoom.id;
    NSMutableArray *userIdArray = [NSMutableArray array];
    [self.currentRoomMembersArray enumerateObjectsUsingBlock:^(TBUser *tempTBUser, NSUInteger idx, BOOL *stop) {
        if (![tempTBUser.id isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey]]) {
            [userIdArray addObject:tempTBUser.id];
        }
    }];

    NSDictionary *paramsDic  =[NSDictionary dictionaryWithObjectsAndKeys:userIdArray,@"_userIds",nil];
    [[TBHTTPSessionManager sharedManager]POST:[NSString stringWithFormat:@"%@/%@/%@",kTopicURLString,roomID,kAddTopicMemberURLString] parameters:paramsDic success:^(NSURLSessionDataTask *task, id responseObject) {
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(successCreateRoom:)]) {
                [self.delegate successCreateRoom:newRoom];
            }
        }];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Done")];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

- (NSInteger)memberSection {
    if (self.isMemberGroup) {
        return 0;
    } else {
        return 1;
    }
}

- (void)addMemberToTopic {
    UINavigationController *temNav = (UINavigationController *)[[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"addMemberToTopicNav"];
    [temNav setTransitioningDelegate:[TBUtility currentAppDelegate].presentTransition];
    AddTopicMemberViewController *tempVC = (AddTopicMemberViewController *)[temNav.viewControllers objectAtIndex:0];
    NSMutableArray *tempAddedArray = [[NSMutableArray alloc]init];
    [tempAddedArray addObjectsFromArray:self.currentRoomMembersArray];
    tempVC.addedTeamMemberArray = tempAddedArray;
    tempVC.title = NSLocalizedString(@"Member", @"Member") ;
    if (self.isMemberGroup) {
        tempVC.isCreatingGroup = YES;
    } else {
        tempVC.isCreatingRoom = YES;
    }
    tempVC.delegate = self;
    [self presentViewController:temNav animated:YES completion:nil];
}

#pragma mark - AddTopicMemberViewControllerDelegate

- (void)addMemberForNewTopicWith:(NSMutableArray *)tbMemeberArray {
    NSArray *tempMemberArray = [NSArray arrayWithArray:tbMemeberArray];
    [self.currentRoomMembersArray removeAllObjects];
    [self.currentRoomMembersArray addObjectsFromArray:tempMemberArray];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[self memberSection]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect tempRect = headViewRect;
    tempRect.origin.y = headViewRect.origin.y + scrollView.contentOffset.y;
    self.topicNameView.frame = tempRect;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.nameField resignFirstResponder];
    });
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameField) {
        [self.nameField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isMemberGroup) {
        return 1;
    } else {
        return 2;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isMemberGroup) {
        switch (section) {
            case 0: {
                return self.currentRoomMembersArray.count +1;;
            }
            default:
                return 0;
        }
    } else {
        switch (section) {
            case 0:
                return 1;
                break;
            case 1:
                return self.currentRoomMembersArray.count +1;;
                break;
            default:
                return 0;
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

//fix iOS 8.3 bug
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isMemberGroup) {
        TBTopicMemberCell *memberCell = [tableView dequeueReusableCellWithIdentifier:memberCellIdentifier forIndexPath:indexPath];
        [self setupMemberCell:memberCell AtIndexPath:indexPath];
        return memberCell;
    } else {
        if (indexPath.section == 0) {
            TBTopicOpenCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TBTopicOpenCell" forIndexPath:indexPath];
            cell.nameLabel.text = NSLocalizedString(@"Private Topic", @"Private Topic");
            cell.openSwitch.onTintColor = [UIColor jl_redColor];
            return cell;
        } else {
            TBTopicMemberCell *memberCell = [tableView dequeueReusableCellWithIdentifier:memberCellIdentifier forIndexPath:indexPath];
            [self setupMemberCell:memberCell AtIndexPath:indexPath];
            return memberCell;
        }
    }
}

- (void)setupMemberCell:(TBTopicMemberCell *)memberCell AtIndexPath:(NSIndexPath *)indexPath {
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
    memberCell.deleteButton.hidden = YES;
    if (indexPath.row == self.currentRoomMembersArray.count) {
        memberCell.deleteButton.hidden = YES;
        
        memberCell.cellImageView.tintColor = [UIColor jl_redColor];
        UIImage *addTemplateImage = [[UIImage imageNamed:@"icon-add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        memberCell.cellImageView.image = addTemplateImage;
        
        memberCell.nameLabel.textColor = [UIColor jl_redColor];
        memberCell.nameLabel.text = NSLocalizedString(@"Invite members from team", @"Invite members from team");
    } else {
        TBUser *tempUser = [self.currentRoomMembersArray objectAtIndex:indexPath.row];
        memberCell.nameLabel.textColor = [UIColor blackColor];
        memberCell.nameLabel.text = [TBUtility getFinalUserNameWithTBUser:tempUser];
        if ([tempUser.id isEqualToString:currentUserID]) {
            memberCell.nameLabel.text = NSLocalizedString(@"Me", @"Me");
            NSMutableAttributedString *nameAttrString = [[NSMutableAttributedString alloc] initWithString:memberCell.nameLabel.text];
            NSString *roleString = NSLocalizedString(@"Creator", @"Creator");
            NSAttributedString *roleAttrString = [[NSAttributedString alloc]
                                                  initWithString:roleString
                                                  attributes:@{
                                                               NSForegroundColorAttributeName : [UIColor tb_textGray],
                                                               NSFontAttributeName : memberCell.nameLabel.font
                                                               }];
            [nameAttrString appendAttributedString:roleAttrString];
            memberCell.nameLabel.attributedText = nameAttrString;
        }
        [memberCell.cellImageView  sd_setImageWithURL:tempUser.avatarURL placeholderImage:[UIImage imageNamed:@"avatar"]];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == [self memberSection] && indexPath.row == self.currentRoomMembersArray.count) {
        [self addMemberToTopic];
    }
}

@end
