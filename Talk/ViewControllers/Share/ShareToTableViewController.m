//
//  ShareToTableViewController.m
//  Talk
//
//  Created by teambition-ios on 15/3/17.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//
#import "MOUser.h"
#import "MORoom.h"
#import "ShareToTableViewController.h"
#import "TBShareToCell.h"
#import "TBShareTeamCell.h"
#import "UIColor+TBColor.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "constants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ShareSectionHeaderView.h"
#import <Hanzi2Pinyin/Hanzi2Pinyin.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import "TBUtility.h"
#import "NSManagedObject+MagicalFinders.h"
#import "MOTeam.h"
#import "ShareTeamTableViewController.h"
#import "TBHTTPSessionManager.h"
#import "SVProgressHUD.h"
#import "TBUser.h"
#import "FEMManagedObjectDeserializer.h"
#import "MappingProvider.h"


@interface ShareToTableViewController ()<ShareTeamTableViewControllerDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate>

//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) MOTeam *selectedTeam;
@property (strong, nonatomic) NSMutableArray *roomsArray;
@property (strong, nonatomic) NSMutableArray *membersArray;
@property (strong, nonatomic) NSMutableArray *searchMemeberResults;
@property (strong, nonatomic) NSMutableArray *searchRoomResults;
@property (strong, nonatomic) NSString *currentSearchString;
@property (nonatomic)  int searchSectionCount;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableViewController *searchResultController;

@end

static NSString *teamCellIdentifier = @"TBShareTeamCell";
static NSString *CellIdentifier = @"ShareToCell";
static NSString *SectionHeaderViewIdentifier = @"SectionHeaderViewIdentifier";

@implementation ShareToTableViewController

#pragma mark- ViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"ShareSectionHeaderView" bundle:nil];
    [self.tableView registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:SectionHeaderViewIdentifier];
    
    self.title = NSLocalizedString(@"Forward To", @"Forward To");
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.roomsArray = [NSMutableArray array];
    self.membersArray = [NSMutableArray array];
    self.searchRoomResults = [[NSMutableArray alloc]init];
    self.searchMemeberResults = [[NSMutableArray alloc]init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentTeamID = [defaults valueForKey:kCurrentTeamID];
    MOTeam *team = [MOTeam MR_findFirstByAttribute:@"id" withValue:currentTeamID];
    self.selectedTeam = team;
    
    [self fetchAndSetDataWithTeamId:currentTeamID];
}

- (UITableViewController *)searchResultController {
    if (!_searchResultController) {
        _searchResultController = [[UITableViewController alloc] init];
        _searchResultController.tableView.delegate = self;
        _searchResultController.tableView.dataSource = self;
        _searchResultController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _searchResultController;
}

- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultController];
        
        _searchController.searchResultsUpdater = self;
        _searchController.delegate = self;
        _searchController.searchBar.delegate = self;
        
        //Customize
        _searchController.dimsBackgroundDuringPresentation = NO;
        _searchController.searchBar.barTintColor = [UIColor tb_shareToSearchBarcolor];
        _searchController.searchBar.layer.borderWidth = 1.0;
        _searchController.searchBar.layer.borderColor = [UIColor tb_searchBarColor].CGColor;
        _searchController.searchBar.tintColor = [UIColor jl_redColor];
    }
    return _searchController;
}

