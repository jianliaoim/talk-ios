//
//  TeamActivityTableViewController.m
//  Talk
//
//  Created by Suric on 16/1/29.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "TeamActivityTableViewController.h"
#import "TBHTTPSessionManager.h"
#import "constants.h"
#import "TBUtility.h"
#import "NSDate+TBUtilities.h"
#import "SVProgressHUD.h"
#import "MeTableViewController.h"
#import "ChatViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "PlaceHolderView.h"

#import "TeamActivityCell.h"
#import "TeamActivityDetailCell.h"

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "NSManagedObject+MagicalFinders.h"
#import "MOStory.h"
#import "TBStory.h"
#import "MORoom.h"
#import "TBTeamActivity.h"

static NSString * const TeamActivityCellIdentifier = @"TeamActivityCell";
static NSString * const TeamActivityDetailCellIdentifier = @"TeamActivityDetailCell";
static CGFloat const kActivityFetchLimit = 20;

@interface TeamActivityTableViewController ()
@property (strong, nonatomic) IBOutlet UIView *comingPlaceHolder;
@property (weak, nonatomic) IBOutlet UILabel *comingLabel;
@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;

@property (strong, nonatomic) PlaceHolderView *noActivityPlaceHolder;
@property (assign, nonatomic) BOOL hasAuthority;
@end

@implementation TeamActivityTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.separatorColor = [UIColor tb_tableViewSeperatorColor];
    //[self setMJRefresh];
    self.noActivityPlaceHolder = (PlaceHolderView *)[[[NSBundle mainBundle] loadNibNamed:@"PlaceHolderView" owner:self options:nil] objectAtIndex:0];
    [self.noActivityPlaceHolder setPlaceHolderWithImage:[UIImage imageNamed:@"icon-no-info"] andTitle:NSLocalizedString(@"Soon Online", @"Soon Online") andReminder:@""];
    
    self.allActivityArray = [[NSMutableArray alloc]init];
    
    self.comingLabel.text = NSLocalizedString(@"Team activity coming soon", nil);
    self.introduceLabel.text = NSLocalizedString(@"Team activity introduce", nil);
    [self checkActivityCount];
//    [self loadTeamActivityForRefrsh:NO];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAction:) name:kTeamDataStored object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityCreate:) name:kSocketActivityCreate object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityUpdate:) name:kSocketActivityUpdate object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityRemove:) name:kSocketActivityRemove object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOtherTeamUnread) name:kUpdateOtherTeamUnread object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBActions

- (IBAction)refreshAction:(id)sender {
//    self.hasAuthority = [TBUtility isManagerForCurrentAccount];
//    [self loadTeamActivityForRefrsh:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}

#pragma mark - Private Methods

- (void)loadTeamActivityForRefrsh:(BOOL)isrefresh {
//    if (isrefresh) {
//        [self setMJRefresh];
//    }
//    
//    NSString *teamId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
//    NSDictionary *parameters = @{@"_teamId": teamId, @"limit": [NSNumber numberWithFloat:kActivityFetchLimit]};
//    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
//    [manager GET:kTeamActivityPath parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.refreshControl endRefreshing];
//        });
//        if ([responseObject isKindOfClass:[NSArray class]]) {
//            if (isrefresh) {
//                [self.allActivityArray removeAllObjects];
//            }
//            [self processResponseObject:(NSArray *)responseObject];
//        } else {
//            DDLogError(@"Wrong data type, Please check");
//        }
//    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
//        [self.refreshControl endRefreshing];
//        [TBUtility showMessageInError:error];
//    }];
}

- (void)processResponseObject:(NSArray *)responseObject {
    if (responseObject.count < kActivityFetchLimit) {
        [self.tableView.footer noticeNoMoreData];
    }

    NSError *error = nil;
    NSArray *responseTeamActivityArray = [MTLJSONAdapter modelsOfClass:[TBTeamActivity class] fromJSONArray:responseObject error:&error];
    if (!error) {
        [self.allActivityArray addObjectsFromArray:responseTeamActivityArray];
        [self.tableView reloadData];
    }
    [self checkActivityCount];
}

- (void)checkActivityCount {
    if (self.allActivityArray.count == 0) {
        self.tableView.tableFooterView = self.comingPlaceHolder;
    } else {
        self.tableView.tableFooterView = [UIView new];
    }
}

- (void)alertDeleteAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you Sure", @"Are you Sure") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self deleteTeamActivityAtIndexPath:indexPath];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:OKAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    alertController.view.tintColor = [UIColor blackColor];
}

