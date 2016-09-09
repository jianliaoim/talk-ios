//
//  AddMemberViewController.m
//  Talk
//
//  Created by Suric on 14/10/15.
//  Copyright (c) 2014年 jiaoliao. All rights reserved.
//

#import "AddTopicMemberViewController.h"
#import "VENTokenField.h"
#import "VENToken.h"
#import "UIColor+TBColor.h"
#import <Hanzi2Pinyin.h>
#import "AddTopicMemberCell.h"
#import "CoreData+MagicalRecord.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SVProgressHUD.h"
#import "TBHTTPSessionManager.h"
#import "TBUtility.h"
#import "constants.h"
#import <CoreData+MagicalRecord.h>

#import "MORoom.h"
#import "TBUser.h"
#import "MOUser.h"
#import "MOTeam.h"
#import "MOGroup.h"

#import "TBSocketManager.h"
#import "FEMManagedObjectDeserializer.h"
#import "MappingProvider.h"
#import "CallingViewController.h"
#import "TopicsViewController.h"
#import "ContactTableViewController.h"

@interface AddTopicMemberViewController ()<VENTokenFieldDelegate, VENTokenFieldDataSource,UITableViewDataSource,UITableViewDelegate,ChooseGroupDelegate, ContactTableViewControllerChooseDelegate>
@property (weak, nonatomic) IBOutlet VENTokenField *tokenField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneItem;
@property (weak, nonatomic) IBOutlet UITableView *memberTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tokenFieldHeightConstraint;

@property (strong, nonatomic) NSMutableDictionary*allContactsDic;  //all Team members dictionary
@property (strong, nonatomic) NSMutableArray *arrayDictKey;
@property (strong, nonatomic) NSMutableArray *allTokenArray;
@property (strong, nonatomic) NSMutableArray *allSelectedMembers;
@property (strong, nonatomic) NSMutableArray *addedMembers;
@property (strong, nonatomic) NSMutableArray *removedMembers;
@property (assign, nonatomic) BOOL canEdit;

@end

static NSString *TableCellIdentifier = @"AddTopicMemberCell";

@implementation AddTopicMemberViewController

#define TokenFiledDefaultHeight   44.0
#define TokenFieldMaxHeight    150.0
#define CommonMargin            14.0

//sort method
NSInteger NameSort(id user1, id user2, void *context) {
    TBUser *u1,*u2;
    u1 = (TBUser*)user1;
    u2 = (TBUser*)user2;
    return  [u1.name localizedCompare:u2.name];
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self initAndSortMemberData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayOriginSelectedMembers];
    });
    
    self.canEdit = NO;
    if([TBUtility isManagerForCurrentAccount]) {
        self.canEdit = YES;
    }
    if (self.isUpdatingStoryMember) {
        NSString *currentUserKey = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        if ([[TBUtility currentAppDelegate].currentStory.creatorID isEqualToString:currentUserKey]) {
            self.canEdit = YES;
        }
    }
    if (self.isUpdatingRoomMember) {
        NSString *currentUserID = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentUserKey];
        NSString *currentRoomCreatorID = [TBUtility currentAppDelegate].currentRoom.creatorID;
        if ([currentRoomCreatorID isEqualToString:currentUserID]) {
            self.canEdit = YES;
        }
    }
    if (self.isUpdatingMemberGroup) {
        if ([TBUtility isManagerForCurrentAccount]) {
            self.canEdit = YES;
        }
    }
    if (self.isCalling || self.isCreatingStory ||self.isCreatingRoom || self.isCreatingGroup) {
        self.canEdit = YES;
    }
}