- (void)fetchAndSetDataWithTeamId:(NSString *)teamId {
    NSPredicate *joinedTopicFilter = [NSPredicate predicateWithFormat:@"isQuit = NO AND isArchived = NO AND teams.id = %@", teamId];
    self.roomsArray= (NSMutableArray *)[MORoom MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:joinedTopicFilter];
    NSMutableArray *userArray = (NSMutableArray *)[MOUser findAllInTeamExceptSelfWithTeamId:teamId sortBy:@"pinyin"];
    [self.membersArray removeAllObjects];
    for (MOUser *user in userArray) {
        if (!user.isQuitValue) {
            [self.membersArray addObject:user];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- IBActions

- (IBAction)cancelDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- Private Method

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark-Get Tap Block

/**
 *  get tap block
 *
 *  @param tapRoom      taped room
 *  @param tapTableView taped tablevew
 *  @param indexPath    taped indexPath
 *
 *  @return UIAlertViewCompletionBlock
 */
- (UIAlertViewCompletionBlock )getRoomTapBlockWithRoom:(MORoom *)tapRoom andTableView:(UITableView *)tapTableView  andIndex:(NSIndexPath *)indexPath {
     UIAlertViewCompletionBlock tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            DDLogDebug(@"Cancelled");
            [tapTableView deselectRowAtIndexPath:indexPath animated:YES];
        } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Send", @"Send")]) {
            NSMutableDictionary *tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:tapRoom.id,@"_roomId",nil];
            [self forwardMessageWithParas:tempParamsDic];
        } else {
            [tapTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    };
    
    return tapBlock;
}

/**
 *  get User TapBlock
 *
 *  @param tapUser      taped user
 *  @param tapTableView taped tablevew
 *  @param indexPath    taped indexPath
 *
 *  @return UIAlertViewCompletionBlock
 */
- (UIAlertViewCompletionBlock )getUserTapBlockWithUser:(MOUser *)tapUser andTableView:(UITableView *)tapTableView  andIndex:(NSIndexPath *)indexPath {
    UIAlertViewCompletionBlock tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            DDLogDebug(@"Cancelled");
            [tapTableView deselectRowAtIndexPath:indexPath animated:YES];
        } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Send", @"Send")]) {
            NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:tapUser.id,@"_toId",
                                                        [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID],@"_teamId",nil];
            [self forwardMessageWithParas:tempParams];
        } else {
            [tapTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    };
    
    return tapBlock;
}

- (void)forwardMessageWithParas:(NSMutableDictionary *)paras {
    if (self.isSendMessage) {
        [self sendMessageWithParas:paras];
    } else {
        NSString *forwardUrlString;
        if (self.isFavorite) {
            forwardUrlString = kFavoritesForwardURLString;
            [paras setValue:self.forwardMessageIdArray forKey:@"_favoriteIds"];
        } else {
            forwardUrlString = kForwardMessageURLString;
            [paras setValue:self.forwardMessageIdArray forKey:@"_messageIds"];
        }
        
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Sending...", @"Sending...")];
        [[TBHTTPSessionManager sharedManager] POST:forwardUrlString parameters:paras success:^(NSURLSessionDataTask *task, id responseObject) {
            [self dismissViewControllerAnimated:YES completion:^{
            }];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Has Send", @"Has Send")];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed,Please try later", @"Failed,Please try later")];
        }];
    }
}

- (void)sendMessageWithParas:(NSMutableDictionary *)tempParamsDic {
    [tempParamsDic setObject:self.messageBody forKey:kMessageBody];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Sending...", @"Sending...")];
    [[TBHTTPSessionManager sharedManager] POST:kSendMessageURLString parameters:tempParamsDic success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"responseObject%@",responseObject);
        [self dismissViewControllerAnimated:YES completion:^{}];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Has Send", @"Has Send")];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed,Please try later", @"Failed,Please try later")];
        }];
}

#pragma mark - ShareTeamTableViewControllerDelegate

- (void)selecteTeam:(MOTeam *)team {
    self.selectedTeam = team;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentTeamID = [defaults valueForKey:kCurrentTeamID];
    if ([team.id isEqualToString:currentTeamID]) {
        [self fetchAndSetDataWithTeamId:currentTeamID];
        [self.tableView reloadData];
    } else {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
        TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
        [manager GET:[NSString stringWithFormat:@"%@/%@",kTeamURLString,team.id] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            [self processTeamDataWithDictionary:responseObject];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        }];
    }
}

