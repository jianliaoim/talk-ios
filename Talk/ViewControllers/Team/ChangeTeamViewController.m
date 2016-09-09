//
//  TeamsViewController.m
//  Talk
//
//  Created by Shire on 9/24/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import "ChangeTeamViewController.h"
#import "TBHTTPSessionManager.h"
#import "TBTeam.h"
#import "constants.h"
#import "MOTeam.h"
#import "CoreData+MagicalRecord.h"
#import "UIColor+TBColor.h"
#import "RootViewController.h"
#import "SVProgressHUD.h"
#import "TBUtility.h"
#import "TBTeamCell.h"
#import "UIView+TBSnapshotView.h"
#import "UIImage+ImageEffects.h"
#import <M13BadgeView.h>
#import "MOUser.h"
#import "TBUser.h"
#import "NewTeamViewController.h"
#import "NSString+Emoji.h"
#import <UIActionSheet+SHActionSheetBlocks.h>
#import "AddTeamCell.h"
#import "SyncTeamsViewController.h"

static NSString *CellIdentifier = @"TBTeamCell";
static NSString *AddTeamIdentifier = @"SyncTeamCell";

@interface ChangeTeamViewController ()<UIActionSheetDelegate,UIScrollViewDelegate,SyncTeamsDelegate>
{
    UIImageView *shadowView;
}
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (assign, nonatomic) CATransform3D initialTransformation;
@property (nonatomic, strong) NSMutableSet *shownIndexes;
@property (nonatomic)BOOL isViewDidAppear;
@property (nonatomic)BOOL isTeamListDidAppear;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@end

@implementation ChangeTeamViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kCurrentTeamID] == nil) {
        [self.navigationItem setHidesBackButton:YES animated:YES];
    }

    [self commonInit];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kCurrentTeamID]) {
        self.tableView.backgroundColor = [UIColor clearColor];
        [self.refreshControl setTintColor:[UIColor whiteColor]];
        UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSelectTeam)];
        self.navigationItem.leftBarButtonItem = cancelBarItem;
    }
        
    [self fetchLocalData];
    
    //cell naniamtion
    CGPoint offsetPositioning = CGPointMake(0, [UIScreen mainScreen].bounds.size.height);
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, 0.0);
    _initialTransformation = transform;
    _shownIndexes = [NSMutableSet set];
    
    _isTeamListDidAppear = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataForNewTeam) name:kNewTeamSavedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataForCreateTeam) name:kTeamCreateNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg.png"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg.png"]];
        
    UINavigationBar *navBar = self.navigationController.navigationBar;
    CGRect rect = CGRectMake(0, navBar.bounds.size.height, navBar.bounds.size.width, 20);
    shadowView = [[UIImageView alloc]initWithFrame:rect];
    shadowView.image = self.shadowImage;
        
    // Create a gradient layer that goes transparent -&gt; opaque
    CAGradientLayer *alphaGradientLayer = [CAGradientLayer layer];
    NSArray *colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                           (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                           nil];
    [alphaGradientLayer setColors:colors];
    // Start the gradient at the bottom and go almost half way up.
    [alphaGradientLayer setStartPoint:CGPointMake(0.5f, 1.0f)];
    [alphaGradientLayer setEndPoint:CGPointMake(0.5f, 0.0f)];
    [alphaGradientLayer setFrame:[shadowView bounds]];
    [[shadowView layer] setMask:alphaGradientLayer];
    [navBar addSubview:shadowView];
        
    self.tableView.tableHeaderView.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (shadowView) {
        [shadowView removeFromSuperview];
    }
    self.navigationController.navigationBarHidden = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    self.isViewDidAppear = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)cancelSelectTeam
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  refresh Data For Create Team
 */
-(void)refreshDataForCreateTeam
{
    [self fetchLocalData];
    [self.tableView reloadData];
    //self.navigationController.navigationBarHidden = YES;
}

