//
//  AppSettingViewController.m
//  Talk
//
//  Created by 史丹青 on 15/4/23.
//  Copyright (c) 2015年 jiaoliao. All rights reserved.
//

#import "AppSettingViewController.h"
#import "NotificationSettingTableViewController.h"
#import "FeedbackTableViewController.h"
#import "TBHTTPSessionManager.h"
#import "SVProgressHUD.h"
#import "CoreData+MagicalRecord.h"
#import "constants.h"
#import "TBSocketManager.h"
#import "TBUtility.h"
#import "MOUser.h"
#import "TBPersonInfoCell.h"
#import "UIActionSheet+SHActionSheetBlocks.h"
#import "ChangeNameViewController.h"
#import "TBUser.h"
#import "TBTopicOpenCell.h"
#import "JLWebViewController.h"
#import "Talk-swift.h"
#import "TBFileSessionManager.h"
#import "MultiLanguageTableViewController.h"

#define privacyURL @"https://www.jianliao.com/privacy"

@interface AppSettingViewController () <UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,TBTopicOpenCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *appSettingTableView;
@property (weak, nonatomic) IBOutlet UILabel *buildVersionLabel;
@property (strong, nonatomic) MOUser *user;

@end

static NSString *const avatatCellIdentifier = @"TBPersonInfoCell";
static NSString *const hidePhoneCellIdentifier = @"TBHidePhoneCell";
static NSString *const nameCellIdentifier = @"userNameCell";

@implementation AppSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"App Settings", @"App Settings");
    
    self.appSettingTableView.delegate = self;
    self.appSettingTableView.dataSource = self;
    self.appSettingTableView.backgroundColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1];
    
    self.navigationController.navigationBar.barTintColor = [UIColor jl_redColor];
    self.navigationController.navigationBar.translucent = NO;
    
    NSString *versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildNUmber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    self.buildVersionLabel.text = [NSString stringWithFormat:@"%@ (Build %@)",versionStr,buildNUmber];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateName:) name:kPersonalInfoChangeNotification object:nil];
    
    //user info
    MOUser *user = [MOUser currentUser];
    self.user = user;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (IBAction)changePhotoAction:(id)sender {
    UIActionSheet *actionSheet = [UIActionSheet SH_actionSheetWithTitle:nil];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet SH_addButtonWithTitle:NSLocalizedString(@"Take a Photo", @"Take a Photo") withBlock:^(NSInteger theButtonIndex) {
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerController.delegate = self;
            pickerController.allowsEditing = YES;
            [self presentViewController:pickerController animated:YES completion:nil];
        }];
    }
    [actionSheet SH_addButtonWithTitle:NSLocalizedString(@"Choose From Library", @"Choose From Library") withBlock:^(NSInteger theButtonIndex) {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerController.delegate = self;
        pickerController.allowsEditing = YES;
        [self presentViewController:pickerController animated:YES completion:nil];
    }];
    [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:nil];
    [actionSheet showInView:self.view];
}

