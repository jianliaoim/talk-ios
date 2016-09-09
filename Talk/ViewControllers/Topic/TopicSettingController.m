//
//  TopicSettingController.m
//  Talk
//
//  Created by Suric on 14/10/15.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "TopicSettingController.h"
#import "EditTopicNameController.h"
#import "constants.h"
#import "AddTopicMemberViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TBUtility.h"
#import "CoreData+MagicalRecord.h"
#import "TBHTTPSessionManager.h"
#import "SVProgressHUD.h"
#import "RecentMessagesViewController.h"
#import "TopicsViewController.h"
#import "MeInfoViewController.h"

#import "TBTopicColorCell.h"
#import "TBTopicSettingMemberCell.h"
#import "TopicColorTableViewController.h"
#import "TBTopicOpenCell.h"
#import "TBMemberCollectionCell.h"
#import "TBMemberCell.h"

#import "MORoom.h"
#import "MOMessage.h"
#import "MOUser.h"
#import "UIActionSheet+SHActionSheetBlocks.h"
#import "TBSocketManager.h"
#import "TBTopicMemberCell.h"
#import "FEMManagedObjectDeserializer.h"
#import "MappingProvider.h"

static NSString * memberCellIdentifier = @"TBTopicMemberCell";

@interface TopicSettingController ()<UIActionSheetDelegate,TBTopicOpenCellDelegate>
@property(nonatomic) BOOL couldEditTopic;
@property(nonatomic,strong) NSMutableArray *currentRoomMembersArray;  //current members for current room
@property (assign, nonatomic) BOOL isManager;
@end

@implementation TopicSettingController

#pragma mark - View LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isStorySetting) {
        self.title = NSLocalizedString(@"Setting", @"Setting");
        NSString *currentUserKey = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        if ([[TBUtility currentAppDelegate].currentStory.creatorID isEqualToString:currentUserKey] || [TBUtility isManagerForCurrentAccount]) {
            self.isManager = YES;
        }
    } else {
        self.title = NSLocalizedString(@"Topic Settings", @"Topic Settings");
    }
    self.topicTintColor = [UIColor jl_redColor];

    UINib *nib = [UINib nibWithNibName:memberCellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:memberCellIdentifier];
    self.tableView.contentInset = UIEdgeInsetsMake(-11, 0, 0, 0);
    self.tableView.separatorColor = [UIColor tb_tableViewSeperatorColor];
    
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentUserKey];
    NSString *currentRoomCreatorID = [TBUtility currentAppDelegate].currentRoom.creatorID;
    MOUser *currentMOMembe = [MOUser findFirstWithId:currentUserID];
    if ([currentMOMembe.role isEqualToString:@"owner"] || [currentMOMembe.role isEqualToString:@"admin"] ||[currentRoomCreatorID isEqualToString:currentUserID]) {
        self.couldEditTopic = YES;
    } else {
        self.couldEditTopic = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchData];
        [self.tableView reloadData];
        if (!self.isStorySetting) {
        [self updateData];
        }
    });
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(succeedInviteRoomMember) name:kSocketRoomJoin object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(succeedInviteRoomMember) name:kSocketRoomLeave object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(editTopicInfo) name:kEditTopicInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadMemberSection) name:kEditStoryNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UITableViewCell *topicNameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    topicNameCell.detailTextLabel.text = [TBUtility getTopicNameWithIsGeneral:[TBUtility currentAppDelegate].currentRoom.isGeneral.boolValue andTopicName:[TBUtility currentAppDelegate].currentRoom.topic];
    
    UITableViewCell *topicTargetCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    NSString *topicTarget = [TBUtility currentAppDelegate].currentRoom.purpose;
    topicTargetCell.detailTextLabel.text = topicTarget;
}

- (void)viewDidDisappear:(BOOL)animated {
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

-(void)updateData {
    if (self.isStorySetting) {
        return;
    }
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
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self fetchData];
                     [self reloadMemberSection];
                     [SVProgressHUD dismiss];
                 });
             }];
             
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             DDLogError(@"error: %@", error.localizedRecoverySuggestion);
         }];
}