- (void)setupUI {
    if (self.isCalling) {
        self.title = NSLocalizedString(@"multiple phone call", @"multiple phone call");
    } else {
        self.title = NSLocalizedString(@"Invite members from team", @"Invite members from team");
    }
    if (self.isCreatingRoom || self.isCreatingStory) {
        self.doneItem.enabled = YES;
    } else {
        self.doneItem.enabled = NO;
    }
    
    //init tokenField
    self.tokenField.delegate = self;
    self.tokenField.dataSource = self;
    self.tokenField.hideToLabel = YES;
    [self.tokenField setColorScheme:[UIColor jl_redColor]];
    [self.tokenField.inputTextField setEnabled:NO];
    
    //init memberTableView
    UINib *nib = [UINib nibWithNibName:TableCellIdentifier bundle:nil];
    [self.memberTableView registerNib:nib forCellReuseIdentifier:TableCellIdentifier];
    [self.memberTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.memberTableView.sectionIndexColor = [UIColor jl_redColor];
    self.memberTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.memberTableView.allowsMultipleSelection = YES;
    self.memberTableView.tableFooterView = [UIView new];
    [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
}

- (void)initAndSortMemberData {
    self.allTokenArray = [NSMutableArray array];
    self.allSelectedMembers = [NSMutableArray array];
    self.addedMembers = [NSMutableArray array];
    self.removedMembers = [NSMutableArray array];
    
    if (self.isCalling && self.currentRoom != nil) {
        [self updateData];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *currentTeamID = [defaults valueForKey:kCurrentTeamID];
        NSArray *memberArray = [MOUser findAllInTeamWithTeamId:currentTeamID containRobot:YES containQuit:NO];
        NSMutableArray *tempAllArray = [NSMutableArray array];
        for (MOUser *tempMOUser in memberArray) {
            if (!tempMOUser.isQuitValue) {
                TBUser *tempTBUser = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:tempMOUser error:NULL];
                [tempAllArray addObject:tempTBUser];
            }
        }
        [tempAllArray sortUsingFunction:NameSort context:NULL];
        
        _arrayDictKey = [[NSMutableArray alloc] init];
        for (TBUser *contact in tempAllArray) {
            NSString *string = [[[Hanzi2Pinyin convertToAbbreviation:contact.name] substringToIndex:1] uppercaseString];
            if (![_arrayDictKey containsObject:string]) {
                [_arrayDictKey addObject:string];
            }
        }
        [_arrayDictKey sortUsingSelector:@selector(localizedCompare:)];
        _allContactsDic = [[NSMutableDictionary alloc] init];
        for (NSString *firstWord in _arrayDictKey) {
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            for (TBUser *contact in tempAllArray) {
                NSString *string = [[[Hanzi2Pinyin convertToAbbreviation:contact.name] substringToIndex:1] uppercaseString];
                if ([string isEqualToString:firstWord])
                {
                    [tempArray addObject:contact];
                }
            }
            [_allContactsDic setValue:tempArray forKey:firstWord];
        }
    }
}

- (void)displayOriginSelectedMembers {
    if (self.isCreatingRoom || self.isCreatingGroup) {
        [self addTokenWithMembers:self.addedTeamMemberArray];
    } else {
        [self addTokenWithMembers:self.currentRoomMembersArray];
    }
}

#pragma mark - IBActions

- (IBAction)cancelAction:(id)sender {
    [self.tokenField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneAction:(id)sender {
    if (self.isCalling || self.isCreatingStory ||self.isCreatingRoom || self.isCreatingGroup) {
        if (self.isCalling) {
            if ([self.phoneCallDelegate respondsToSelector:@selector(selectUserArray:)]) {
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.phoneCallDelegate selectUserArray:self.allSelectedMembers];
            }
        } else if (self.isCreatingStory) {
            NSMutableArray *userIdArray = [NSMutableArray array];
            for (VENToken *tempToken in self.allTokenArray) {
                [userIdArray addObject:tempToken.userId];
            }
            [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            [self.delegate addMemberForNewTopicWith:userIdArray];
        } else if (self.isCreatingRoom || self.isCreatingGroup) {
            if ([self.delegate respondsToSelector:@selector(addMemberForNewTopicWith:)]) {
                [self.delegate addMemberForNewTopicWith:self.allSelectedMembers];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        [self memberUpdateDictionary];
        if (self.isUpdatingStoryMember) {
            [self updateStoryMember];
        } else if (self.isUpdatingMemberGroup) {
            [self updateMemberGroup];
        } else {
            [self updateRoomMember];
        }
    }
}

- (NSDictionary *)memberUpdateDictionary {
    NSMutableArray *allSelectedMemberIds = [NSMutableArray array];
    [self.allSelectedMembers enumerateObjectsUsingBlock:^(TBUser *user, NSUInteger idx, BOOL * _Nonnull stop) {
        [allSelectedMemberIds addObject:user.id];
    }];
    NSMutableArray *currentRoomMemberIds = [NSMutableArray array];
    [self.currentRoomMembersArray enumerateObjectsUsingBlock:^(TBUser *user, NSUInteger idx, BOOL * _Nonnull stop) {
        [currentRoomMemberIds addObject:user.id];
    }];
    NSMutableArray *addMembers = [NSMutableArray arrayWithArray:allSelectedMemberIds];
    NSMutableArray *removeMembers = [NSMutableArray arrayWithArray:currentRoomMemberIds];
    [addMembers removeObjectsInArray:currentRoomMemberIds];
    DDLogDebug(@"addMembers:%@",addMembers);
    [removeMembers removeObjectsInArray:allSelectedMemberIds];
    DDLogDebug(@"removeMembers:%@",removeMembers);
    NSMutableDictionary *updateDictionary = [NSMutableDictionary  dictionary];
    if (addMembers.count > 0) {
        [updateDictionary setObject:addMembers forKey:@"addMembers"];
    }
    if (removeMembers.count > 0) {
        [updateDictionary setObject:removeMembers forKey:@"removeMembers"];
    }
    
    return updateDictionary;
}

- (void)updateStoryMember {
    NSDictionary *paramsDic  = [self memberUpdateDictionary];
    if (paramsDic.count == 0) {
        return;
    }
    
    NSString *storyId = [TBUtility currentAppDelegate].currentStory.id;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
    [[TBHTTPSessionManager sharedManager]PUT:[NSString stringWithFormat:kStoryUpdateURLString,storyId] parameters:paramsDic success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        [self.tokenField resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
        [[TBSocketManager sharedManager] storyUpdateWith:responseObject];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Done")];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

- (void)updateMemberGroup {
    NSDictionary *paramsDic  = [self memberUpdateDictionary];
    if (paramsDic.count == 0) {
        return;
    }
    [[TBHTTPSessionManager sharedManager] PUT:[NSString stringWithFormat:kUpdateGroupURLString, self.currentMemberGroup.id] parameters:paramsDic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [self.tokenField resignFirstResponder];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            MOGroup *localGroup = [self.currentMemberGroup MR_inContext:localContext];
            localGroup.members = responseObject[@"_memberIds"];
        } completion:^(BOOL success, NSError *error) {
            if ([self.delegate respondsToSelector:@selector(addMemberForNewTopicWith:)]) {
                [self.delegate addMemberForNewTopicWith:responseObject[@"_memberIds"]];
            }
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Done")];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

- (void)updateRoomMember {
    NSString *roomID = [TBUtility currentAppDelegate].currentRoom.id;
    NSDictionary *paramsDic = [self memberUpdateDictionary];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
    [[TBHTTPSessionManager sharedManager]PUT:[NSString stringWithFormat:@"%@/%@",kTopicURLString,roomID] parameters:paramsDic success:^(NSURLSessionDataTask *task, id responseObject) {
        [[TBSocketManager sharedManager] roomUpdateWith:responseObject];
        [self dismissViewControllerAnimated:YES completion:nil];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Done")];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

#pragma mark - Private Methods

- (void)fetchData {
    //get topic members
    NSArray *memberArray = [MOUser findTopicMembersExceptSelfAndSortByNameWithTopicId:[TBUtility currentAppDelegate].currentRoom.id];
    //me
    self.currentRoomMembersArray = [NSMutableArray arrayWithArray:memberArray];
    if (!self.isUpdatingMemberGroup) {
        MOUser *Me = [MOUser currentUser];
        if (self.currentRoomMembersArray.count == 0) {
            [self.currentRoomMembersArray addObject:Me];
        } else {
            [self.currentRoomMembersArray insertObject:Me atIndex:0];
        }
    }
    
    _arrayDictKey = [[NSMutableArray alloc] init];
    NSMutableArray *tempAllArray = [NSMutableArray array];
    for (MOUser *tempMOUser in self.currentRoomMembersArray) {
        TBUser *tempTBUser = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:tempMOUser error:NULL];
        [tempAllArray addObject:tempTBUser];
    }
    [tempAllArray sortUsingFunction:NameSort context:NULL];
    for (TBUser *contact in tempAllArray) {
        NSString *string = [[[Hanzi2Pinyin convertToAbbreviation:contact.name] substringToIndex:1] uppercaseString];
        if (![_arrayDictKey containsObject:string]) {
            [_arrayDictKey addObject:string];
        }
    }
    [_arrayDictKey sortUsingSelector:@selector(localizedCompare:)];
    _allContactsDic = [[NSMutableDictionary alloc] init];
    for (NSString *firstWord in _arrayDictKey) {
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for (TBUser *contact in tempAllArray) {
            NSString *string = [[[Hanzi2Pinyin convertToAbbreviation:contact.name] substringToIndex:1] uppercaseString];
            if ([string isEqualToString:firstWord]) {
                [tempArray addObject:contact];
            }
        }
        [_allContactsDic setValue:tempArray forKey:firstWord];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.memberTableView reloadData];
    });
}

-(void)updateData {
    if (self.currentRoomMembersArray.count == 0) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
    }
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:[NSString stringWithFormat:@"%@/%@",kTopicURLString,[TBUtility currentAppDelegate].currentRoom.id]
      parameters:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             // process members data
             NSArray *memberArray   = responseObject[@"members"];
             [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                 NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:[TBUtility currentAppDelegate].currentRoom.id];
                 MORoom *currentRoom = [MORoom MR_findFirstWithPredicate:predicate inContext:localContext];
                 NSArray *previousMemberArray = [MOUser findAllInTopicWithTopicId:currentRoom.id containRobot:NO inContext:localContext];
                 for (MOUser *previousMember in previousMemberArray) {
                     [currentRoom removeMembersObject:previousMember];
                 }
                 
                 NSError *error;
                 NSArray *tbUserArray = [MTLJSONAdapter modelsOfClass:[TBUser class] fromJSONArray:memberArray error:&error];
                 for (TBUser *user in tbUserArray) {
                     MOUser *newMOUSer = [MOUser findFirstWithId:user.id inContext:localContext];
                     if (!newMOUSer) {
                         newMOUSer = [MTLManagedObjectAdapter managedObjectFromModel:user insertingIntoContext:localContext error:&error];
                     }
                     if (!newMOUSer.isGuestValue) {
                         [currentRoom addMembersObject:newMOUSer];
                     }
                 }
                 
             } completion:^(BOOL success, NSError *error) {
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     [self fetchData];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [SVProgressHUD dismiss];
                     });
                 });
             }];
             
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             DDLogError(@"error: %@", error.localizedRecoverySuggestion);
         }];
}

//reload tokenField for data updating
-(void)reloadTokenField {
    [self.tokenField reloadData];
    CGFloat tempScrollViewHeight = self.tokenField.scrollView.contentSize.height>=TokenFieldMaxHeight ?TokenFieldMaxHeight:self.tokenField.scrollView.contentSize.height;
    self.tokenFieldHeightConstraint.constant = tempScrollViewHeight + CommonMargin;
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.7
                        options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:NULL];
}