- (void)updateName:(NSNotification *)notification {
    MOUser *user = [MOUser currentUser];
    self.user = user;
    // save user id & name & avatar to user default
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.user.name forKey:kCurrentUserName];
    [defaults setValue:self.user.avatarURL forKey:kCurrentUserAvatar];

    [self.appSettingTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - TBOpenSwitchCellDelegate

//Mute Topic
-(void)hideMobileWith:(BOOL)isOpen {
    DDLogDebug(@"%d",isOpen);
    TBTopicOpenCell *hideMobileCell = (TBTopicOpenCell *)[self.appSettingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    NSDictionary *params = @{@"prefs": @{@"hideMobile":[NSNumber numberWithBool:isOpen]}};
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager PUT:[NSString stringWithFormat:@"%@/%@/prefs",kTeamURLString,[[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID]]
      parameters:params
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [SVProgressHUD dismiss];
             BOOL hideMobile = [[[responseObject objectForKey:@"prefs"] objectForKey:@"hideMobile"] boolValue];
             [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                 NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
                 MOUser *user = [MOUser findFirstWithId:userID inContext:localContext];
                 user.hideMobileValue = hideMobile;
             } completion:^(BOOL success, NSError *error) {
                 [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Done")];
             }];
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             hideMobileCell.openSwitch.on = !isOpen;
             DDLogError(@"error: %@", error.localizedRecoverySuggestion);
             [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
         }];
}

#pragma mark - tableview dataSource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.hasTeamInfo) {
        return 4;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if (self.hasTeamInfo) {
            return 4;
        } else {
            return 3;
        }
    }
    else if (section == 1) {
        if (self.hasTeamInfo) {
            return 1;
        } else {
            return 6;
        }
    }
    else if (section == 2) {
        if (self.hasTeamInfo) {
            return 6;
        } else {
            return 1;
        }
    }
    else {
        return 1;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        UITableViewCell *cell;
        switch (indexPath.row) {
            case 0: {
                TBPersonInfoCell *avatarCell = [tableView dequeueReusableCellWithIdentifier:avatatCellIdentifier forIndexPath:indexPath];
                [avatarCell.nameImageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatarURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
                avatarCell.nameLabel.text = NSLocalizedString(@"Avatar", @"Avatar");
                cell = avatarCell;
            }
                break;
            case 1: {
                cell = [tableView dequeueReusableCellWithIdentifier:nameCellIdentifier forIndexPath:indexPath];
                cell.textLabel.text = NSLocalizedString(@"Name", @"Name");
                cell.detailTextLabel.text = self.user.name;
            }
                break;
            case 2: {
                if (self.hasTeamInfo) {
                    cell = [tableView dequeueReusableCellWithIdentifier:nameCellIdentifier forIndexPath:indexPath];
                    cell.textLabel.text = NSLocalizedString(@"Alias in team", @"Alias in team");
                    cell.detailTextLabel.text = self.user.alias;
                } else {
                    cell = [tableView dequeueReusableCellWithIdentifier:nameCellIdentifier forIndexPath:indexPath];
                    cell.textLabel.text = NSLocalizedString(@"Email", @"Email");
                    cell.detailTextLabel.text = self.user.email;
                }
            }
                break;
            case 3: {
                cell = [tableView dequeueReusableCellWithIdentifier:nameCellIdentifier forIndexPath:indexPath];
                cell.textLabel.text = NSLocalizedString(@"Email", @"Email");
                cell.detailTextLabel.text = self.user.email;
            }
                break;
            default:
                break;
        }
        return cell;
    } else if (indexPath.section == 1) {
        if (self.hasTeamInfo) {
            TBTopicOpenCell *switchCell = [tableView dequeueReusableCellWithIdentifier:hidePhoneCellIdentifier forIndexPath:indexPath];
            switchCell.switchType = TBTopicSwitchCellTypeHideMobile;
            switchCell.delegate = self;
            switchCell.nameLabel.text = NSLocalizedString(@"Hide phone", @"Hide phone");
            switchCell.openSwitch.on = self.user.hideMobileValue;
            return switchCell;
        } else {
            static NSString *CellIdentifier = @"appSettingCell";
            static NSString *LanguageCellIdentifier = @"languageSettingCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"Linked accounts",@"Linked accounts");
                    break;
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"Notifications",@"Notifications");
                    break;
                case 2: {
                    cell = [tableView dequeueReusableCellWithIdentifier:LanguageCellIdentifier];
                    cell.textLabel.text = NSLocalizedString(@"Language", @"Language");
                    cell.detailTextLabel.text = [JLInternationalManager userLanguageString];
                    break;
                }
                case 3:
                    cell.textLabel.text = NSLocalizedString(@"FeedBack",@"FeedBack");
                    break;
                case 4:
                    cell.textLabel.text = NSLocalizedString(@"Terms of service",@"Terms of service");
                    break;
                case 5:
                    cell.textLabel.text = NSLocalizedString(@"Rate Talk in App Store", @"Rate Talk in App Store");
                    break;
                default:
                    break;
            }
            
            return cell;
        }
    }
    else if (indexPath.section == 2) {
        if (self.hasTeamInfo) {
            static NSString *CellIdentifier = @"appSettingCell";
            static NSString *LanguageCellIdentifier = @"languageSettingCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"Linked accounts",@"Linked accounts");
                    break;
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"Notifications",@"Notifications");
                    break;
                case 2: {
                    cell = [tableView dequeueReusableCellWithIdentifier:LanguageCellIdentifier];
                    cell.textLabel.text = NSLocalizedString(@"Language", @"Language");
                    cell.detailTextLabel.text = [JLInternationalManager userLanguageString];
                    break;
                }
                case 3:
                    cell.textLabel.text = NSLocalizedString(@"FeedBack",@"FeedBack");
                    break;
                case 4:
                    cell.textLabel.text = NSLocalizedString(@"Terms of service",@"Terms of service");
                    break;
                case 5:
                    cell.textLabel.text = NSLocalizedString(@"Rate Talk in App Store", @"Rate Talk in App Store");
                    break;
                default:
                    break;
            }
            
            return cell;
        } else {
            static NSString *CellIdentifier = @"appLogoutCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.textLabel.text = NSLocalizedString(@"LOGOUT_ACCOUNT_DESCTRUCTIVE_TITLE",@"LOGOUT_ACCOUNT_DESCTRUCTIVE_TITLE");
            return cell;
        }
    }
    else {
        static NSString *CellIdentifier = @"appLogoutCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = NSLocalizedString(@"LOGOUT_ACCOUNT_DESCTRUCTIVE_TITLE",@"LOGOUT_ACCOUNT_DESCTRUCTIVE_TITLE");
        return cell;
    }
    
}