- (void)fetchData {
    //get members
    NSArray *memberArray;
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
    if (self.isStorySetting) {
        NSArray *userIds = [TBUtility currentAppDelegate].currentStory.members;
        memberArray = [MOUser findUsersWithIds:userIds NotIncludeIds:@[currentUserID]];
    } else {
        memberArray = [MOUser findTopicMembersExceptSelfAndSortByNameWithTopicId:[TBUtility currentAppDelegate].currentRoom.id];
    }
    //me
    MOUser *Me = [MOUser findFirstWithId:currentUserID];
    self.currentRoomMembersArray = [NSMutableArray arrayWithArray:memberArray];
    if (self.currentRoomMembersArray.count == 0) {
        [self.currentRoomMembersArray addObject:Me];
    } else {
        [self.currentRoomMembersArray insertObject:Me atIndex:0];
    }
}

- (void)editTopicInfo {
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [self fetchData];
    [self reloadMemberSection];
}

- (void)reloadMemberSection {
    [self.tableView beginUpdates];
    if (self.isStorySetting) {
        [self fetchData];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
}

-(void)succeedInviteRoomMember {
    [self fetchData];
    [self reloadMemberSection];
}

- (void)memberCellDeleteAction:(TBButton *)sender {
    UIActionSheet *actionSheet = [UIActionSheet SH_actionSheetWithTitle:nil];
    [actionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Sure", @"Sure") withBlock:^(NSInteger theButtonIndex) {
        if (self.isStorySetting) {
            [self removeUserFromStoryWithUser:sender.indexPath];
        } else {
            [self removeUserFromPrivateTopicWithUser:sender.indexPath];
        }
    }];
    [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:^(NSInteger theButtonIndex) {
    }];
    [actionSheet showInView:self.view];
}

- (void)removeUserFromStoryWithUser:(NSIndexPath *)indexPath {
    MOUser *user = [self.currentRoomMembersArray objectAtIndex:indexPath.row];
    if (!user.id) {
        return;
    }
    MOStory *story = [TBUtility currentAppDelegate].currentStory;
    NSDictionary *parameter = @{@"category":story.category,
                                @"data":story.data,
                                @"removeMembers":@[user.id]};
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager PUT:[NSString stringWithFormat:kStoryUpdateURLString,[TBUtility currentAppDelegate].currentStory.id]
       parameters:parameter
          success:^(NSURLSessionDataTask *task, id responseObject) {
              DDLogVerbose(@"Successfully remove member");
              [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                  //delete member from room
                  MOStory *localStory = [MOStory MR_findFirstByAttribute:@"id" withValue:story.id inContext:localContext];
                  NSMutableArray *members = [localStory.members mutableCopy];
                  [members removeObject:user.id];
                  localStory.members = members.copy;
              } completion:^(BOOL success, NSError *error) {
                  //refresh related data
                  [self.currentRoomMembersArray removeObject:user];
                  [self reloadMemberSection];
              }];
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              DDLogError(@"Error: %@", error.localizedRecoverySuggestion);
              [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
          }];

}

- (void)removeUserFromPrivateTopicWithUser:(NSIndexPath *)indexPath {
    MOUser *user = [self.currentRoomMembersArray objectAtIndex:indexPath.row];
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager POST:[NSString stringWithFormat:KRoomRemoveMemberURLString,[TBUtility currentAppDelegate].currentRoom.id]
       parameters:@{@"_userId" : user.id}
            success:^(NSURLSessionDataTask *task, id responseObject) {
                DDLogVerbose(@"Successfully remove memver");
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                    //delete member from room
                    NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:[TBUtility currentAppDelegate].currentRoom.id];
                    MORoom *currentRoom  =[MORoom MR_findFirstWithPredicate:predicate inContext:localContext];
                    MOUser *currentUser = [MOUser findFirstWithId:user.id inContext:localContext];
                    [currentRoom removeMembersObject:currentUser];
                } completion:^(BOOL success, NSError *error) {
                    //refresh related data
                    [self.currentRoomMembersArray removeObject:user];
                    [self reloadMemberSection];
                }];
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
                DDLogError(@"Error: %@", error.localizedRecoverySuggestion);
                [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
            }];
}