- (void)deleteTeamActivityAtIndexPath:(NSIndexPath *)indexPath {
    NSString *teamId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    NSDictionary *parameters = @{@"_teamId": teamId};
    TBTeamActivity *deleteTeamActivity = [self.allActivityArray objectAtIndex:indexPath.row];
    NSString *urlPath = [NSString stringWithFormat:@"%@/%@",kTeamActivityPath,deleteTeamActivity.id];
    [[TBHTTPSessionManager sharedManager] DELETE:urlPath parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [self.allActivityArray removeObject:deleteTeamActivity];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self checkActivityCount];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [TBUtility showMessageInError:error];
    }];
}

#pragma mark-LoadMore

- (void)setMJRefresh {
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    // Forbid automatical refresh
    self.tableView.footer.automaticallyRefresh = YES;
    // Set title
    [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
    [self.tableView.footer setTitle:NSLocalizedString(@"Loading more items...", @"Loading more items...") forState:MJRefreshFooterStateRefreshing];
    [self.tableView.footer setTitle:NSLocalizedString(@"", @"") forState:MJRefreshFooterStateNoMoreData];
}

- (void)loadMoreData {
    if (self.allActivityArray.count > 0) {
        TBTeamActivity *lastActivity = [self.allActivityArray lastObject];
        NSString *teamId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
        NSDictionary *parameters = @{@"_teamId": teamId, @"limit": [NSNumber numberWithFloat:kActivityFetchLimit],@"_maxId": lastActivity.id};
        TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
        [manager GET:kTeamActivityPath parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            if ([responseObject isKindOfClass:[NSArray class]]) {
                [self processResponseObject:(NSArray *)responseObject];
            } else {
                DDLogError(@"Wrong data type, Please check");
            }
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            [self.refreshControl endRefreshing];
            [TBUtility showMessageInError:error];
        }];
    }
}

#pragma mark-enter chat

- (void)enterChatWithStory:(MOStory *)selectedMOStory {
    ChatViewController *tempChatVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    tempChatVC.currentStory = selectedMOStory;
    tempChatVC.refreshWhenViewDidLoad = YES;
    tempChatVC.roomType = ChatRoomTypeForStory;
    [TBUtility currentAppDelegate].currentStory = selectedMOStory;
    [self.navigationController pushViewController:tempChatVC animated:YES];
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
}

#pragma mark-socket Notification actions

- (void)activityCreate:(NSNotification *)notiication {
    TBTeamActivity *newActivity = notiication.object;
    NSIndexPath *existIndexPath = [self indexPathForActivity:newActivity];
    if (existIndexPath) {
        return;
    }
    
    if (self.allActivityArray.count == 0) {
        [self.allActivityArray addObject:newActivity];
    } else {
        [self.allActivityArray insertObject:newActivity atIndex:0];
    }
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [self checkActivityCount];
}