#pragma mark - Private Methods

- (void)commonInit {
    self.tableView.rowHeight = TBDefaultCellHeight;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UINib *nib = [UINib nibWithNibName:CellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    
    [self.refreshControl addTarget:self action:@selector(syncData) forControlEvents:UIControlEventValueChanged];
    self.title = NSLocalizedString(@"Select team", @"Select team");
}

- (void)fetchLocalData {
    self.dataArray = [NSMutableArray arrayWithArray:[MOTeam MR_findAllSortedBy:@"unread,updatedAt" ascending:NO]];
    for (MOTeam *tempTeam in self.dataArray) {
        if ([tempTeam.id isEqualToString:self.selectedTeamID]) {
            [self.dataArray removeObject:tempTeam];
            [self.dataArray insertObject:tempTeam atIndex:0];
            break;
        }
    }
}

- (void)syncData {
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:kTeamURLString
      parameters:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             DDLogVerbose(@"teams data: %@", responseObject);
             if ([SVProgressHUD isVisible]) {
                 [SVProgressHUD dismiss];
             }
             [self processData:responseObject];
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             DDLogError(@"error: %@", error.localizedRecoverySuggestion);
             if ([SVProgressHUD isVisible]) {
                 [SVProgressHUD dismiss];
             }
             [self executeCompleteOperation]; 
             [SVProgressHUD showErrorWithStatus:error.localizedDescription];
         }];
}

- (void)processData:(NSArray *)responseObject {

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *oldMOTeamArray = [MOTeam MR_findAllInContext:localContext];
        NSArray *newTBTeamArray = [MTLJSONAdapter modelsOfClass:[TBTeam class] fromJSONArray:responseObject error:NULL];
        [newTBTeamArray enumerateObjectsUsingBlock:^(TBTeam *team, NSUInteger idx, BOOL *stop) {
            [MTLManagedObjectAdapter
                    managedObjectFromModel:team
                      insertingIntoContext:localContext
                                     error:NULL];
        }];
        
        for (MOTeam *oldTeam in oldMOTeamArray) {
            BOOL findInNew = NO;
            for (TBTeam *team in newTBTeamArray) {
                if ([team.id isEqualToString:oldTeam.id]) {
                    findInNew = YES;
                    break;
                }
            }
            
            if (!findInNew) {
                [oldTeam MR_deleteInContext:localContext];
            }
        }

    } completion:^(BOOL success, NSError *error) {
        [self fetchLocalData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self executeCompleteOperation];
        });
    }];
}

- (void)executeCompleteOperation {
    [self.refreshControl endRefreshing];
}

/**
 *  delete And exit Team
 */
