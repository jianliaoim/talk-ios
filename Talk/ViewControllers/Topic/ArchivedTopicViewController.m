//
//  ArchivedTopicViewController.m
//  Talk
//
//  Created by jiaoliao-ios on 15/3/25.
//  Copyright (c) 2015年 jiaoliao. All rights reserved.
//

#import "ArchivedTopicViewController.h"
#import "constants.h"
#import "MORoom.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "TBTopicCell.h"
#import "UIColor+TBColor.h"
#import "TBHTTPSessionManager.h"
#import "TBUtility.h"
#import "TBButton.h"
#import "SVProgressHUD.h"
#import "MOTeam.h"

#import <FastEasyMapping/FastEasyMapping.h>
#import "MappingProvider.h"

static NSString *CellIdentifier = @"TBTopicCell";

@interface ArchivedTopicViewController ()

@property (nonatomic, strong) NSMutableArray *archivedTopicArray;
@property (strong, nonatomic) IBOutlet UIView *noArchivedTopicView;
@property (nonatomic) NSInteger archivedTopicsCount;

@end

static NSString * const kArchivedTopicsCount = @"archivedTopicsCount";

@implementation ArchivedTopicViewController
#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Archived Topics", @"Archived Topics");
    self.tableView.rowHeight = TBDefaultCellHeight;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"TBTopicCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self addObserver:self forKeyPath:kArchivedTopicsCount options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld  context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kSocketRoomArchive object:nil];
    
    [self fetchLocalData];
    [self getArchivedRooms];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:kArchivedTopicsCount];
}

#pragma mark - Private Method

- (void)refreshData {
    [self fetchLocalData];
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)fetchLocalData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentTeamID = [defaults valueForKey:kCurrentTeamID];
    NSPredicate *archivedTopicFilter = [NSPredicate predicateWithFormat:@"isArchived = YES AND teams.id = %@", currentTeamID];
    self.archivedTopicArray = [NSMutableArray arrayWithArray:[MORoom MR_findAllSortedBy:@"createdAt"  ascending:NO withPredicate:archivedTopicFilter]];
    self.archivedTopicsCount = self.archivedTopicArray.count;
}

- (void)getArchivedRooms {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *teamID = [defaults valueForKey:kCurrentTeamID];

    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:[NSString stringWithFormat:kGetRoomsURLString,teamID]
      parameters:@{@"isArchived": @YES}
         success:^(NSURLSessionDataTask *task, id responseObject) {
             NSMutableArray *archivedRooms = responseObject;
             [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                 // Get current team data
                 MOTeam *moTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:teamID inContext:localContext];
                 
                 // Process archived topics data
                 NSPredicate *roomFilter = [NSPredicate predicateWithFormat:@"isArchived = YES AND teams.id = %@", teamID];
                 NSArray *oldMORoomArray = [MORoom MR_findAllWithPredicate:roomFilter inContext:localContext];
                 [moTeam removeRooms:[NSSet setWithArray:oldMORoomArray]];
                 
                 NSArray *MORoomArray = [FEMManagedObjectDeserializer collectionFromRepresentation:archivedRooms
                                                                                                     mapping:[MappingProvider roomMapping]
                                                                                                          context:localContext];
                 for (MORoom *tempMORoom in MORoomArray) {
                     [moTeam addRoomsObject:tempMORoom];
                 }
                 
                 NSPredicate *deleteRoomFilter = [NSPredicate predicateWithFormat:@"teams.id = nil", teamID];
                 [MORoom MR_deleteAllMatchingPredicate:deleteRoomFilter inContext:localContext];
                 
             } completion:^(BOOL success, NSError *error) {
                 DDLogDebug(@"save archived topic success : %lu",(unsigned long)archivedRooms.count);
                 [self refreshData];
             }];
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             [SVProgressHUD showWithStatus:error.localizedRecoverySuggestion];
         }];
}

- (void)removeResumeTopicWithIndex:(NSIndexPath *)resumeIndexPath {
    [self.archivedTopicArray removeObjectAtIndex:resumeIndexPath.row];
    self.archivedTopicsCount  =  self.archivedTopicArray.count;
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)resumeTopic:(TBButton *)sender {
    DDLogDebug(@"%ld",(long)sender.indexPath.row);
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Recovering", @"Recovering")];
    
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    MORoom *room = self.archivedTopicArray[(NSUInteger) sender.indexPath.row];
    [manager POST:[NSString stringWithFormat:@"rooms/%@/archive",room.id]
       parameters:@{@"isArchived": @NO}
          success:^(NSURLSessionDataTask *task, id responseObject) {
              DDLogVerbose(@"Successfully resume topic");
              [SVProgressHUD dismiss];
              
              [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                  //resume room
                  NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:room.id];
                  MORoom *currentRoom  =[MORoom MR_findFirstWithPredicate:predicate inContext:localContext];
                  currentRoom.isArchived = [NSNumber numberWithBool:NO];
              } completion:^(BOOL success, NSError *error) {
                  if (success) {
                      //refresh related data
                      [[NSNotificationCenter defaultCenter]postNotificationName:kResumeRoomSucceedNotification object:nil];
                      [self removeResumeTopicWithIndex:sender.indexPath];
                  }
              }];
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              DDLogError(@"Error: %@", error.localizedRecoverySuggestion);
              [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
          }];

}

#pragma mark - KVO 

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:kArchivedTopicsCount])
    {
        if (self.archivedTopicArray.count == 0) {
            self.tableView.tableHeaderView = self.noArchivedTopicView;
        }
        else {
            self.tableView.tableHeaderView  = nil;
        }
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.archivedTopicArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MORoom *room = self.archivedTopicArray[(NSUInteger) indexPath.row];
    if ([TBUtility isManagerForCurrentAccount] || [[[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey] isEqualToString:room.creatorID]) {
        TBButton *button = [TBButton buttonWithType:UIButtonTypeSystem];
        CGRect frame = CGRectMake(0, 10, 60, 30);
        button.frame = frame;
        button.indexPath = indexPath;
        [button setTitle:NSLocalizedString(@"Recover", @"Recover") forState:UIControlStateNormal];
        [button setTitleColor:[UIColor jl_redColor] forState:UIControlStateNormal];
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [button addTarget:self action:@selector(resumeTopic:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
    }
    else {
        cell.accessoryView = nil;
    }
    
    cell.titleLabel.text = [TBUtility getTopicNameWithIsGeneral:room.isGeneralValue andTopicName:room.topic];
    cell.cellImageView.tintColor = [TBUtility getTopicRoomColorWith:room.color];
    
    UIImage *image;
    if (room.isPrivateValue) {
        image = [[UIImage imageNamed:@"icon-lock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        image = [UIImage imageNamed:@"TopicLogo"];
    }
    [cell.cellImageView setImage:image];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MORoom *selectedMORoom = self.archivedTopicArray[(NSUInteger) indexPath.row];
    ChatViewController *tempChatVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    tempChatVC.refreshWhenViewDidLoad = YES;
    tempChatVC.roomType = ChatRoomTypeForRoom;
    if (selectedMORoom.isArchivedValue) {
        tempChatVC.isArchived = YES;
    }
    [TBUtility currentAppDelegate].currentRoom = selectedMORoom;
    [self.navigationController pushViewController:tempChatVC animated:YES];
}

@end