- (void)leaveStory {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Exiting", @"Exiting")];
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager POST:[NSString stringWithFormat:@"stories/%@/leave",[TBUtility currentAppDelegate].currentStory.id]
       parameters:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              DDLogVerbose(@"Successfully leave story");
              [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Succeed", @"Succeed")];
              [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                  MOStory *currentStory = [MOStory MR_findFirstByAttribute:@"id" withValue:[TBUtility currentAppDelegate].currentStory.id inContext:localContext];
                  [currentStory MR_deleteInContext:localContext];
              } completion:^(BOOL success, NSError *error) {
                  if (success) {
                      [[NSNotificationCenter defaultCenter]postNotificationName:kLeaveStorySucceedNotification object:[TBUtility currentAppDelegate].currentStory.id];
                      [self.navigationController popToRootViewControllerAnimated:YES];
                  }
              }];
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              DDLogError(@"Error: %@", error.localizedRecoverySuggestion);
              [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
          }];
}

- (void)deleteStory {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Deleting", @"Deleting")];
    NSString *urlString = [NSString stringWithFormat:kStoryRemoveURLString, [TBUtility currentAppDelegate].currentStory.id];
    [[TBHTTPSessionManager sharedManager] DELETE:urlString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            MOStory *currentStory = [MOStory MR_findFirstByAttribute:@"id" withValue:[TBUtility currentAppDelegate].currentStory.id inContext:localContext];
            if (currentStory) {
                [currentStory MR_deleteInContext:localContext];
            }
        } completion:^(BOOL success, NSError *error) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

- (void)leaveRoom {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Exiting", @"Exiting")];
    
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager POST:[NSString stringWithFormat:@"rooms/%@/leave",[TBUtility currentAppDelegate].currentRoom.id]
       parameters:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              DDLogVerbose(@"Successfully leave topic");
              [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Succeed", @"Succeed")];
              [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                  //leave room
                  NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:[TBUtility currentAppDelegate].currentRoom.id];
                  MORoom *currentRoom  =[MORoom MR_findFirstWithPredicate:predicate inContext:localContext];
                  currentRoom.isQuit = [NSNumber numberWithBool:YES];
                  //delete room messaeg
                  [MOMessage MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"roomID = %@",[TBUtility currentAppDelegate].currentRoom.id ] inContext:localContext];
              } completion:^(BOOL success, NSError *error) {
                  if (success) {
                      //refresh related data
                      [[NSNotificationCenter defaultCenter]postNotificationName:kLeaveRoomSucceedNotification object:[TBUtility currentAppDelegate].currentRoom.id];
                      [self.navigationController popToRootViewControllerAnimated:YES];
                  }
              }];
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              DDLogError(@"Error: %@", error.localizedRecoverySuggestion);
              [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
          }];
}

- (void)archiveRoom {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Archiving", @"Archiving")];
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager POST:[NSString stringWithFormat:@"rooms/%@/archive",[TBUtility currentAppDelegate].currentRoom.id]
       parameters:@{@"isArchived": @YES}
          success:^(NSURLSessionDataTask *task, id responseObject) {
              DDLogVerbose(@"Successfully leave topic");
              [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Succeed", @"Succeed")];
              [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                  NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:[TBUtility currentAppDelegate].currentRoom.id];
                  MORoom *currentRoom  =[MORoom MR_findFirstWithPredicate:predicate inContext:localContext];
                  currentRoom.isArchived = [NSNumber numberWithBool:YES];
                  [MOMessage MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"roomID = %@",[TBUtility currentAppDelegate].currentRoom.id ] inContext:localContext];
              } completion:^(BOOL success, NSError *error) {
                  if (success) {
                      [[NSNotificationCenter defaultCenter]postNotificationName:kArchiveRoomSucceedNotification object:[TBUtility currentAppDelegate].currentRoom.id];
                      [self.navigationController popToRootViewControllerAnimated:YES];
                  }
              }];
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              DDLogError(@"Error: %@", error.localizedRecoverySuggestion);
              [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
          }];
}

