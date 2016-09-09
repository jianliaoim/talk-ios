//
//  TopicColorTableViewController.m
//  Talk
//
//  Created by teambition-ios on 14/12/12.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "TopicColorTableViewController.h"
#import "TBColorPickerCell.h"
#import "TBUtility.h"
#import "SVProgressHUD.h"
#import "TBHTTPSessionManager.h"
#import <CoreData+MagicalRecord.h>
#import "constants.h"

#import "MORoom.h"
#import "MOTeam.h"

@interface TopicColorTableViewController ()
{
    NSArray *colorStrArray;
}
@end

@implementation TopicColorTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Color", @"Color");
    if (self.type == TopicColorVCTypeCreateTopic || self.type == TopicColorVCTypeTopicEdit) {
        colorStrArray = [NSArray arrayWithObjects:@"Purple",@"Indigo",@"Blue",@"Cyan",@"Grass",@"Yellow", nil];
    } else {
        colorStrArray = [NSArray arrayWithObjects:@"Grape",@"Blueberry",@"Ocean",@"Mint",@"Tea",@"Ink",nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - didSelected row for different type
//type TopicColorVCTypeTopicEdit
-(void)editTopicColorWith:(NSIndexPath *)indexPath
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
    
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    NSString *selectedColorStr = [[colorStrArray objectAtIndex:indexPath.row]lowercaseString];
    NSDictionary *params;
    params = [NSDictionary dictionaryWithObjectsAndKeys:selectedColorStr,@"color",nil];
    
    [manager PUT:[NSString stringWithFormat:@"%@/%@",kTopicURLString,[TBUtility currentAppDelegate].currentRoom.id]
      parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             
             [self processRoomTypeData:responseObject];
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             DDLogError(@"error: %@", error.localizedRecoverySuggestion);
             [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
         }];

}

/**
 *  parse data to save for update Room
 *
 *  @param responseObject http responseObject
 */
- (void)processRoomTypeData:(id)responseObject {
    NSDictionary *responseDic = (NSDictionary *)responseObject;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:[TBUtility currentAppDelegate].currentRoom.id];
        MORoom *currentRoom  = [MORoom MR_findFirstWithPredicate:predicate inContext:localContext];
        currentRoom.color = [responseDic objectForKey:@"color"];
    } completion:^(BOOL success, NSError *error) {
        if (success) {
            [TBUtility currentAppDelegate].currentRoom.color = [responseDic objectForKey:@"color"];
            if ([_delegate respondsToSelector:@selector(didChangedColor:)]) {
                [_delegate didChangedColor:[responseDic objectForKey:@"color"]];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Done")];
            });
        }
        else {
            [SVProgressHUD showSuccessWithStatus:error.localizedRecoverySuggestion];
        }
    }];
    
}

//type TopicColorVCTypeCreateTopic
-(void)createTopicColorWith:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(didChangedColor:)]) {
        NSString *selectedColorStr = [[colorStrArray objectAtIndex:indexPath.row]lowercaseString];
        [_delegate didChangedColor:selectedColorStr];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//type
-(void)editTeamColorWith:(NSIndexPath *)indexPath
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];

    NSString *selectedColorStr = [[colorStrArray objectAtIndex:indexPath.row]lowercaseString];
    NSDictionary *params;
    params = [NSDictionary dictionaryWithObjectsAndKeys:selectedColorStr,@"color",nil];

    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager PUT:[NSString stringWithFormat:@"%@/%@",kTeamURLString,[[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID]]
      parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             
             [self processTeamData:responseObject];
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             DDLogError(@"error: %@", error.localizedRecoverySuggestion);
             [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
         }];

}

/**
 *  parse data to save for update Team
 *
 *  @param responseObject http responseObject
 */
- (void)processTeamData:(id)responseObject {
    
    NSDictionary *responseDic = (NSDictionary *)responseObject;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MOTeam *currentTeam  = [MOTeam MR_findFirstByAttribute:@"id" withValue:[[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID] inContext:localContext];
        currentTeam.color = [responseDic objectForKey:@"color"];
    } completion:^(BOOL success, NSError *error) {
        if (success) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Done")];
            //[[NSNotificationCenter defaultCenter] postNotificationName:kEditTeamColorNotification object:[responseDic objectForKey:@"color"]];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            DDLogError(@"error: %@", error.localizedRecoverySuggestion);
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return colorStrArray.count;
}

//fix iOS 8.3 bug
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBColorPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TBColorPickerCell" forIndexPath:indexPath];
    // Configure the cell...
    NSString *tempColorStr = [colorStrArray objectAtIndex:indexPath.row];
    if (!tempColorStr) {
        tempColorStr = @"doc";
    }
    cell.colorNameLabel.text = NSLocalizedString(tempColorStr, tempColorStr);
    
    NSString *topicColorStr = [tempColorStr lowercaseString];
    NSString *teamColor = [NSString stringWithFormat:@"tb_%@Color", topicColorStr];
    SEL aSelector = NSSelectorFromString(teamColor);
    if ([UIColor respondsToSelector:aSelector]) {
        cell.colorLabel.backgroundColor = [UIColor performSelector:aSelector];
    } else {
        cell.colorLabel.backgroundColor = [UIColor jl_redColor];
    }
    cell.tintColor = [UIColor jl_redColor];
    if ([topicColorStr isEqualToString:[self.defaultColorStr lowercaseString]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TBColorPickerCell *cell = (TBColorPickerCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    switch (self.type) {
        case TopicColorVCTypeTopicEdit:
            [self editTopicColorWith:indexPath];
            break;
        case TopicColorVCTypeCreateTopic:
            [self createTopicColorWith:indexPath];
            break;
        case TopicColorVCTypeTeamEdit:
            [self editTeamColorWith:indexPath];
            break;
        case TopicColorVCTypeCreateTeam:
            [self createTopicColorWith:indexPath];
            break;
            
        default:
            break;
    }
}

@end
