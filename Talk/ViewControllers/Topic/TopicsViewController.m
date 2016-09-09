//
//  TopicsViewController.m
//  Talk
//
//  Created by Shire on 9/25/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TopicsViewController.h"
#import "TBHTTPSessionManager.h"
#import "MORoom.h"
#import "TBRoom.h"
#import "CoreData+MagicalRecord.h"
#import "constants.h"
#import "TBTopicCell.h"
#import "ChatViewController.h"
#import "UIColor+TBColor.h"
#import "TBUtility.h"
#import "SVProgressHUD.h"
#import "NewTopicViewController.h"
#import <Masonry.h>
#import "TBShowArchivedCell.h"

static NSString *CellIdentifier = @"TBTopicCell";
static NSString *ArchivedCellIdentifier = @"TBShowArchivedCell";

@interface TopicsViewController ()<NewTopicViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *noTopicJoinLabel;
@property (weak, nonatomic) IBOutlet UIButton *addNewTopic;

@property (nonatomic, strong) NSArray *joinedTopicArray;
@property (nonatomic, strong) NSArray *recommendTopicArray;

@property (nonatomic) BOOL isEnteringChatVC;

@end

@implementation TopicsViewController

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    //set team button and titleView
    self.title = NSLocalizedString(@"My Groups", @"My Groups");
    
    [self commonInit];
    [self fetchLocalData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.isEnteringChatVC = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBActions

-(IBAction)barButtonPressed:(id)sender
{
    UINavigationController *temNav = (UINavigationController *)[[UIStoryboard storyboardWithName:kNewTopicStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"showAddNewTopicNav"];
    [temNav setTransitioningDelegate:[TBUtility currentAppDelegate].presentTransition];
    NewTopicViewController *newTopicVC = [temNav.viewControllers objectAtIndex:0];
    newTopicVC.delegate = self;
    [self presentViewController:temNav animated:YES completion:^{}];
}

- (IBAction)refreshEvent:(UIRefreshControl *)sender {
    [self.refreshControl beginRefreshing];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshRecentData object:nil];
}

#pragma mark - Private Methods

- (void)commonInit {
    self.welcomeLabel.text = NSLocalizedString(@"Welcome to Talk", @"Welcome to Talk");
    self.noTopicJoinLabel.attributedText = [TBUtility getAttributedStringWith:NSLocalizedString(@"No group join", @"No group join") andLineSpace:4.0 andFont:13.0];
    [self.addNewTopic setTitle:NSLocalizedString(@"Add new group", @"Add new group") forState:UIControlStateNormal];
    
    self.tableView.rowHeight = TBDefaultCellHeight;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"TBTopicCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    if (!self.isForChoosingGroup) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(barButtonPressed:)];
        self.navigationItem.rightBarButtonItem = addButton;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kTeamDataStored object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshEvent:) name:kSocketRoomCreate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kSocketRoomJoin object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kEditTopicInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kEditTopicColorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kLeaveRoomSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kResumeRoomSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kDeleteRoomSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderNewTeamData) name:kSocketRoomRemove object:nil];
}

// rneder new Team Data
- (void)renderNewTeamData {
    [self endRefreshingLoading];
    [self fetchLocalData];
    [self.tableView reloadData];
}

- (void)failedFetchRemoteData {
    [self renderNewTeamData];
    [self endRefreshingLoading];
}

- (void)endRefreshingLoading {
    [self.refreshControl endRefreshing];
}

- (void)fetchLocalData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentTeamID = [defaults valueForKey:kCurrentTeamID];

    NSPredicate *joinedTopicFilter = [NSPredicate predicateWithFormat:@"isArchived = NO AND isQuit = NO AND teams.id = %@", currentTeamID];
    self.joinedTopicArray = [MORoom MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:joinedTopicFilter ];
    
    NSPredicate *recommendTopicFilter = [NSPredicate predicateWithFormat:@"isArchived = NO AND isQuit = YES AND teams.id = %@ AND isPrivate = NO", currentTeamID];
    self.recommendTopicArray = [MORoom MR_findAllSortedBy:@"createdAt"  ascending:NO withPredicate:recommendTopicFilter];
}