- (void)deleteRoom {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Deleting", @"Deleting")];
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager DELETE:[NSString stringWithFormat:@"rooms/%@",[TBUtility currentAppDelegate].currentRoom.id]
         parameters:nil
            success:^(NSURLSessionDataTask *task, id responseObject) {
                DDLogVerbose(@"Successfully leave topic");
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Succeed", @"Succeed")];
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                    NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:[TBUtility currentAppDelegate].currentRoom.id];
                    MORoom *currentRoom  =[MORoom MR_findFirstWithPredicate:predicate inContext:localContext];
                    [currentRoom MR_deleteInContext:localContext];
                    [MOMessage MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"roomID = %@",[TBUtility currentAppDelegate].currentRoom.id ] inContext:localContext];
                } completion:^(BOOL success, NSError *error) {
                    if (success) {
                        [[NSNotificationCenter defaultCenter]postNotificationName:kDeleteRoomSucceedNotification object:[TBUtility currentAppDelegate].currentRoom.id];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                }];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                DDLogError(@"Error: %@", error.localizedRecoverySuggestion);
                [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
            }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isStorySetting) {
        return 2;
    } else {
        if ([TBUtility currentAppDelegate].currentRoom.isGeneral.boolValue) {
            return 2;
        }
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isStorySetting) {
        switch (section) {
            case 0:
                return self.currentRoomMembersArray.count +1;
            case 1: {
                MOStory *currentStory = [TBUtility currentAppDelegate].currentStory;
                BOOL isCreator = [currentStory.creatorID isEqualToString:[MOUser currentUser].id];
                if ([TBUtility isManagerForCurrentAccount] || isCreator) {
                    return 2;
                }
                return 1;
            }
                
            default:
                return 0;
        }
    } else {
        switch (section) {
            case 0:
                return 3;
                break;
            case 1:
                if ([TBUtility currentAppDelegate].currentRoom.isGeneral.boolValue) {
                    return self.currentRoomMembersArray.count;
                }
                return self.currentRoomMembersArray.count +1;
                break;
            case 2: {
                if (self.couldEditTopic) {
                    return 3;
                } else {
                    return 1;
                }
                break;
            }
                
            default:
                return 0;
                break;
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 3) {
        return 44;
    } else {
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 10;
            break;
        case 1:
            return 0;
            break;
        case 2:
            return 10;
            break;
        case 3:
            return 0;
            break;
        default:
            return 0;
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 10;
            break;
        case 1:
            return 0;
            break;
        case 2:
            return 10;
            break;
        case 3:
            return 0;
            break;
        default:
            return 0;
            break;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if (indexPath.section != 2) {
        return;
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (self.isStorySetting) {
        if (indexPath.section == 0) {
            NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
            TBTopicMemberCell *memberCell = [tableView dequeueReusableCellWithIdentifier:memberCellIdentifier forIndexPath:indexPath];
            memberCell.deleteButton.indexPath = indexPath;
            [memberCell.deleteButton addTarget:self action:@selector(memberCellDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
            if (self.isManager) {
                memberCell.deleteButton.hidden = NO;
            } else {
                memberCell.deleteButton.hidden = YES;
            }
            
            if (indexPath.row == self.currentRoomMembersArray.count) {
                memberCell.deleteButton.hidden = YES;
                memberCell.cellImageView.tintColor = self.topicTintColor;
                UIImage *addTemplateImage = [[UIImage imageNamed:@"icon-add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                memberCell.cellImageView.image = addTemplateImage;
                memberCell.nameLabel.textColor = self.topicTintColor;
                memberCell.nameLabel.text = NSLocalizedString(@"Invite members from team", @"Invite members from team");
            } else {
                MOUser *tempUser = [self.currentRoomMembersArray objectAtIndex:indexPath.row];
                memberCell.nameLabel.textColor = [UIColor blackColor];
                memberCell.nameLabel.text = [TBUtility getFinalUserNameWithMOUser:tempUser];
                if ([tempUser.id isEqualToString:currentUserID]) {
                    memberCell.deleteButton.hidden = YES;
                    memberCell.nameLabel.text = NSLocalizedString(@"Me", @"Me");
                }
                if ([[TBUtility currentAppDelegate].currentStory.creatorID isEqualToString:tempUser.id]) {
                    memberCell.deleteButton.hidden = YES;
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
                [memberCell.cellImageView  sd_setImageWithURL:[NSURL URLWithString:tempUser.avatarURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
            }
            return memberCell;
        } else if (indexPath.section == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"deleteRoom" forIndexPath:indexPath];
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"Leave Story", @"Leave Story");
            } else {
                cell.textLabel.text = NSLocalizedString(@"Remove Story", @"Remove Story");
            }
        }
    } else {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"topicName" forIndexPath:indexPath];
                cell.textLabel.text = NSLocalizedString(@"Topic Name", @"Topic Name");
                cell.detailTextLabel.text = [TBUtility getTopicNameWithIsGeneral:[TBUtility currentAppDelegate].currentRoom.isGeneral.boolValue andTopicName:[TBUtility currentAppDelegate].currentRoom.topic];
            } else if(indexPath.row == 1) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"topicTarget" forIndexPath:indexPath];
                cell.textLabel.text = NSLocalizedString(@"Topic Target", @"Topic Target");
                cell.detailTextLabel.text = [TBUtility currentAppDelegate].currentRoom.purpose;
            } else if(indexPath.row == 2) {
                TBTopicOpenCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TBTopicOpenCell" forIndexPath:indexPath];
                cell.nameLabel.text = NSLocalizedString(@"Private Topic", @"Private Topic");
                cell.delegate = self;
                cell.switchType = TBTopicSwitchCellTypeOpen;
                BOOL isOpen = [TBUtility currentAppDelegate].currentRoom.isPrivate.boolValue;
                cell.openSwitch.on = isOpen;
                cell.openSwitch.onTintColor  = self.topicTintColor;
                if (self.couldEditTopic) {
                    cell.openSwitch.enabled = YES;
                } else {
                    cell.openSwitch.enabled = NO;
                }
                if ([TBUtility currentAppDelegate].currentRoom.isGeneral.boolValue) {
                    cell.openSwitch.on = NO;
                    cell.openSwitch.enabled = NO;
                }
                return cell;
            }
            if (self.couldEditTopic || indexPath.row == 0 || indexPath.row == 1) {
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.userInteractionEnabled = YES;
            } else {
                cell.selectionStyle = UITableViewCellEditingStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.userInteractionEnabled = NO;
            }
        } else if (indexPath.section == 1) {
            NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
            TBTopicMemberCell *memberCell = [tableView dequeueReusableCellWithIdentifier:memberCellIdentifier forIndexPath:indexPath];
            memberCell.deleteButton.indexPath = indexPath;
            [memberCell.deleteButton addTarget:self action:@selector(memberCellDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
            if (![TBUtility currentAppDelegate].currentRoom.isGeneralValue && ([TBUtility isManagerForCurrentAccount] ||[[TBUtility currentAppDelegate].currentRoom.creatorID isEqualToString:currentUserID])) {
                memberCell.deleteButton.hidden = NO;
            } else {
                memberCell.deleteButton.hidden = YES;
            }
            
            if (indexPath.row == self.currentRoomMembersArray.count) {
                memberCell.deleteButton.hidden = YES;
                memberCell.cellImageView.tintColor = self.topicTintColor;
                UIImage *addTemplateImage = [[UIImage imageNamed:@"icon-add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                memberCell.cellImageView.image = addTemplateImage;
                memberCell.nameLabel.textColor = self.topicTintColor;
                memberCell.nameLabel.text = NSLocalizedString(@"Invite members from team", @"Invite members from team");
            } else {
                MOUser *tempUser = [self.currentRoomMembersArray objectAtIndex:indexPath.row];
                memberCell.nameLabel.textColor = [UIColor blackColor];
                memberCell.nameLabel.text = [TBUtility getFinalUserNameWithMOUser:tempUser];
                if ([tempUser.id isEqualToString:currentUserID]) {
                    memberCell.deleteButton.hidden = YES;
                    memberCell.nameLabel.text = NSLocalizedString(@"Me", @"Me");
                }
                if ([[TBUtility currentAppDelegate].currentRoom.creatorID isEqualToString:tempUser.id]) {
                    memberCell.deleteButton.hidden = YES;
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
                [memberCell.cellImageView  sd_setImageWithURL:[NSURL URLWithString:tempUser.avatarURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
            }
            return memberCell;
        } else if (indexPath.section == 2) {
            if (self.couldEditTopic) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"deleteRoom" forIndexPath:indexPath];
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.text = NSLocalizedString(@"Leave Topic", nil);
                        cell.textLabel.textColor = [UIColor blackColor];
                        break;
                    case 1:
                        cell.textLabel.text = NSLocalizedString(@"Archive Topic", nil);
                        cell.textLabel.textColor = [UIColor blackColor];
                        break;
                    case 2:
                        cell.textLabel.textColor = [UIColor redColor];
                        cell.textLabel.text = NSLocalizedString(@"Remove Topic", nil);
                        break;
                    default:
                        break;
                }
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"deleteRoom" forIndexPath:indexPath];
                cell.textLabel.text = NSLocalizedString(@"Leave Topic", nil);
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.isStorySetting) {
        if (indexPath.section == 0) {
            if (indexPath.row == self.currentRoomMembersArray.count) {
                [self addTopicMemberWithType:AddTopicMemberTypeUpdateStory];
            } else {
                [self enterMeInfoWithIndexPath:indexPath];
            }
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                UIActionSheet *actionSheet = [UIActionSheet SH_actionSheetWithTitle:NSLocalizedString(@"Sure exit", @"Sure exit")];
                [actionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Sure", @"Sure") withBlock:^(NSInteger theButtonIndex) {
                    [self leaveStory];
                }];
                [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:nil];
                [actionSheet showInView:self.view];
            } else {
                UIActionSheet *actionSheet = [UIActionSheet SH_actionSheetWithTitle:NSLocalizedString(@"Sure remove", @"Sure remove")];
                [actionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Sure", @"Sure") withBlock:^(NSInteger theButtonIndex) {
                    [self deleteStory];
                }];
                [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:nil];
                [actionSheet showInView:self.view];
            }
        }
    } else {
        if (indexPath.section ==2) {
            UIActionSheet *actionSheet;
            switch (indexPath.row) {
                case 0: {
                    actionSheet = [UIActionSheet SH_actionSheetWithTitle:NSLocalizedString(@"Sure exit", @"Sure exit")];
                    [actionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Sure", @"Sure") withBlock:^(NSInteger theButtonIndex) {
                        [self leaveRoom];
                    }];
                    break;
                }
                case 1: {
                    actionSheet = [UIActionSheet SH_actionSheetWithTitle:NSLocalizedString(@"Archive remind", @"Archive remind")];
                    [actionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Sure", @"Sure") withBlock:^(NSInteger theButtonIndex) {
                        [self archiveRoom];
                    }];
                    break;
                }
                case 2: {
                    actionSheet = [UIActionSheet SH_actionSheetWithTitle:NSLocalizedString(@"Remove topic remind", @"Remove topic remind")];
                    [actionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Sure", @"Sure") withBlock:^(NSInteger theButtonIndex) {
                        [self deleteRoom];
                    }];
                    break;
                }
                default:
                    break;
            }
            [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:nil];
            [actionSheet showInView:self.view];
        } else if (indexPath.section == 1) {
            if (indexPath.row == self.currentRoomMembersArray.count) {
                [self addTopicMemberWithType:AddTopicMemberTypeUpdateTopic];
            } else {
                [self enterMeInfoWithIndexPath:indexPath];
            }
        }
    }
}