//click tableViewCell to add email
- (void)addExistedMember:(TBUser*)tempContact andIndex:(NSIndexPath *)indexPath {
    VENToken*tempToken = [[VENToken alloc]init];
    tempToken.tokenText = @"    ";
    tempToken.emailAddress = tempContact.email;
    tempToken.userId = tempContact.id;
    tempToken.memberImageURL = tempContact.avatarURL;
    tempToken.isavatarImage = YES;
    tempToken.indexPath = indexPath;
    [self.allTokenArray addObject:tempToken];
    
    [self reloadTokenField];
    [self.doneItem setEnabled:YES];
}

#pragma mark - VENTokenFieldDataSource && VENTokenFieldDelegate

- (VENToken *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index {
    return self.allTokenArray[index];
}

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField {
    return [self.allTokenArray count];
}

- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField {
    return [NSString stringWithFormat:@"%tu people", [self.allTokenArray count]];
}

- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text {
    VENToken *tempToken = [[VENToken alloc]init];
    tempToken.tokenText = text;
    tempToken.emailAddress = text;
    tempToken.isavatarImage = NO;
    [self.allTokenArray addObject:tempToken];
    
    [self reloadTokenField];
    [self.doneItem setEnabled:YES];
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index {
    VENToken *deleteToken = [self.allTokenArray objectAtIndex:index];
    if (deleteToken.indexPath) {
        AddTopicMemberCell *cell = (AddTopicMemberCell *)[self.memberTableView cellForRowAtIndexPath:deleteToken.indexPath];
        cell.selectedImageView.image= nil;
        TBUser *tempContact;
        if (self.isCalling) {
            tempContact = [[self.allContactsDic objectForKey:[self.arrayDictKey objectAtIndex:deleteToken.indexPath.section]] objectAtIndex:deleteToken.indexPath.row];
        } else {
            tempContact = [[self.allContactsDic objectForKey:[self.arrayDictKey objectAtIndex:deleteToken.indexPath.section - 1]] objectAtIndex:deleteToken.indexPath.row];
        }
        [self.allSelectedMembers removeObject:tempContact];
    }
    [self.allTokenArray removeObjectAtIndex:index];
    [self reloadTokenField];
    if (self.allTokenArray.count == 0) {
        self.doneItem.enabled = NO;
    }
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    if (self.isCalling) {
        return [self.allContactsDic.allKeys count];
    } else {
        return [self.allContactsDic.allKeys count] + 1;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.arrayDictKey;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSInteger count = 0;
    for(NSString *character in self.arrayDictKey) {
        if([character isEqualToString:title]) {
            return count;
        }
        count ++;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.isCalling) {
        return [self.arrayDictKey objectAtIndex:section];
    } else {
        if (section == 0) {
            return NSLocalizedString(@"Choose Group", @"Choose Group");
        } else {
            return [self.arrayDictKey objectAtIndex:section - 1];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isCalling) {
        NSInteger i =  [[self.allContactsDic objectForKey:[self.arrayDictKey objectAtIndex:section]] count];
        return i;
    } else {
        if (section == 0) {
            return 1;
        }
        NSInteger i =  [[self.allContactsDic objectForKey:[self.arrayDictKey objectAtIndex:section - 1]] count];
        return i;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddTopicMemberCell *cell = (AddTopicMemberCell *)[tableview dequeueReusableCellWithIdentifier:@"AddTopicMemberCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectedImageView.hidden = NO;
    
    NSUInteger sectionMy;
    if (self.isCalling) {
        sectionMy = [indexPath section];
    } else {
        if (indexPath.section == 0) {
            cell.nameLable.text = NSLocalizedString(@"Member Groups", @"Member Groups");
            [cell.avatarImageView setImage:[UIImage imageNamed:@"icon-teamsetting"]];
            cell.selectedImageView.hidden = YES;
            cell.userInteractionEnabled = YES;
            return cell;
        }
        sectionMy = [indexPath section] - 1;
    }
    NSUInteger row = indexPath.row;
    TBUser *tempContact = [[self.allContactsDic objectForKey:[self.arrayDictKey objectAtIndex:sectionMy]] objectAtIndex:row];
    cell.selectedImageView.image= nil;
    cell.userInteractionEnabled = YES;
    cell.avatarImageView.alpha = 1.0;
    cell.selectedImageView.alpha = 1.0;
    if (self.isCalling) {
        if (tempContact.phoneForLogin == nil) {
            cell.avatarImageView.alpha = 0.3;
            cell.userInteractionEnabled = NO;
        }
    }
    for (TBUser*existUser in self.allSelectedMembers) {
        if ([existUser.id isEqualToString:tempContact.id]) {
            cell.selectedImageView.image= [UIImage imageNamed:@"icon-member-selecting"];
            cell.userInteractionEnabled = YES;
            break;
        }
    }
    
    BOOL isSelf = [tempContact.id isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey]];
    if (!self.isUpdatingMemberGroup && !self.isCreatingGroup) {
        if (isSelf) {
            [self setCannotUpdateForCell:cell];
        }
    }
    if (isSelf) {
        cell.nameLable.text = [[TBUtility getFinalUserNameWithTBUser:tempContact] stringByAppendingFormat:@"(%@)",NSLocalizedString(@"Me", @"Me")];
    } else {
        cell.nameLable.text = [TBUtility getFinalUserNameWithTBUser:tempContact];
    }
    if (!self.canEdit) {
        for (TBUser*existUser in self.currentRoomMembersArray) {
            if ([existUser.id isEqualToString:tempContact.id]) {
                [self setCannotUpdateForCell:cell];
                break;
            }
        }
    }
    [cell.avatarImageView sd_setImageWithURL:tempContact.avatarURL placeholderImage:[UIImage imageNamed:@"avatar"] options:SDWebImageRefreshCached];
    return cell;
}

- (void)setCannotUpdateForCell:(AddTopicMemberCell *)cell {
    cell.avatarImageView.alpha = 0.3;
    cell.selectedImageView.alpha = 0.3;
    cell.userInteractionEnabled = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.memberTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TBUser *tempContact;
    if (self.isCalling) {
        tempContact = [[self.allContactsDic objectForKey:[self.arrayDictKey objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    } else {
        if (indexPath.section == 0) {
            ContactTableViewController *memberGroupsVC = [[ContactTableViewController alloc] init];
            memberGroupsVC.contactType = TBContactTypeMemberGroup;
            memberGroupsVC.isChoosing = YES;
            memberGroupsVC.isCancelButtonNeedHide = YES;
            memberGroupsVC.delegate = self;
            [self.navigationController pushViewController:memberGroupsVC animated:YES];
            return;
        }
        tempContact = [[self.allContactsDic objectForKey:[self.arrayDictKey objectAtIndex:indexPath.section - 1]] objectAtIndex:indexPath.row];
    }
    
    AddTopicMemberCell *cell = (AddTopicMemberCell *)[self.memberTableView cellForRowAtIndexPath:indexPath];
    if ([self.allSelectedMembers containsObject:tempContact]) {
        [self.allSelectedMembers removeObject:tempContact];
        cell.selectedImageView.image= nil;
        cell.selectedImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        NSInteger indexForCell = -1;
        for (VENToken *tempToken in self.allTokenArray) {
            if (tempToken.indexPath.section == indexPath.section && tempToken.indexPath.row == indexPath.row) {
                indexForCell =[self.allTokenArray indexOfObject:tempToken];
                break;
            }
        }
        if (indexForCell >= 0) {
            [self tokenField:self.tokenField didDeleteTokenAtIndex:indexForCell];
        }
    } else {
        cell.selectedImageView.image= [UIImage imageNamed:@"icon-member-selecting"];
        cell.selectedImageView.backgroundColor = [UIColor whiteColor];
        [self.allSelectedMembers addObject:tempContact];
        [self addExistedMember:tempContact andIndex:indexPath];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tokenField resignFirstResponder];
    });
}

#pragma mark - ChooseGroupDelegate

- (void)haveChoosenGroup:(MORoom *)myGroup {
    [self addUsers:[myGroup.members allObjects]];
}

- (void)didChooseItem:(id)item {
    if ([item isKindOfClass:[MOGroup class]]) {
        MOGroup *group = (MOGroup *)item;
        NSArray *users = [MOUser findUsersWithIds:group.members];
        [self addUsers:users];
    }
}

- (void)addUsers:(NSArray *)users {
    for (MOUser *user in users) {
        if ([user.id isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey]] || [self.currentRoomMembersArray containsObject:user]) {
            continue;
        }
        [self addTokenWithMembers:[NSArray arrayWithObject:user]];
    }
}

- (void)addTokenWithMembers:(NSArray *)members {
    for (NSInteger section = 0; section < self.arrayDictKey.count; section++) {
        NSString *key = [self.arrayDictKey objectAtIndex:section];
        NSInteger rows = [[self.allContactsDic objectForKey:key] count];
        for (NSInteger row = 0; row < rows; row ++) {
            TBUser *tempContact = [[self.allContactsDic objectForKey:[self.arrayDictKey objectAtIndex:section]] objectAtIndex:row];
            for (MOUser *user in members) {
                if ([user.id isEqualToString:tempContact.id] && ![self.allSelectedMembers containsObject:tempContact]) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section+1];
                    AddTopicMemberCell *cell = (AddTopicMemberCell *)[self.memberTableView cellForRowAtIndexPath:indexPath];
                    [self.allSelectedMembers addObject:tempContact];
                    cell.selectedImageView.image= [UIImage imageNamed:@"icon-member-selecting"];
                    if (!self.isCreatingGroup && !self.isUpdatingMemberGroup) {
                        BOOL isSelf = [tempContact.id isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey]];
                        if (isSelf) {
                            cell.selectedImageView.alpha= 0.3;
                        }
                    }
                    [self addExistedMember:tempContact andIndex:indexPath];
                    break;
                }
            }
        }
    }
}

@end
