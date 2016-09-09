//
//  MoreTableViewController.m
//  Talk
//
//  Created by 史丹青 on 15/4/23.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "MoreTableViewController.h"
#import "ItemsViewController.h"
#import "constants.h"
#import "TBMoreCell.h"
#import "UIColor+TBColor.h"
#import "FavoritesTableViewController.h"
#import "TagsViewController.h"

#import "CoreData+MagicalRecord.h"
#import "MOTeam.h"
#import "TBTeam.h"
#import "TBUser.h"
#import "MOUser.h"

@interface MoreTableViewController ()

@end

@implementation MoreTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorColor = self.tableView.backgroundColor;
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOtherTeamUnread) name:kUpdateOtherTeamUnread object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"moreCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.moreCellName.text = NSLocalizedString(@"Favorites", @"Favorites");
        [cell.moreCellImage setImage:[UIImage imageNamed:@"icon-star"]];
        cell.divider.hidden = YES;
    }
    if (indexPath.row == 1) {
        cell.moreCellName.text = NSLocalizedString(@"Items", @"Items");
        [cell.moreCellImage setImage:[UIImage imageNamed:@"icon-shelf"]];
        cell.divider.hidden = YES;
    }
    if (indexPath.row == 2) {
        cell.moreCellName.text = NSLocalizedString(@"Tags", @"Tags");
        [cell.moreCellImage setImage:[UIImage imageNamed:@"icon-tags"]];
        cell.divider.hidden = YES;
    }
    if (indexPath.row == 3) {
        cell.moreCellName.text = NSLocalizedString(@"@Messages", @"@Messages");
        [cell.moreCellImage setImage:[UIImage imageNamed:@"icon-at"]];
        cell.divider.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        FavoritesTableViewController *viewController = [[UIStoryboard storyboardWithName:@"Favorites" bundle:nil] instantiateViewControllerWithIdentifier:@"FavoritesTableViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.row == 1) {
        ItemsViewController *viewController = [[UIStoryboard storyboardWithName:@"Items" bundle:nil] instantiateViewControllerWithIdentifier:@"ItemsViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.row == 2) {
        TagsViewController *viewController = [[UIStoryboard storyboardWithName:@"Tags" bundle:nil] instantiateViewControllerWithIdentifier:@"TagsViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
    } else if (indexPath.row == 3) {
        FavoritesTableViewController *viewController = [[UIStoryboard storyboardWithName:@"Favorites" bundle:nil] instantiateViewControllerWithIdentifier:@"FavoritesTableViewController"];
        viewController.type = JLCategoryTypeAt;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