- (void)addTopicMemberWithType:(AddTopicMemberType)type {
    UINavigationController *temNav = (UINavigationController *)[[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"addMemberToTopicNav"];
    [temNav setTransitioningDelegate:[TBUtility currentAppDelegate].presentTransition];
    AddTopicMemberViewController *tempVC = (AddTopicMemberViewController *)[temNav.viewControllers objectAtIndex:0];
    switch (type) {
        case AddTopicMemberTypeUpdateTopic:
            tempVC.isUpdatingRoomMember = YES;
            break;
        case AddTopicMemberTypeUpdateStory:
            tempVC.isUpdatingStoryMember = YES;
            break;
        default:
            break;
    }
    tempVC.currentRoomMembersArray = [self.currentRoomMembersArray mutableCopy];
    [self presentViewController:temNav animated:YES completion:nil];
}

- (void)enterMeInfoWithIndexPath:(NSIndexPath *)indexPath {
    MeInfoViewController *temMeInfoVC = (MeInfoViewController *)[[UIStoryboard storyboardWithName:kMeInfoStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"MeInfoViewController"];
    MOUser *selectedUser = [self.currentRoomMembersArray objectAtIndex:indexPath.row];
    temMeInfoVC.user = [[[NSArray arrayWithObject:selectedUser] mutableCopy] objectAtIndex:0];
    temMeInfoVC.isFromSetting = NO;
    temMeInfoVC.renderColor = self.topicTintColor;
    [self.navigationController pushViewController:temMeInfoVC animated:YES];
}

#pragma mark - TBTopicOpenCellDelegate

-(void)openTopicWith:(BOOL) isOpen {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Edit...", @"Edit...")];
    TBTopicOpenCell *topicOpenCell = (TBTopicOpenCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isOpen],@"isPrivate",nil];
    [manager PUT:[NSString stringWithFormat:@"%@/%@",kTopicURLString,[TBUtility currentAppDelegate].currentRoom.id]
      parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             NSDictionary *responseDic = (NSDictionary *)responseObject;
             [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                 NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:[TBUtility currentAppDelegate].currentRoom.id];
                 MORoom *currentRoom  = [MORoom MR_findFirstWithPredicate:predicate inContext:localContext];
                 currentRoom.isPrivateValue = [[responseDic objectForKey:@"isPrivate"] boolValue];
             } completion:^(BOOL success, NSError *error) {
                 if (success) {
                     [TBUtility currentAppDelegate].currentRoom.isPrivate = [NSNumber numberWithBool:[[responseDic objectForKey:@"isPrivate"] boolValue]];
                     [[NSNotificationCenter defaultCenter] postNotificationName:kEditTopicInfoNotification object:nil];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (isOpen) {
                             [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"have opened", nil)];
                         } else {
                             [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"have closed", nil)];
                         }
                     });
                     //update member cells for private topic
                     //[self reloadMemberSection];
                 }
             }];
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             DDLogError(@"error: %@", error.localizedRecoverySuggestion);
             topicOpenCell.openSwitch.on = !isOpen;
             [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
         }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    EditTopicNameController *tempEditTopicVC = (EditTopicNameController *)segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"EditTopicName"]) {
        tempEditTopicVC.isEditingTopicName = YES;
        tempEditTopicVC.title = NSLocalizedString(@"Topic Name", @"Topic Name");
        tempEditTopicVC.nameStr = [TBUtility getTopicNameWithIsGeneral:[TBUtility currentAppDelegate].currentRoom.isGeneral.boolValue andTopicName:[TBUtility currentAppDelegate].currentRoom.topic];
    } else if ([segue.identifier isEqualToString:@"EditTopicTarget"]) {
        tempEditTopicVC.isEditingTopicName = NO;
        tempEditTopicVC.title = NSLocalizedString(@"Topic Target", @"Topic Target");
        tempEditTopicVC.nameStr = [TBUtility currentAppDelegate].currentRoom.purpose;
    }
}

@end
