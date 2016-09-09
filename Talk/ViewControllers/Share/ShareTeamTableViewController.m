//
//  ShareTeamTableViewController.m
//  
//
//  Created by Suric on 15/8/19.
//
//

#import "ShareTeamTableViewController.h"
#import "constants.h"
#import "MOTeam.h"
#import "CoreData+MagicalRecord.h"
#import "UIColor+TBColor.h"
#import "SVProgressHUD.h"
#import "TBUtility.h"
#import "TBTeamCell.h"

@interface ShareTeamTableViewController ()
@property (strong ,nonatomic) NSMutableArray *dataArray;
@end

static NSString *CellIdentifier = @"TeamNameCell";

@implementation ShareTeamTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Select team", @"Select team");
    
    self.tableView.rowHeight = 44.0f;
    self.tableView.tableFooterView = [UIView new];
    self.dataArray = [NSMutableArray arrayWithArray:[MOTeam MR_findAllSortedBy:@"unread,updatedAt" ascending:NO]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.tintColor = [UIColor jl_redColor];
    MOTeam *team = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = team.name;
    if ([self.selectedTeamID isEqualToString:team.id]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(selecteTeam:)]) {
        MOTeam *team = [self.dataArray objectAtIndex:indexPath.row];
        [self.delegate selecteTeam:team];
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