-(void)deleteAndExitTeamWithIndexPath:(NSIndexPath *)indexPath
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Exiting", @"Exiting")];
    MOTeam *moTeam = self.dataArray[(NSUInteger) indexPath.row];
    TBTeam *deleteTBTeam = [MTLManagedObjectAdapter modelOfClass:[TBTeam class] fromManagedObject:moTeam error:NULL];
    
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
                      
                      [self.dataArray removeObject:moTeam];
                      [self.tableView beginUpdates];
                      [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                      [self.tableView endUpdates];
                  }
                  else
                  {
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

- (void)refreshDataForNewTeam {
    [self fetchLocalData];
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.dataArray.count > 0) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray.count > 0) {
        if (section == 0) {
            return self.dataArray.count;
        } else {
            return 3;
        }
    } else {
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count > 0) {
        if (indexPath.section == 0) {
            return 50;
        } else {
            return 60;
        };
    } else {
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return 0;
    } else {
        return 10;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 5)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
        [footerView setBackgroundColor:[UIColor clearColor]];
        
        if (self.dataArray.count > 0) {
            UIView *footerAboveView = [[UIView alloc] initWithFrame:CGRectMake(0, 9, tableView.bounds.size.width, 1)];
            [footerAboveView setBackgroundColor:[UIColor grayColor]];
            [footerView addSubview:footerAboveView];
        }
        
        return footerView;
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 || self.dataArray.count == 0) {
        
        AddTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:AddTeamIdentifier forIndexPath:indexPath];
        
        switch (indexPath.row) {
            case 0:
                [cell setCellWithImageName:@"icon-add" andTitle:NSLocalizedString(@"Create a new team", @"Create a new team") andDescription:NSLocalizedString(@"Create a team for you" , @"Create a team for you" )];
                break;
                
            case 1:
                [cell setCellWithImageName:@"icon-scan" andTitle:NSLocalizedString(@"Scan to join a team", @"Scan to join a team") andDescription:NSLocalizedString(@"Scan to join a existing team", @"Scan to join a existing team")];
                break;
                
            case 2:
                [cell setCellWithImageName:@"icon-sync" andTitle:NSLocalizedString(@"Sync from Teambition", @"Sync from Teambition") andDescription:NSLocalizedString(@"Sync Teambition team", @"Sync Teambition team")];
                break;
                
            default:
                break;
        }
        
        cell.addTeamImage.backgroundColor = [UIColor whiteColor];
        cell.addTeamImage.layer.masksToBounds = YES;
        cell.addTeamImage.layer.cornerRadius = 20;
        cell.addTeamTitle.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
    }
    
    TBTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Get object at indexPath
    MOTeam *team = self.dataArray[(NSUInteger) indexPath.row];
    cell.nameLabel.text = team.name;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    // Check mark type accessory for selected team
    if ([team.id isEqualToString:self.selectedTeamID]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        if (team.unread.intValue > 0 ) {
            CGFloat badgeHeight = 20.0;
            M13BadgeView *unreadLabel = [[M13BadgeView alloc] initWithFrame:CGRectMake(0, 0, badgeHeight, badgeHeight)];
            unreadLabel.cornerRadius = badgeHeight/2;
            unreadLabel.font = [UIFont systemFontOfSize:13.0];
            NSString *unreadNumber = [NSString stringWithFormat:@"%@",team.unread];
            if (unreadNumber) {
                unreadLabel.text = unreadNumber;
            }
            cell.accessoryView = unreadLabel;
        }
        else
        {
            if ([[TBUtility currentAppDelegate].allNewTeamIdArray containsObject:team.id] || team.hasUnreadValue) {
                UIImageView *dotView  =[[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"icon-unread"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                dotView.tintColor = [UIColor redColor];
                [dotView setFrame:CGRectMake(0, 0, 10, 10)];
                cell.accessoryView = dotView;
            } else {
                cell.accessoryView = nil;
            }
        }
    }
    
    // Transform team color to corresponding UIColor selector
    cell.InitialNameLabel.hidden = NO;
    cell.cellImageView.hidden = YES;
    cell.InitialNameLabel.backgroundColor = [TBUtility getTopicRoomColorWith:team.color];
    NSString *teamNameAlif = [NSString getFirstWordWithEmojiForString:team.name];
    cell.InitialNameLabel.text = teamNameAlif;
    cell.tintColor = [UIColor whiteColor];
    cell.nameLabel.textColor = [UIColor whiteColor];
    if (iOS8)
    {
        cell.selectedBackgroundView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.shownIndexes containsObject:indexPath]) {
        [self.shownIndexes addObject:indexPath];
        UIView *card = (TBTeamCell* )cell;
        card.layer.transform = self.initialTransformation;
        card.layer.opacity = 0.8;
        
        NSTimeInterval delay;
        if (self.isViewDidAppear) {
            delay = 0;
        } else {
            if (indexPath.section == 0) {
                delay = 0.1 * indexPath.row;
            } else {
                delay = 0.1 * (indexPath.row + self.dataArray.count + 1);
            }
        }
        
        [UIView animateWithDuration:0.8 delay: delay usingSpringWithDamping:0.8 initialSpringVelocity:0.1 options:7<<16
                         animations:^{
                             card.layer.transform = CATransform3DIdentity;
                             card.layer.opacity = 1;
                         } completion:NULL];

    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if (section == 0 && self.dataArray.count > 0 && !self.isTeamListDidAppear) {
        self.isTeamListDidAppear = YES;
        UIView *sectionView = (UIView *)view;
        sectionView.layer.transform = self.initialTransformation;
        sectionView.layer.opacity = 0.8;
        NSInteger delay = self.dataArray.count - self.shownIndexes.count;
        if (delay < 0) {
            delay = self.dataArray.count;
        }
        [UIView animateWithDuration:0.8 delay: delay * 0.1 usingSpringWithDamping:0.8 initialSpringVelocity:0.1 options:7<<16 animations:^{
            sectionView.layer.transform = CATransform3DIdentity;
            sectionView.layer.opacity = 1;
        } completion:NULL];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.dataArray.count > 0) {
        MOTeam *team = self.dataArray[(NSUInteger) indexPath.row];
        if ([team.id isEqualToString:self.selectedTeamID]) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIActionSheet *deleteActionSheet = [UIActionSheet SH_actionSheetWithTitle:NSLocalizedString(@"Sure exit Team", @"Sure exit Team")];
    [deleteActionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Sure", @"Sure") withBlock:^(NSInteger theButtonIndex) {
        [self deleteAndExitTeamWithIndexPath:indexPath];
    }];
    [deleteActionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:^(NSInteger theButtonIndex) {
        [self.tableView setEditing:NO animated:YES];
    }];
    [deleteActionSheet showInView:self.view];
}

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Exit Team", @"Exit Team");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 || self.dataArray.count == 0) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"addNewTeam" sender:self];
        } else if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"scanQRCode" sender:self];
        } else if (indexPath.row == 2) {
            SyncTeamsViewController *syncVC = [[UIStoryboard storyboardWithName:kLoginStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"SyncTeamsViewController"];
            syncVC.delegate = self;
            [self.navigationController pushViewController:syncVC animated:YES];
        }
    }
    
    if (indexPath.section == 0 && self.dataArray.count > 0) {
        TBTeam *team = self.dataArray[(NSUInteger) indexPath.row];
        [self enterTeam:team];
    }
}