//jump to chat room
-(void)jumpToChatWithRoom:(MORoom *)room andIsPreview:(BOOL)isPreView
{
    ChatViewController *tempChatVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    tempChatVC.refreshWhenViewDidLoad = YES;
    tempChatVC.roomType = ChatRoomTypeForRoom;
    tempChatVC.isPreView = isPreView;
    [TBUtility currentAppDelegate].currentRoom = room;
    [tempChatVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:tempChatVC animated:YES];
}

- (void)joinTopic:(UIButton *)sender {
    CGRect frame = CGRectMake(0, 0, 50, 30);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = NSLocalizedString(@"Joined", @"Joined");
    label.font = [UIFont systemFontOfSize:14.0f];
    label.textColor = [UIColor tb_textGray];
    
    TBTopicCell *cell = (TBTopicCell *) [self superviewOfType:[TBTopicCell class] forView:sender];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    MORoom *room = self.recommendTopicArray[(NSUInteger) indexPath.row];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    cell.accessoryView = indicator;
    [indicator startAnimating];
    
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager POST:[NSString stringWithFormat:@"rooms/%@/join", room.id]
       parameters:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              DDLogVerbose(@"Successfully joined topic");
              [indicator startAnimating];
              cell.accessoryView = label;
              
              [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                  MORoom *moRoom = [MORoom MR_findFirstByAttribute:@"id" withValue:room.id inContext:localContext];
                  moRoom.isQuit = [NSNumber numberWithBool:NO];
              } completion:^(BOOL success, NSError *error) {
                  // update Joined and Recommend data array
                  NSMutableArray *recommendMutableArray = [self.recommendTopicArray mutableCopy];
                  NSMutableArray *joinedMutableArray = [self.joinedTopicArray mutableCopy];
                  [recommendMutableArray removeObjectAtIndex:(NSUInteger) indexPath.row];
                  [joinedMutableArray insertObject:room atIndex:0];
                  self.recommendTopicArray = [NSArray arrayWithArray:recommendMutableArray];
                  self.joinedTopicArray = [NSArray arrayWithArray:joinedMutableArray];
                  
                  [self.tableView beginUpdates];
                  [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                  [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                  [self.tableView endUpdates];
                  
                  MORoom *joinedMORoom = [MORoom MR_findFirstByAttribute:@"id" withValue:room.id];
                  [self jumpToChatWithRoom:joinedMORoom andIsPreview:NO];
                  
                  [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Joined", @"Joined")];
              }];
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              DDLogError(@"Error: %@", error.localizedRecoverySuggestion);
              [indicator stopAnimating];
          }];
}

- (UIView *) superviewOfType:(Class)paramSuperviewClass forView:(UIView *)paramView {
    if (paramView.superview != nil){
        if ([paramView.superview isKindOfClass:paramSuperviewClass]){
            return paramView.superview;
        } else {
            return [self superviewOfType:paramSuperviewClass
                                 forView:paramView.superview];
        }
    }
    return nil;
}


#pragma mark - NewTopicViewControllerDelegate

-(void)successCreateRoom:(MORoom *)room
{
    [self jumpToChatWithRoom:room andIsPreview:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.joinedTopicArray.count;
            break;
        case 1:
            return self.recommendTopicArray.count;
            break;
        case 2:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rows;
    switch (indexPath.section) {
        case 0: {
            rows = self.joinedTopicArray.count;
            if (rows == 1) {
                return TBDefaultCellHeight + 10;
            }
            else {
                if (indexPath.row == 0) {
                    return TBDefaultCellHeight + 5;
                }
                else if (indexPath.row == rows - 1) {
                    return TBDefaultCellHeight + 5;
                }
                else {
                    return TBDefaultCellHeight;
                }
            }
            break;
        }
        case 1: {
            rows = self.recommendTopicArray.count;
            if (rows == 1) {
                return TBDefaultCellHeight + 10;
            }
            else {
                if (indexPath.row == 0) {
                    return TBDefaultCellHeight + 5;
                }
                else if (indexPath.row == rows - 1) {
                    return TBDefaultCellHeight + 5;
                }
                else {
                    return TBDefaultCellHeight;
                }
            }
            break;
        }
        case 2: {
            return TBDefaultCellHeight;
            break;
        }
        default:
            return TBDefaultCellHeight;
            break;
    }

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Joined", @"Joined");
            break;
        case 1:
            return NSLocalizedString(@"Joinable", @"Joinable");
            break;
        case 2:
            return NSLocalizedString(@"Archived", @"Archived");
            break;
            
        default:
            return @"";
            break;
    }
    
}

