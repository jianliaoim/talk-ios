//
//  SyncTeamsViewController.m
//  Talk
//
//  Created by 史丹青 on 9/17/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "SyncTeamsViewController.h"
#import "SelectSyncTeamTableViewController.h"
#import "TBHTTPSessionManager.h"
#import "SVProgressHUD.h"
#import "Talk-Swift.h"
#import "UIColor+TBColor.h"

static NSString *SelectSyncTeamSegue = @"SelectSyncTeamSegue";

@interface SyncTeamsViewController ()<SelectSyncTeamTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *remindLabel;
@property (weak, nonatomic) IBOutlet UIButton *syncButton;
@property (nonatomic) BOOL hasBindTeambition;

@end

@implementation SyncTeamsViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Sync from Teambition", @"Sync from Teambition");
    self.remindLabel.text = NSLocalizedString(@"After you bind the Teambition, Talk can sync your team automatically.", @"After you bind the Teambition, Talk can sync your team automatically.");
    self.tableView.allowsSelection = NO;
    self.hasBindTeambition = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
    [self getUserBindStatus];
}

- (void)dealloc {
    [SVProgressHUD dismiss];
    [[TBHTTPSessionManager sharedManager] cancelAllHTTPOperationsWithPath:[kAccountBaseURLString stringByAppendingString:kCheckAllBindAccountsPath]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SelectSyncTeamSegue]) {
        SelectSyncTeamTableViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.referString = @"teambition";
    }
}

#pragma mark - IBActions

- (IBAction)clickSyncButton:(UIButton *)sender {
    if (self.hasBindTeambition) {
        [self performSegueWithIdentifier:SelectSyncTeamSegue sender:nil];
    } else {
        BindAccountViewController *bindVC = [[UIStoryboard storyboardWithName:kAppSettingStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"BindAccountViewController"];
        [self.navigationController pushViewController:bindVC animated:YES];
    }
}

#pragma mark - Private Methods

- (void)getUserBindStatus {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:[kAccountBaseURLString stringByAppendingString:kCheckAllBindAccountsPath] parameters:nil success:^(NSURLSessionDataTask *task, NSArray *responseObject) {
        [SVProgressHUD dismiss];
        for (NSDictionary *bindInfo in responseObject) {
            if ([bindInfo[@"login"] isEqualToString:@"teambition"]) {
                self.hasBindTeambition = YES;
                [self.syncButton setTitle:NSLocalizedString(@"Sync team", @"Sync team") forState:UIControlStateNormal];
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

#pragma mark - SelectSyncTeamTableViewControllerDelegate

- (void)syncTeamSuccessWithInfo:(NSDictionary *)teamInfo {
    if ([self.delegate respondsToSelector:@selector(finishSyncTeamsWithTeamArray:)]) {
        [self.delegate finishSyncTeamsWithTeamArray:[NSArray arrayWithObject:teamInfo]];
    }
}

- (void)enterTeamWithSourceId:(NSString *)sourceId {
    if ([self.delegate respondsToSelector:@selector(chooseTeamWithSourceId:)]) {
        [self.delegate chooseTeamWithSourceId:sourceId];
    }
}

@end