- (void)enterTeam:(TBTeam *)team {
    //remove team  from all new team
    if ([[TBUtility currentAppDelegate].allNewTeamIdArray containsObject:team.id]) {
        [[TBUtility currentAppDelegate].allNewTeamIdArray removeObject:team.id];
    }
    
    // Check  if selected team
    if ([team.id isEqualToString:self.selectedTeamID]) {
        [self cancelSelectTeam];
        return;
    }
    
    [TBUtility currentAppDelegate].isChangeTeam = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeamKey object:team];
}

#pragma mark - SyncTeamsDelegate

- (void)finishSyncTeamsWithTeamArray:(NSArray *)teamArray {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *newTBTeamArray = [MTLJSONAdapter modelsOfClass:[TBTeam class] fromJSONArray:teamArray error:NULL];
        [newTBTeamArray enumerateObjectsUsingBlock:^(TBTeam *team, NSUInteger idx, BOOL *stop) {
            [MTLManagedObjectAdapter
             managedObjectFromModel:team
             insertingIntoContext:localContext
             error:NULL];
        }];
    } completion:^(BOOL success, NSError *error) {
        [self fetchLocalData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)chooseTeamWithSourceId:(NSString *)sourceId {
    MOTeam *moTeam = [MOTeam MR_findFirstByAttribute:@"sourceId" withValue:sourceId];
    if (moTeam) {
        TBTeam *team = [MTLManagedObjectAdapter modelOfClass:[TBTeam class] fromManagedObject:moTeam error:NULL];
        if (team) {
            [self enterTeam:team];
        }
    }
}

@end