- (void)activityUpdate:(NSNotification *)notiication {
    TBTeamActivity *updateActivity = notiication.object;
    NSIndexPath *indexPath = [self indexPathForActivity:updateActivity];
    if (indexPath) {
        [self.allActivityArray replaceObjectAtIndex:indexPath.row withObject:updateActivity];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (NSIndexPath *)indexPathForActivity:(TBTeamActivity *)activity {
    NSUInteger index = -1;
    for (TBTeamActivity *tempActivity in self.allActivityArray) {
        if ([tempActivity.id isEqualToString:activity.id]) {
            index = [self .allActivityArray indexOfObject:tempActivity];
            break;
        }
    }
    if (index != -1) {
        return [NSIndexPath indexPathForRow:index inSection:0];
    } else {
        return nil;
    }
}

- (void)activityRemove:(NSNotification *)notiication {
    TBTeamActivity *removeActivity = notiication.object;
    NSIndexPath *indexPath = [self indexPathForActivity:removeActivity];
    if (indexPath) {
        [self.allActivityArray removeObjectAtIndex:indexPath.row];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    [self checkActivityCount];
}

#pragma mark - Table view data source & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allActivityArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBTeamActivity *teamActivity = [self.allActivityArray objectAtIndex:indexPath.row];
    return teamActivity.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBTeamActivity *teamActivity = [self.allActivityArray objectAtIndex:indexPath.row];

    if (teamActivity.targetId) {
        TeamActivityDetailCell *detailCell = (TeamActivityDetailCell *)[tableView dequeueReusableCellWithIdentifier:TeamActivityDetailCellIdentifier forIndexPath:indexPath];
        detailCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        detailCell.avatarImageView.image = [UIImage imageNamed:teamActivity.imageName];
        detailCell.activityTitleLabel.text = teamActivity.activityTitle;
        detailCell.activityDetailLabel.text = teamActivity.activityDetail;
        detailCell.systemMessageLabel.text = teamActivity.text;
        detailCell.timeLabel.text = [teamActivity.createdAt tb_timeAgo];
        if (teamActivity.imageSize.width) {
            detailCell.activityDetailImageView.hidden = NO;
            detailCell.activityDetailLabel.hidden = YES;
            detailCell.activity = teamActivity;
            [detailCell.activityDetailImageView sd_setImageWithURL:[NSURL URLWithString:teamActivity.thumbnailURLString] placeholderImage:[UIImage imageNamed:@"photoDefault"]];
        } else {
            detailCell.activityDetailImageView.hidden = YES;
            detailCell.activityDetailLabel.hidden = NO;
        }
        return detailCell;
    } else {
        TeamActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:TeamActivityCellIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.avatarImageView.image = [UIImage imageNamed:@"teamActivty-system"];
        cell.systemMessageLabel.text = teamActivity.text;
        cell.timeLabel.text = [teamActivity.createdAt tb_timeAgo];
        return cell;
    }
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
    TBTeamActivity *teamActivity = [self.allActivityArray objectAtIndex:indexPath.row];
    BOOL createdBySelf = [currentUserID isEqualToString:teamActivity.creatorId];
    if (self.hasAuthority || createdBySelf) {
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [self alertDeleteAtIndexPath:indexPath];
        }];
        return @[deleteAction];
    } else {
        return @[];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TBTeamActivity *teamActivity = [self.allActivityArray objectAtIndex:indexPath.row];
    if ([teamActivity.type isEqualToString:kNotificationTypeRoom]) {
        NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:teamActivity.targetId];
        MORoom *currentRoom  =[MORoom MR_findFirstWithPredicate:predicate];
        if (currentRoom) {
            [self enterChatWithRoom:currentRoom];
        }
    } else if ([teamActivity.type isEqualToString:kNotificationTypeStory]) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            MOStory *tempMOStory = [MOStory MR_findFirstByAttribute:@"id" withValue:teamActivity.target[@"_id"] inContext:localContext];
            if (!tempMOStory) {
                TBStory *tempTBStory = [MTLJSONAdapter modelOfClass:[TBStory class] fromJSONDictionary:teamActivity.target error:nil];
                tempMOStory = [MTLManagedObjectAdapter managedObjectFromModel:tempTBStory insertingIntoContext:localContext error:nil];
            }
        } completion:^(BOOL success, NSError *error) {
            MOStory *tempMOStory = [MOStory MR_findFirstByAttribute:@"id" withValue:teamActivity.target[@"_id"]];
            if (tempMOStory) {
                [self enterChatWithStory:tempMOStory];
            }
        }];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

@end