#pragma mark - tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self.appSettingTableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.row == 0) {
            [self changePhotoAction:nil];
        }
        else if (indexPath.row == 1) {
            ChangeNameViewController *nameViewController = [[UIStoryboard storyboardWithName:kMeInfoStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChangeNameViewController"];
            nameViewController.name = self.user.name;
            nameViewController.title = NSLocalizedString(@"Name", @"Name");

            [self.navigationController pushViewController:nameViewController animated:YES];
        }
        else if (indexPath.row == 2) {
            if (self.hasTeamInfo) {
                UITableViewCell *aliasCell = [self.appSettingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
                ChangeNameViewController *phoneViewController = [[UIStoryboard storyboardWithName:kMeInfoStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChangeNameViewController"];
                phoneViewController.name = aliasCell.detailTextLabel.text;
                phoneViewController.isEditAlias = YES;
                phoneViewController.title = NSLocalizedString(@"Alias in team", @"Alias in team");
                [self.navigationController pushViewController:phoneViewController animated:YES];
            } else {
                [self changEmail];
            }
        }
        else if (indexPath.row == 3) {
            [self changEmail];
        }
    }
    else if (indexPath.section == 1) {
        if (!self.hasTeamInfo) {
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"linkAccounts" sender:self];
            }
            if (indexPath.row == 1) {
                [self performSegueWithIdentifier:@"notification" sender:self];
            }
            if (indexPath.row == 2) {
                MultiLanguageTableViewController *languageViewController = [MultiLanguageTableViewController new];
                [self.navigationController pushViewController:languageViewController animated:YES];
            }
            if (indexPath.row == 3) {
                [self performSegueWithIdentifier:@"feedback" sender:self];
            }
            if (indexPath.row == 4) {
                JLWebViewController *jsViewController = [[JLWebViewController alloc]init];
                jsViewController.hidesBottomBarWhenPushed = YES;
                jsViewController.urlString = privacyURL;
                [self.navigationController pushViewController:jsViewController animated:YES];
            }
            if (indexPath.row == 5) {
                NSString *iTunesLink = @"itms-apps://itunes.apple.com/cn/app/jian-liao-jiaoliao-zui-hao/id922425179?mt=8";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
            }
            [self.appSettingTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    //logout
    else if (indexPath.section == 2) {
        if (self.hasTeamInfo) {
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"linkAccounts" sender:self];
            }
            if (indexPath.row == 1) {
                [self performSegueWithIdentifier:@"notification" sender:self];
            }
            if (indexPath.row == 2) {
                MultiLanguageTableViewController *languageViewController = [[MultiLanguageTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                [self.navigationController pushViewController:languageViewController animated:YES];
            }
            if (indexPath.row == 3) {
                [self performSegueWithIdentifier:@"feedback" sender:self];
            }
            if (indexPath.row == 4) {
                JLWebViewController *jsViewController = [[JLWebViewController alloc]init];
                jsViewController.hidesBottomBarWhenPushed = YES;
                jsViewController.urlString = privacyURL;
                [self.navigationController pushViewController:jsViewController animated:YES];
            }
            if (indexPath.row == 5) {
                NSString *iTunesLink = @"itms-apps://itunes.apple.com/cn/app/jian-liao-jiaoliao-zui-hao/id922425179?mt=8";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
            }
            [self.appSettingTableView deselectRowAtIndexPath:indexPath animated:YES];
        } else {
            [self logoutWithIndexPath:indexPath];
        }
    }
    else {
        [self logoutWithIndexPath:indexPath];
    }
}

- (void)changEmail {
    ChangeNameViewController *phoneViewController = [[UIStoryboard storyboardWithName:kMeInfoStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChangeNameViewController"];
    phoneViewController.name = self.user.email;
    phoneViewController.isEditEmail = YES;
    phoneViewController.title = NSLocalizedString(@"Email", @"Email");
    [self.navigationController pushViewController:phoneViewController animated:YES];
}

- (void)logoutWithIndexPath:(NSIndexPath *)indexPath {
    UIActionSheet *actionSheet =
    [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"LOGOUT_ACCOUNT_TITLE", @"LOGOUT_ACCOUNT_TITLE")
                                delegate:self
                       cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                  destructiveButtonTitle:NSLocalizedString(@"LOGOUT_ACCOUNT_DESCTRUCTIVE_TITLE", @"LOGOUT_ACCOUNT_DESCTRUCTIVE_TITLE")
                       otherButtonTitles:nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
    [self.appSettingTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self logoutAccount];
    }
}

#pragma mark - Helper
- (void)logoutAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [defaults valueForKey:kDeviceToken];
    NSDictionary *parameters = [NSDictionary dictionary];
    if (deviceToken) {
        parameters = @{ @"token": deviceToken };
    }
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager POST:kLogoutURLString
       parameters:parameters
          success:^(NSURLSessionDataTask *task, id responseObject) {
              DDLogVerbose(@"Successfully logout!");
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              DDLogError(@"Logout error: %@", error);
          }];
    [manager.requestSerializer clearAuthorizationHeader];
    [manager.requestSerializer setValue:nil forHTTPHeaderField:@"x-socket-id"];
    
    //[SSKeychain deletePasswordForService:APP_NAME account:@"default"];
    //[defaults removePersistentDomainForName:APP_NAME];
    
    //close remote notification when logout
    [[UIApplication sharedApplication]unregisterForRemoteNotifications];
    
    // Close socket when logout
    [[TBSocketManager sharedManager] closeSocket];
    
    //Clear NSUserDefaults
    [defaults setBool:NO forKey:kUserHaveLogin];
    [defaults setValue:nil forKey:kCurrentTeamID];
    //clean linked account
    [defaults setValue:nil forKey:kCurrentUserEmail];
    [defaults setValue:nil forKey:kCurrentUserPhone];
    [defaults setValue:nil forKey:kCurrentUserWechat];
    [defaults synchronize];
    
    //Clear App groups NSUserDefaults
    NSUserDefaults *groupDeafaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
    [groupDeafaults setBool:NO forKey:kUserHaveLogin];
    [groupDeafaults setValue:nil forKey:kCurrentTeamID];
    [groupDeafaults synchronize];
    
    // Clear cookie for login web view
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    // Clear core data
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
    [self cleanCoreData];
}

- (void)cleanCoreData {
    [[TBUtility currentAppDelegate]cleanAndResetupDB];
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Succeed", @"Succeed")];
    if (!self.hasTeamInfo) {
        DDLogDebug(@"logout from choose team");
        if ([self.navigationController.viewControllers[0] isKindOfClass:[ChooseTeamViewController class]]) {
            [self dismissViewControllerAnimated:NO completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidLogoutKey object:nil];
            }];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } else {
        DDLogDebug(@"logout from Root view controller");
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidLogoutKey object:nil];
    }
}

#pragma mark - imagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *organizationLogoImage = (UIImage*) info[UIImagePickerControllerEditedImage];
    NSData *imageData = UIImagePNGRepresentation(organizationLogoImage);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"please wait...", @"please wait...")];
    [[TBFileSessionManager sharedManager] POST:kUploadURLString parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"avatar.png" mimeType:@"image/png"];
    }
                                       success:^(NSURLSessionDataTask *task, id responseObject) {
                                           DDLogVerbose(@"Image upload successfully.");
                                           
                                           if ([responseObject valueForKey:@"thumbnailUrl"]) {
                                               NSString *URLString = [responseObject valueForKey:@"thumbnailUrl"];
                                               self.user.avatarURL = URLString;
                                               [self updateUserAvatar];
                                           }
                                       }
                                       failure:^(NSURLSessionDataTask *task, NSError *error) {
                                           DDLogError(@"Image upload failed.");
                                           [SVProgressHUD showErrorWithStatus:[error localizedRecoverySuggestion]];
                                       }];
}

- (void)updateUserAvatar {
    NSString *avatarURL = self.user.avatarURL;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:avatarURL forKey:@"avatarUrl"];
    
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager PUT:[NSString stringWithFormat:@"users/%@", self.user.id]
      parameters:parameters
         success:^(NSURLSessionDataTask *task, id responseObject) {
             DDLogVerbose(@"Successfully updated avatar");
             [[TBSocketManager sharedManager] userUpdateWith:responseObject completion:^(BOOL success, NSError *error) {
                 TBPersonInfoCell *cell = (TBPersonInfoCell *)[self.appSettingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                 [cell.nameImageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatarURL]];
                 [[NSUserDefaults standardUserDefaults] setValue:self.user.avatarURL forKey:kCurrentUserAvatar];
                 [[NSNotificationCenter defaultCenter] postNotificationName:kAvatarChangeNotification object:nil];
                 [SVProgressHUD dismiss];
             }];
         }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
             DDLogError(@"error: %@", error.localizedRecoverySuggestion);
             [SVProgressHUD showErrorWithStatus:[error localizedRecoverySuggestion]];
         }];
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
