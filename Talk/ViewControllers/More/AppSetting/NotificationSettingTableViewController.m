//
//  NotificationSettingTableViewController.m
//  Talk
//
//  Created by Suric on 14/11/1.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "NotificationSettingTableViewController.h"
#import "SVProgressHUD.h"
#import "constants.h"
#import "TBUtility.h"
#import "TBHTTPSessionManager.h"
#import "JLSwitchButtonCell.h"
#import "TBHTTPSessionManager.h"

static  NSString *CellIdentification = @"NotificationCell";
static  NSString *SwitchCellIdentification = @"JLSwitchButtonCell";
static  NSString *kNotificationOnMe = @"notifyOnRelated";

@interface NotificationSettingTableViewController () <JLSwitchButtonCellDelegate>
@property (nonatomic) NSInteger selectedRow;
@property (nonatomic) BOOL isMuteWhenWebOnline;
@property (nonatomic) BOOL isPushOnWorkTime;
@end

@implementation NotificationSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Notifications", @"Notifications");
    [self fetchNotificationSetting];
    [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
}

- (void)fetchNotificationSetting {
    [self jadgeSelectedRow];
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:kMeInfoURLString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *notificationSetting = responseObject[@"preference"];
        self.isMuteWhenWebOnline = [notificationSetting[@"muteWhenWebOnline"] boolValue];
        self.isPushOnWorkTime = [notificationSetting[@"pushOnWorkTime"] boolValue];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)jadgeSelectedRow {
    //notification switch
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kCloseRemoteNotification]) {
        self.selectedRow = 2;
    } else {
        //notify me switch
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kNotifyOnRelated]) {
            self.selectedRow = 1;
        } else {
            self.selectedRow = 0;
        }
    }
}

- (void)setNotificationOpen:(BOOL)open {
    if (open) {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:kCloseRemoteNotification];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[TBUtility currentAppDelegate] openRemoteNotification];
    } else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kCloseRemoteNotification];
    }
}

-(void)setNotificationIsRelatedMe:(BOOL)isRelatedMe {
    NSDictionary *params = @{kNotificationOnMe : [NSNumber numberWithBool:isRelatedMe]};
    [[TBHTTPSessionManager sharedManager] PUT:kPreferencesURLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [[NSUserDefaults standardUserDefaults] setBool:isRelatedMe forKey:kNotifyOnRelated];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kCloseRemoteNotification]) {
            [self setNotificationOpen:YES];
        }
        [self jadgeSelectedRow];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source && Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentification forIndexPath:indexPath];
        cell.tintColor = [UIColor jl_redColor];
        NSString *nameString;
        switch (indexPath.row) {
            case 0:
                nameString = NSLocalizedString(@"Nofication all", @"Nofication all");
                break;
            case 1:
                nameString = NSLocalizedString(@"Nofication about self", @"Nofication about self");
                break;
            case 2:
                nameString = NSLocalizedString(@"Nofication closed", @"Nofication closed");
                break;
                
            default:
                break;
        }
        cell.textLabel.text = nameString;
        if (indexPath.row == self.selectedRow) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    } else if (indexPath.section == 1) {
        JLSwitchButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:SwitchCellIdentification forIndexPath:indexPath];
        cell.switchFor = kMuteWhenWebOnline;
        [cell setCellTitle:NSLocalizedString(@"Mute when web online", @"Mute when web online")];
        [cell.switchButton setOn:self.isMuteWhenWebOnline];
        cell.delegate = self;
        return cell;
    } else {
        JLSwitchButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:SwitchCellIdentification forIndexPath:indexPath];
        cell.switchFor = kPushOnWorkTime;
        [cell setCellTitle:NSLocalizedString(@"Notification on work time", @"Notification on work time")];
        [cell.switchButton setOn:self.isPushOnWorkTime];
        cell.delegate = self;
        return cell;
    }
}

//fix iOS 8.3 bug
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    switch (indexPath.row) {
        case 0:
            [self setNotificationIsRelatedMe:NO];
            break;
        case 1:
            [self setNotificationIsRelatedMe:YES];
            break;
        case 2: {
            [self setNotificationOpen:NO];
            [self jadgeSelectedRow];
            [self.tableView reloadData];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - JLSwitchButtonCellDelegate
- (void)switchButtonTo:(BOOL)onOrNot for:(NSString *)switchFor {
    if ([switchFor isEqualToString:kMuteWhenWebOnline]) {
        NSDictionary *params = @{kMuteWhenWebOnline : [NSNumber numberWithBool:onOrNot]};
        [[TBHTTPSessionManager sharedManager] PUT:kPreferencesURLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            [[NSUserDefaults standardUserDefaults] setBool:onOrNot forKey:kMuteWhenWebOnline];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
            }
        }];
    } else if ([switchFor isEqualToString:kPushOnWorkTime]) {
        NSTimeZone *timeZone = [NSTimeZone localTimeZone];
        NSString *tzName = [timeZone name];
        NSDictionary *params = @{
                                 kPushOnWorkTime : [NSNumber numberWithBool:onOrNot],
                                 @"timezone": tzName
                                 };
        [[TBHTTPSessionManager sharedManager] PUT:kPreferencesURLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            [[NSUserDefaults standardUserDefaults] setBool:onOrNot forKey:kPushOnWorkTime];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
            }
        }];
    }
    
}

@end
