//
//  GroupSettingViewController.m
//  Talk
//
//  Created by 王卫 on 15/12/24.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "GroupSettingViewController.h"
#import "TBTopicMemberCell.h"
#import "MOGroup.h"
#import "MOUser.h"
#import "TBUtility.h"
#import "TBHTTPSessionManager.h"
#import "AddTopicMemberViewController.h"
#import "EditTopicNameController.h"
#import "SVProgressHUD.h"
#import <CoreData+MagicalRecord.h>
#import <UIImageView+WebCache.h>
#import <ReactiveCocoa.h>

@interface GroupSettingViewController ()<AddTopicMemberViewControllerDelegate>

@property (strong, nonatomic) MOGroup *group;
@property (strong, nonatomic) NSArray *relatedUsersArray;

@end

static NSString *const kMemberCell = @"MemberCellIdentifier";
static NSString *const kNameCell = @"NameCellIdentifier";
static NSString *const kDeleteCell = @"DeleteGroupCellIdentifier";

@implementation GroupSettingViewController

- (instancetype)initWithGroup:(MOGroup *)group {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.group = group;
        self.relatedUsersArray = [MOUser findUsersWithIds:group.members];
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        self.tableView.separatorColor = [UIColor tb_tableViewSeperatorColor];
        self.title = NSLocalizedString(@"Manage Group", @"Manage Group");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TBTopicMemberCell class]) bundle:nil] forCellReuseIdentifier:kMemberCell];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupInfoDidUpdate) name:kEditMemberGroupInfoNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.delegate respondsToSelector:@selector(didUpdateGroupSetting:)]) {
        [self.delegate didUpdateGroupSetting:self.group];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - tableview datasource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([TBUtility isManagerForCurrentAccount]) {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:{
            if ([TBUtility isManagerForCurrentAccount]) {
                return self.relatedUsersArray.count + 1;
            }
            return self.relatedUsersArray.count;
        }
        case 2:{
            return 1;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 0.1;
        case 1:
            return 10;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNameCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kNameCell];
        }
        cell.textLabel.text = NSLocalizedString(@"Member Group Name", @"Member Group Name");
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.text = self.group.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    } else if (indexPath.section == 1) {
        TBTopicMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:kMemberCell forIndexPath:indexPath];
        [cell.deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        if (indexPath.row == self.relatedUsersArray.count) {
            cell.deleteButton.hidden = YES;
            cell.cellImageView.tintColor = [UIColor jl_redColor];
            cell.cellImageView.image = [[UIImage imageNamed:@"icon-add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.nameLabel.text = NSLocalizedString(@"Add members from team", @"Add members from team");
        } else {
            MOUser *user = [self.relatedUsersArray objectAtIndex:indexPath.row];
            cell.deleteButton.hidden = ![TBUtility isManagerForCurrentAccount];
            [cell.cellImageView sd_setImageWithURL:[NSURL URLWithString:user.avatarURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
            cell.nameLabel.text = [TBUtility getFinalUserNameWithMOUser:user];
        }
        return cell;
    } else if (indexPath.section == 2) {
        //Delete Group
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDeleteCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDeleteCell];
        }
        cell.textLabel.text = NSLocalizedString(@"Remove group", @"Remove group");
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor redColor];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && [TBUtility isManagerForCurrentAccount]) {
        [self editGroupName:self.group];
    } else if (indexPath.section == 1 && indexPath.row == self.relatedUsersArray.count) {
        if ([TBUtility isManagerForCurrentAccount]) {
            [self addMembersToGroup:self.group];
        }
    } else if (indexPath.section == 2 && [TBUtility isManagerForCurrentAccount]) {
        [self removeGroupAction:self.group];
    }
}

#pragma mark - update notification 

- (void)groupInfoDidUpdate {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - edit group name

- (void)editGroupName:(MOGroup *)group {
    EditTopicNameController *editNameViewController = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"EditTopicNameController"];
    editNameViewController.isEditingGroupName = YES;
    editNameViewController.group = group;
    editNameViewController.nameStr = group.name;
    editNameViewController.title = NSLocalizedString(@"Group Name", @"Group Name");
    [self.navigationController pushViewController:editNameViewController animated:YES];
}

#pragma mark - remove group

- (void)removeGroupAction:(MOGroup *)group {
    if (!group) {
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Sure to remove group ?", @"Sure to remove group ?") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Sure", @"Sure") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self removeMemberGroup:group];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)removeMemberGroup:(MOGroup *)group {
    [SVProgressHUD showWithStatus:nil];
    [[TBHTTPSessionManager sharedManager] DELETE:[NSString stringWithFormat:kRemoveGroupURLString, group.id] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
       [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
           MOGroup *localGroup = [group MR_inContext:localContext];
           [localGroup MR_deleteInContext:localContext];
       } completion:^(BOOL success, NSError *error) {
           [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success", @"Success")];
           [self.navigationController popViewControllerAnimated:YES];
       }];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}


#pragma mark - remove member

- (void)deleteAction:(id)sender {
    UIView *superView = ((UIView *)sender).superview;
    while (![superView isKindOfClass:[UITableViewCell class]]) {
        superView = superView.superview;
    }
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)superView];
    if (!selectedIndexPath) {
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Sure", @"Sure") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self removeMemberAtIndexPath:selectedIndexPath];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)removeMemberAtIndexPath:(NSIndexPath *)indexPath {
    MOUser *user = [self.relatedUsersArray objectAtIndex:indexPath.row];
    MOGroup *group = self.group;
    if (!user.id) {
        return;
    }
    NSDictionary *parameter = @{@"removeMembers":@[user.id]};
    [[TBHTTPSessionManager sharedManager] PUT:[NSString stringWithFormat:kUpdateGroupURLString, self.group.id] parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogDebug(@"Remove member successfully");
        NSMutableArray *usersArray = self.relatedUsersArray.mutableCopy;
        [usersArray removeObject:user];
        self.relatedUsersArray = usersArray.copy;
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            MOGroup *localGroup = [group MR_inContext:localContext];
            NSMutableArray *members = [localGroup.members mutableCopy];
            [members removeObject:user.id];
            localGroup.members = members.copy;
        }];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

#pragma mark - add members

- (void)addMembersToGroup:(MOGroup *)group {
    UINavigationController *navigationController = (UINavigationController *)[[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"addMemberToTopicNav"];
    [navigationController setTransitioningDelegate:[TBUtility currentAppDelegate].presentTransition];
    AddTopicMemberViewController *addMemberViewController = (AddTopicMemberViewController *)(navigationController.viewControllers.firstObject);
    addMemberViewController.delegate = self;
    addMemberViewController.currentRoomMembersArray = self.relatedUsersArray.mutableCopy;
    addMemberViewController.isUpdatingMemberGroup = YES;
    addMemberViewController.currentMemberGroup = group;
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - AddTopicMemberViewController delegate
- (void)addMemberForNewTopicWith:(NSMutableArray *)tbMemeberArray {
    if (!tbMemeberArray || tbMemeberArray.count == 0) {
        return;
    }
    self.relatedUsersArray = [MOUser findUsersWithIds:tbMemeberArray];
    [self.tableView reloadData];
}

@end















