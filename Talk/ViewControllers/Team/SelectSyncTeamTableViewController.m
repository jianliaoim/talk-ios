//
//  SelectSyncTeamTableViewController.m
//  Talk
//
//  Created by Suric on 15/11/27.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "SelectSyncTeamTableViewController.h"
#import "SelectSyncTeamCell.h"
#import "UITableViewController+Loading.h"
#import "TBHTTPSessionManager.h"
#import "TBUtility.h"
#import "SVProgressHUD.h"
#import "MOTeam.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>

static NSString *SelectSyncTeamCellidentifier = @"SelectSyncTeamCell";

@interface SelectSyncTeamTableViewController ()
@property (strong, nonatomic) NSArray *thirdTeams;
@property (strong, nonatomic) NSMutableArray *existTeamSourceIds;
@end

@implementation SelectSyncTeamTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.title = NSLocalizedString(@"Sync team", @"Sync team");
    
    //get exist sourceId array
    self.existTeamSourceIds = [[NSMutableArray alloc]init];
    NSArray *existTeams = [[MOTeam MR_findAll] copy];
    [existTeams enumerateObjectsUsingBlock:^(MOTeam *team, NSUInteger idx, BOOL * _Nonnull stop) {
        if (team.sourceId) {
            [self.existTeamSourceIds addObject:team.sourceId];
        }
    }];
    
    //fetch Third Teams
    [self fetchThirdTeams];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)fetchThirdTeams {
    [self startLoading];
    NSDictionary *params = @{@"refer": self.referString};
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:kTeamReadThirdsPath parameters:params success:^(NSURLSessionDataTask *task, NSArray *responseObject) {
        [self stopLoading];
        self.thirdTeams = responseObject;
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self stopLoading];
    }];
}

- (void)syncTeamAction:(TBButton *)sender {
    [sender startLoading];
    NSDictionary *teamInfo = [self.thirdTeams objectAtIndex:sender.indexPath.row];
    NSString *sourceId = teamInfo[@"sourceId"];
    
    NSDictionary *params = @{@"refer": self.referString, @"sourceId": sourceId};
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager POST:KTeamSyncOneFromThirdPath parameters:params success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        [sender stopLoading];
        if ([self.delegate respondsToSelector:@selector(syncTeamSuccessWithInfo:)] && responseObject) {
            [self.delegate syncTeamSuccessWithInfo:responseObject];
            [sender setTitle:NSLocalizedString(@"Sync again", @"Sync again") forState:UIControlStateNormal];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Sync success", @"Sync success")];
            if (![self.existTeamSourceIds containsObject:sourceId]) {
                [self.existTeamSourceIds addObject:sourceId];
                SelectSyncTeamCell *cell = [self.tableView cellForRowAtIndexPath:sender.indexPath];
                cell.enterTeamButton.enabled = YES;
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [sender stopLoading];
        [TBUtility showMessageInError:error];
    }];
}

- (void)enterTeamAction:(TBButton *)sender {
    if ([self.delegate respondsToSelector:@selector(enterTeamWithSourceId:)]) {
        NSDictionary *teamInfo = [self.thirdTeams objectAtIndex:sender.indexPath.row];
        NSString *sourceId = teamInfo[@"sourceId"];
        [self.delegate enterTeamWithSourceId:sourceId];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.thirdTeams.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectSyncTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:SelectSyncTeamCellidentifier forIndexPath:indexPath];
    // Config cell
    NSDictionary *teamInfo = [self.thirdTeams objectAtIndex:indexPath.row];
    NSString *teamName = teamInfo[@"name"];
    NSString *sourceId = teamInfo[@"sourceId"];
    cell.nameLabel.text = teamName;
    cell.syncButton.indexPath = indexPath;
    [cell.syncButton addTarget:self action:@selector(syncTeamAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.syncButton setBackgroundColor:self.navigationController.navigationBar.barTintColor];
    cell.enterTeamButton.indexPath = indexPath;
    [cell.enterTeamButton addTarget:self action:@selector(enterTeamAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.enterTeamButton setBackgroundColor:self.navigationController.navigationBar.barTintColor];
    if ([self.existTeamSourceIds containsObject:sourceId]) {
        [cell.syncButton setTitle:NSLocalizedString(@"Sync again", @"Sync again") forState:UIControlStateNormal];
        cell.enterTeamButton.enabled = YES;
    } else {
        [cell.syncButton setTitle:NSLocalizedString(@"Sync", @"Sync") forState:UIControlStateNormal];
        cell.enterTeamButton.enabled = NO;
    }
    
    return cell;
}

@end
