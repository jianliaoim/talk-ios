//
//  NewTeamViewController.m
//  Talk
//
//  Created by Shire on 10/16/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import "NewTeamViewController.h"
#import "constants.h"
#import "TBHTTPSessionManager.h"
#import "AddTeamMembersViewController.h"
#import <CoreData+MagicalRecord.h>
#import "SVProgressHUD.h"
#import "TBTopicColorCell.h"
#import "TopicColorTableViewController.h"
#import "UIColor+TBColor.h"
#import "constants.h"
#import "TBUtility.h"

#import "MOTeam.h"
#import "TBTeam.h"
#import "AddMemberMethodsTableViewController.h"

@interface NewTeamViewController ()<TopicColorTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextItem;
@property(weak, nonatomic) IBOutlet UITextField *nameField;
@property(strong, nonatomic) UIActivityIndicatorView *indicator;
@property(strong,nonatomic) NSString *colorStr;

- (IBAction)nameChanged:(UITextField *)sender;
- (IBAction)nextPressed:(UIBarButtonItem *)sender;

@end

@implementation NewTeamViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self commonInit];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    [self.navigationController.navigationBar setBarTintColor:[UIColor tb_defaultColor]];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.nameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helper

- (void)commonInit {
    self.title = NSLocalizedString(@"New team", @"New team");
    self.nameField.placeholder = NSLocalizedString(@"Team name", @"Team name");
    
    self.nextItem.title = NSLocalizedString(@"", @"");
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.colorStr = @"ocean";
}

#pragma mark - Selector

- (IBAction)nameChanged:(UITextField *)sender {
    self.navigationItem.rightBarButtonItem.enabled = !EMPTY_STRING(sender.text);
}

- (IBAction)nextPressed:(UIBarButtonItem *)sender {
    [TBUtility sendAnalyticsEventWithCategory:kAnalyticsCategorySwitchTeams action:kAnalyticsActionCreateTeam label:@"" value:nil];
    [self.nameField resignFirstResponder];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicator];
    [self.indicator startAnimating];

    NSMutableDictionary *nameParameters = [NSMutableDictionary dictionary];
    [nameParameters setValue:self.nameField.text forKey:@"name"];
    [nameParameters setValue:self.colorStr forKey:@"color"];
    
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager POST:kTeamURLString
       parameters:nameParameters
          success:^(NSURLSessionDataTask *task, id responseObject) {
              TBTeam *newTeam = [MTLJSONAdapter modelOfClass:[TBTeam class] fromJSONDictionary:responseObject error:nil];
              [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                  MOTeam *newMOTeam = [MTLManagedObjectAdapter managedObjectFromModel:newTeam insertingIntoContext:localContext error:nil];
                  if (newMOTeam) {
                      DDLogDebug(@"save new team success");
                  }
              } completion:^(BOOL success, NSError *error) {
                  if (success) {
                      DDLogVerbose(@"Successfully created team");
                      [[NSNotificationCenter defaultCenter]postNotificationName:kTeamCreateNotification object:nil];
                      [self navToInvitationWithNewTeam:newTeam];
                  } else {
                      DDLogVerbose(@"error created team: %@",error);
                      [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                  }
              }];
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              DDLogError(@"error: %@", error.localizedRecoverySuggestion);
          }];
}

- (void)navToInvitationWithNewTeam:(TBTeam *)newTeam {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:newTeam.id forKey:kCurrentTeamID];
    [defaults synchronize];

    AddMemberMethodsTableViewController *addMemberVC = [[UIStoryboard storyboardWithName:kAddMemberMethodsStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"addMemberMethods"];
    addMemberVC.currentTeam = newTeam;
    [self.navigationController pushViewController:addMemberVC animated:YES];
}

#pragma mark - Table view data source
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - TopicColorTableViewControllerDelegate
-(void)didChangedColor:(NSString *)color
{
    self.colorStr = color;
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