- (void)processTeamDataWithDictionary:(NSDictionary *)responseObject{
    NSArray *roomArray = responseObject[@"rooms"];
    NSArray *userArray = responseObject[@"members"];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MOTeam *moTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:self.selectedTeam.id inContext:localContext];
        NSArray *newMORoomArray = [FEMManagedObjectDeserializer collectionFromRepresentation:roomArray
                                                                                               mapping:[MappingProvider roomMapping]
                                                                                                    context:localContext];
        for (MORoom *tempMORoom in newMORoomArray) {
            [moTeam addRoomsObject:tempMORoom];
        }
        NSArray *MOUserArray = [FEMManagedObjectDeserializer collectionFromRepresentation:userArray
                                                                                            mapping:[MappingProvider userMapping]
                                                                                                 context:localContext];
        for (MOUser *tempMOUser in MOUserArray) {
            [moTeam addUsersObject:tempMOUser];
        }
    } completion:^(BOOL success, NSError *error) {
        [self fetchAndSetDataWithTeamId:self.selectedTeam.id];
        [self.tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}

#pragma mark- Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (tableView == self.tableView) {
        return 3;
    } else {
        int searchSectionCount = 0;
        if (self.searchRoomResults.count > 0) {
            searchSectionCount++;
        }
        if (self.searchMemeberResults.count > 0) {
            searchSectionCount++;
        }
        self.searchSectionCount = searchSectionCount;
        return searchSectionCount;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView != self.searchResultController.tableView) {
        switch (section) {
            case 0:
                return 1;
                break;
            case 1:
                return self.roomsArray.count;
                break;
            case 2:
                return self.membersArray.count;
                break;
                
            default:
                return 0;
                break;
        }

    }
    else {
        switch (self.searchSectionCount) {
            case 0: {
                return 0;
                break;
            }
            case 1: {
                if (self.searchRoomResults.count > 0) {
                    return self.searchRoomResults.count;
                } else {
                    return self.searchMemeberResults.count;
                }
                break;
            }
            case 2: {
                if (section == 0) {
                    return self.searchRoomResults.count;
                }
                else {
                    return self.searchMemeberResults.count;
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
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchResultController.tableView)
    {
        switch (section) {
            case 1:
                return  NSLocalizedString(@"Recent", @"Recent");
                break;
            case 2:
                return  NSLocalizedString(@"Topics", @"Topics");
                break;
            default:
                return nil;
                break;
        }
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ShareSectionHeaderView *sectionHeaderView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:SectionHeaderViewIdentifier];
    if (tableView != self.searchResultController.tableView)
    {
        switch (section) {
            case 0:
                return nil;
                break;
            case 1:
                sectionHeaderView.nameLabel.text =  NSLocalizedString(@"Topics", @"Topics");
                break;
            case 2:
                sectionHeaderView.nameLabel.text =  NSLocalizedString(@"Members", @"Members");
                break;
                
            default:
                return nil;
                break;
        }
        
        return sectionHeaderView;
    }
    else
    {
        switch (section) {
            case 0: {
                if (self.searchRoomResults.count > 0 ) {
                    sectionHeaderView.contentView.backgroundColor = [UIColor whiteColor];
                    sectionHeaderView.nameLabel.text =  NSLocalizedString(@"Topics", @"Topics");
                } else {
                    if (self.searchMemeberResults.count > 0 ) {
                        sectionHeaderView.contentView.backgroundColor = [UIColor whiteColor];
                        sectionHeaderView.nameLabel.text =  NSLocalizedString(@"Members", @"Members");
                    }
                    else {
                    sectionHeaderView.contentView.backgroundColor = [UIColor clearColor];
                    sectionHeaderView.nameLabel.text =  @"";
                    }
                }
                break;
            }
            case 1: {
                if (self.searchMemeberResults.count > 0 ) {
                    sectionHeaderView.contentView.backgroundColor = [UIColor whiteColor];
                    sectionHeaderView.nameLabel.text =  NSLocalizedString(@"Members", @"Members");
                } else {
                    sectionHeaderView.contentView.backgroundColor = [UIColor clearColor];
                    sectionHeaderView.nameLabel.text =  @"";
                }
                break;
            }
            default:
                return nil;
                break;
        }
        
        return sectionHeaderView;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Dequeue a cell from self's table view.
    TBShareToCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    /*
     If the requesting table view is the search display controller's table view, configure the cell using the search results array, otherwise use the product array.
     */
    if (tableView == self.searchResultController.tableView)
    {
        cell.searchString = self.currentSearchString;
        
        switch (indexPath.section) {
            case 0: {
                if (self.searchRoomResults.count > 0) {
                    MORoom *tempRoom = [self.searchRoomResults objectAtIndex:indexPath.row];
                    [cell setRoom:tempRoom];
                } else {
                    MOUser *tempUser = [self.searchMemeberResults objectAtIndex:indexPath.row];
                    [cell setUser:tempUser];
                }
                break;
            }
            case 1: {
                MOUser *tempUser = [self.searchMemeberResults objectAtIndex:indexPath.row];
                [cell setUser:tempUser];
                break;
            }
            default:
                break;
        }

    }
    else
    {
        switch (indexPath.section) {
            case 0: {
                TBShareTeamCell *teamCell = [self.tableView dequeueReusableCellWithIdentifier:teamCellIdentifier];
                teamCell.teamTitleLabel.text = NSLocalizedString(@"Team", @"Team");
                teamCell.teamNameLabel.text = self.selectedTeam.name;
                return teamCell;
                
                break;
            }
            case 1: {
                MORoom *tempRoom = [self.roomsArray objectAtIndex:indexPath.row];
                [cell setRoom:tempRoom];
                break;
            }
            case 2: {
                MOUser *tempUser = [self.membersArray objectAtIndex:indexPath.row];
                [cell setUser:tempUser];
                break;
            }
            default:
              break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TBShareToCell *cell;
    UIAlertViewCompletionBlock tapBlock;
    if (tableView == self.searchResultController.tableView)
    {
        cell = (TBShareToCell *) [self.searchResultController.tableView cellForRowAtIndexPath:indexPath];
        switch (indexPath.section) {
            case 0: {
                if (self.searchRoomResults.count > 0) {
                    MORoom *tempRoom = [self.searchRoomResults objectAtIndex:indexPath.row];
                    tapBlock = [self getRoomTapBlockWithRoom:tempRoom andTableView:tableView andIndex:indexPath];
                } else {
                    MOUser *tempUser = [self.searchMemeberResults objectAtIndex:indexPath.row];
                    tapBlock =  [self getUserTapBlockWithUser:tempUser andTableView:tableView andIndex:indexPath];
                }
                break;
            }
            case 1: {
                MOUser *tempUser = [self.searchMemeberResults objectAtIndex:indexPath.row];
                tapBlock =  [self getUserTapBlockWithUser:tempUser andTableView:tableView andIndex:indexPath];
                break;
            }
            default:
                break;
        }
    }
    else
    {
        cell = (TBShareToCell *) [self.tableView cellForRowAtIndexPath:indexPath];
        switch (indexPath.section) {
            case 0: {
                return;
                break;
            }
            case 1: {
                MORoom *tempRoom = [self.roomsArray objectAtIndex:indexPath.row];
                tapBlock = [self getRoomTapBlockWithRoom:tempRoom andTableView:tableView andIndex:indexPath];
                break;
            }
            case 2: {
                MOUser *tempUser = [self.membersArray objectAtIndex:indexPath.row];
                tapBlock =  [self getUserTapBlockWithUser:tempUser andTableView:tableView andIndex:indexPath];
                break;
            }
            default:
                break;
        }
    }
    [UIAlertView showWithTitle:nil
                       message:[NSString stringWithFormat:NSLocalizedString(@"Confirm forward to", @"Confirm forward to"),cell.nameLabel.text]
             cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
             otherButtonTitles:@[NSLocalizedString(@"Send", @"Send")]
                      tapBlock:tapBlock];
}

#pragma mark - UISearchControllerDelegate

- (void)didPresentSearchController:(UISearchController *)searchController {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    CGFloat topInset = CGRectGetMaxY(searchController.searchBar.frame);
    self.searchResultController.tableView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //Get searchString
    NSString *searchString = searchController.searchBar.text;
    
    //Same as UISearchDisplayController
    [self.searchRoomResults removeAllObjects];
    
    NSString *searchLowercaseString = searchString.lowercaseString;
    for (MORoom *tempRoom in self.roomsArray) {
        NSString *abbreviationString = [Hanzi2Pinyin convertToAbbreviation:tempRoom.topic];
        NSString *pinyinString = [[Hanzi2Pinyin convert:tempRoom.topic] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([[tempRoom.topic lowercaseString] rangeOfString:searchLowercaseString].location != NSNotFound || [pinyinString rangeOfString:searchLowercaseString].location != NSNotFound || [abbreviationString rangeOfString:searchLowercaseString].location != NSNotFound) {
            [self.searchRoomResults addObject:tempRoom];
            continue;
        }
    }
    
    [self.searchMemeberResults removeAllObjects];
    for (MOUser *tempUSer in self.membersArray) {
        NSString *nameString = [TBUtility getFinalUserNameWithMOUser:tempUSer];
        NSString *abbreviationString = [Hanzi2Pinyin convertToAbbreviation:nameString];
        NSString *pinyinString = [[Hanzi2Pinyin convert:nameString] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([[nameString lowercaseString] rangeOfString:searchLowercaseString].location != NSNotFound || [pinyinString rangeOfString:searchLowercaseString].location != NSNotFound || [abbreviationString rangeOfString:searchLowercaseString].location != NSNotFound) {
            [self.searchMemeberResults addObject:tempUSer];
        }
    }
    
    //set current search string
    self.currentSearchString = searchLowercaseString;
    //Reload searchResultController
    [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"TBShareTeam"]) {
        ShareTeamTableViewController *teamController = segue.destinationViewController;
        teamController.delegate = self;
        teamController.selectedTeamID = self.selectedTeam.id;
    }
}

@end