//fix iOS 8.3 bug
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBTopicCell *cell;
    TBShowArchivedCell *archivedCell;
    MORoom *room = nil;
    switch (indexPath.section) {
        case 0: {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            NSInteger rows = [self.tableView numberOfRowsInSection:indexPath.section];
            if (rows == 1) {
                cell.type = TBCellTypeOnly;
            }
            else {
                if (indexPath.row == 0) {
                    cell.type = TBCellTypeTop;
                }
                else if (indexPath.row == rows - 1) {
                    cell.type = TBCellTypeBottom;
                }
                else {
                    cell.type = TBCellTypeCommon;
                }
            }
            room = self.joinedTopicArray[(NSUInteger) indexPath.row];
            cell.accessoryView = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            break;
        }
        case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            NSInteger rows = [self.tableView numberOfRowsInSection:indexPath.section];
            if (rows == 1) {
                cell.type = TBCellTypeOnly;
            }
            else {
                if (indexPath.row == 0) {
                    cell.type = TBCellTypeTop;
                }
                else if (indexPath.row == rows - 1) {
                    cell.type = TBCellTypeBottom;
                }
                else {
                    cell.type = TBCellTypeCommon;
                }
            }
            room = self.recommendTopicArray[(NSUInteger) indexPath.row];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            CGRect frame = CGRectMake(0, 0, 36, 30);
            button.frame = frame;
            [button setTitle:NSLocalizedString(@"Join", @"Join") forState:UIControlStateNormal];
            [button setTitleColor:[UIColor tb_docColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(joinTopic:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = button;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case 2:
            archivedCell = [tableView dequeueReusableCellWithIdentifier:ArchivedCellIdentifier forIndexPath:indexPath];
            archivedCell.tintColor = [UIColor tb_docColor];
            UIImage *nameImage = [[UIImage imageNamed:@"icon-archive"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            archivedCell.archivedIconImageView.image = nameImage;
            archivedCell.archivedTitleLabel.textColor = [UIColor tb_docColor];
            return archivedCell;
            break;
    }
    
    // Transform topic color to corresponding UIColor selector
    if (!room.color) {
        room.color = @"doc";
    }
    UIImage *image;
    if (room.isPrivateValue) {
        image = [[UIImage imageNamed:@"icon-lock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        image = [[UIImage imageNamed:@"icon-topic"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    cell.cellImageView.image = image;
    cell.cellImageView.tintColor = [UIColor jl_redColor];
    return cell;
}

//add by zhangxiaolian 2014-10-9

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor tb_tableHeaderGrayColor];
    header.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        return;
    }
    
    if (self.isEnteringChatVC) {
        return;
    }
    self.isEnteringChatVC = YES;
    
    if (indexPath.section == 0) {
        MORoom *selecteMORoom = self.joinedTopicArray[(NSUInteger) indexPath.row];
        if (self.isForChoosingGroup) {
            if ([self.delegate respondsToSelector:@selector(haveChoosenGroup:)]) {
                [self.delegate haveChoosenGroup:selecteMORoom];
            }
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        [self jumpToChatWithRoom:selecteMORoom andIsPreview:NO];
    } else {
        MORoom *selecteMORoom = self.recommendTopicArray[(NSUInteger) indexPath.row];
        if (self.isForChoosingGroup) {
            if ([self.delegate respondsToSelector:@selector(haveChoosenGroup:)]) {
                [self.delegate haveChoosenGroup:selecteMORoom];
            }
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        [self jumpToChatWithRoom:selecteMORoom andIsPreview:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
