//
//  AddMemberMethodsTableViewController.m
//  Talk
//
//  Created by 史丹青 on 6/10/15.
//  Copyright (c) 2015 jiaoliao. All rights reserved.
//

#import "AddMemberMethodsTableViewController.h"
#import "TBMoreCell.h"
#import "TBUtility.h"
#import "AddTeamMembersViewController.h"
#import "PhoneContactViewController.h"
#import "TeamQRCodeViewController.h"
#import "RootViewController.h"
#import "SVProgressHUD.h"
#import <AddressBook/AddressBook.h>
#import "TBContact.h"
#import "MOUser.h"
#import "constants.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "NSString+Emoji.h"
#import <Hanzi2Pinyin.h>
#import "TBUtility.h"
#import "TBContactCell.h"
#import "TBHTTPSessionManager.h"
#import "SVProgressHUD.h"
#import "TBSocketManager.h"
#import "MOTeam.h"
#import "Talk-Swift.h"
#import "TBHTTPSessionManager.h"
#import "TeamQRCodeViewController.h"
#import "JLActionSheetViewController.h"

static NSString * const contactCellIdentifier = @"contactCell";
static NSString * const inviteCellIdentifier = @"inviteCell";

@interface AddMemberMethodsTableViewController () <RemindViewDelegate, MFMessageComposeViewControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
@property (assign, nonatomic) BOOL isSearching;
@property (strong, nonatomic) NSMutableArray *localContactArray;
@property (strong, nonatomic) NSMutableArray *searchData;
@property (strong, nonatomic) NSString *smsPhoneNumber;
@property (assign, nonatomic) ABAddressBookRef addressBook;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableViewController *searchResultController;

@end

@implementation AddMemberMethodsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setHidesBottomBarWhenPushed:YES];
    self.title = NSLocalizedString(@"Invite member", @"Invite member");
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    self.tableView.scrollEnabled = NO;
    if (self.currentTeam) {
        [self.navigationItem setHidesBackButton:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
        [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
    }
    
    self.localContactArray = [[NSMutableArray alloc] init];
    self.searchData = [[NSMutableArray alloc] init];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self setIsSearching:NO];
    
    _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    [self checkAddressBookAccess];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter

- (UITableViewController *)searchResultController {
    if (!_searchResultController) {
        //Create searchResultController for UISearchController
        _searchResultController = [[UITableViewController alloc] init];
        _searchResultController.tableView.delegate = self;
        _searchResultController.tableView.dataSource = self;
        _searchResultController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_searchResultController.tableView registerClass:[TBContactCell class] forCellReuseIdentifier:contactCellIdentifier];
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
        _searchController.dimsBackgroundDuringPresentation = YES;
        _searchController.searchBar.placeholder = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Phone/Email", "Phone/Email")];
        _searchController.searchBar.backgroundImage = [UIImage imageNamed:@"icon-contact-search-background"];
        _searchController.searchBar.tintColor = [UIColor jl_redColor];
    }
    return _searchController;
}

#pragma mark - IBAction

- (IBAction)inviteContactByPhone:(TBButton *)sender {
    TBContact *contact;
    if (self.isSearching) {
        contact = (self.searchData)[sender.indexPath.row];
    } 
    [self getUserInfo:contact];
}

#pragma mark - HTTP

- (void)getUserInfo:(TBContact *)contact {
    BOOL isPhone = contact.phone ? YES : NO;
    NSDictionary *parameter;
    if (isPhone) {
        parameter = @{@"mobiles":@[contact.phone]};
    } else {
        parameter = @{@"emails":@[contact.email]};
    }
    [[TBHTTPSessionManager sharedManager] GET:kGetUserInfoWithPhoneURLString parameters:parameter success:^(NSURLSessionDataTask *task, NSArray *responseObject){
        if (responseObject.count != 0) {
            if (isPhone) {
                [self inviteWithPhone:contact.phone hasAccount:YES];
            } else {
                [self inviteWithEmail:contact.email hasAccount:YES];
            }
        } else {
            [self.searchController.searchBar resignFirstResponder];
            if (isPhone) {
                [self showSendMessageRemindView:contact.phone];
            } else {
                [self inviteWithEmail:contact.email hasAccount:NO];
            }
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error){
        //failure
        NSString *errorCode = [TBUtility getApiErrorCodeWithError:error];
        if ([errorCode isEqualToString:@"400302"]) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Valid phonenumber", @"Valid phonenumber")];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        }
    }];
}

- (void)inviteWithPhone:(NSString *)phone hasAccount:(BOOL)hasJianLiaoAccount {
    [self inviteWithAccount:phone isPhone:YES hasAccount:hasJianLiaoAccount];
}

- (void)inviteWithEmail:(NSString *)email hasAccount:(BOOL)hasJianLiaoAccount {
    [self inviteWithAccount:email isPhone:NO hasAccount:hasJianLiaoAccount];
}

- (void)inviteWithAccount:(NSString *)account isPhone:(BOOL)isPhone hasAccount:(BOOL)hasJianLiaoAccount {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"please wait...", @"please wait...")];
    NSDictionary *parameter;
    if (isPhone) {
        parameter = @{@"mobile":account};
    } else {
        parameter = @{@"email":account};
    }
    [[TBHTTPSessionManager sharedManager] POST:[NSString stringWithFormat:kTeamInviteURLString,[[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID]] parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject){
        //success
        if (hasJianLiaoAccount) {
            [[TBSocketManager sharedManager] teamJoinWith:responseObject];
        } else {
            [[TBSocketManager sharedManager] invitationCreatWith:responseObject];
        }
        if (self.isSearching) {
            for (int i = 0; i < self.searchData.count; i++) {
                if (isPhone) {
                    if ([((TBContact *)self.searchData[i]).originPhone isEqualToString:account] || [((TBContact *)self.searchData[i]).phone isEqualToString:account]) {
                        ((TBContact *)self.searchData[i]).isInTeam = YES;
                    }
                } else {
                    if ([((TBContact *)self.searchData[i]).email isEqualToString:account]) {
                        ((TBContact *)self.searchData[i]).isInTeam = YES;
                    }
                }
            }
            [self.searchResultController.tableView reloadData];
        }
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Invite success", @"Invite success")];
    }failure:^(NSURLSessionDataTask *task, NSError *error){
        //failure
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

#pragma mark - Private Methods

//send Team Invite
- (void)sendTeamInvite {
    NSString *inviteString;
    if (self.currentTeam) {
        inviteString = [NSString stringWithFormat:NSLocalizedString(@"Team invite text", @"Team invite text"),self.currentTeam.name, self.currentTeam.inviteURL.absoluteString, self.currentTeam.inviteCode];
    } else {
        NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
        MOTeam *team = [MOTeam MR_findFirstByAttribute:@"id" withValue:currentTeamID];
        inviteString = [NSString stringWithFormat:NSLocalizedString(@"Team invite text", @"Team invite text"),team.name, team.inviteURL, team.inviteCode];
    }
    JLActionSheetViewController *actionSheet = [[JLActionSheetViewController alloc]init];
    [actionSheet showTeamInviteActionWithMessage:inviteString];
}

- (void)doneAction:(id)sender {
    [TBUtility currentAppDelegate].isChangeTeam = YES;
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeamKey object:self.currentTeam];
}

// Check the authorization status of our application for Address Book
-(void)checkAddressBookAccess {
    switch (ABAddressBookGetAuthorizationStatus()) {
        case  kABAuthorizationStatusAuthorized:
            [self getLocalContact];
            break;
        case  kABAuthorizationStatusNotDetermined :
            [self requestAddressBookAccess];
            break;
        case  kABAuthorizationStatusDenied:
        case  kABAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
}

// Prompt the user for access to their Address Book data
-(void)requestAddressBookAccess {
    AddMemberMethodsTableViewController * __weak weakSelf = self;
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error){
                                                 if (granted) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [weakSelf getLocalContact];
                                                     });
                                                 }
                                             });
}


- (void)getLocalContact {
    NSArray *contactsArray = [TBContact fetchTeamContactsWithTeamId:self.currentTeam.id ABAddressBookRef:self.addressBook];
    [self.localContactArray addObjectsFromArray:contactsArray];
}

- (void)sendMessage {
    //[[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",phone]]];
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = @[self.smsPhoneNumber];
    // Get current team data
    MOTeam *moTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID]];
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Invitation to %@ team. Visit %@ to download Talk app, and sign up or connect to your mobile number to join the team.", @"Invitation to %@ team. Visit %@ to download Talk app, and sign up or connect to your mobile number to join the team."),moTeam.name,moTeam.inviteURL];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)showSendMessageRemindView:(NSString *)phone {
    RemindView *remindView = (RemindView *)[[[NSBundle mainBundle] loadNibNamed:@"RemindView" owner:self options:nil] objectAtIndex:0];
    [remindView showWithTitle:NSLocalizedString(@"Invite to Talk", @"Invite to Talk") reminder:NSLocalizedString(@"You can invite TA to Jianliao", @"You can invite TA to Jianliao") rightButtonName:NSLocalizedString(@"Open", @"Open") color:[UIColor jl_redColor]];
    remindView.delegate = self;
    [self.navigationController.view addSubview:remindView];
    self.smsPhoneNumber = phone;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.searchResultController.tableView) {
        return self.searchData.count;
    }
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchResultController.tableView) {
        return 60;
    } else {
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.searchResultController.tableView) {
        TBContactCell *cell = [self.tableView dequeueReusableCellWithIdentifier:contactCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        TBContact *contact;
        contact = (self.searchData)[indexPath.row];
        [cell setupCellWithTBContact:contact];
        cell.contactInviteButton.indexPath = indexPath;
        [cell.contactInviteButton addTarget:self action:@selector(inviteContactByPhone:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    TBMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:inviteCellIdentifier];
    switch (indexPath.row) {
            
        case 0:
            cell.moreCellName.text = NSLocalizedString(@"Local Contacts", @"Local Contacts");
            [cell.moreCellImage setImage:[UIImage imageNamed:@"icon-contact"]];
            cell.divider.hidden = YES;
            break;
            
        case 1:
            cell.moreCellName.text = NSLocalizedString(@"QR Code", @"QR Code");
            [cell.moreCellImage setImage:[UIImage imageNamed:@"icon-qrcode"]];
            cell.divider.hidden = YES;
            break;
        case 2:
            cell.moreCellName.text = NSLocalizedString(@"Team invite", @"Team invite");
            [cell.moreCellImage setImage:[UIImage imageNamed:@"icon-team-invite"]];
            cell.divider.hidden = YES;
            break;
            
        default:
            break;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchResultController.tableView) {
        return;
    }
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"showPhoneContact" sender:self];
            break;
        case 1:{
            TeamQRCodeViewController *teamQRVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TeamQRCodeViewController"];
            teamQRVC.currentTeamId = _currentTeam.id;
            [self.navigationController pushViewController:teamQRVC animated:YES];
        }
            break;
        case 2:
            [self sendTeamInvite];
            break;
            
        default:
            break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self.searchData removeAllObjects];
    if(searchString.length > 0) {
        NSArray *terms = [searchString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableArray *subPredicates = [NSMutableArray array];
        for(NSString *term in terms) {
            if(term.length == 0) {
                continue;
            }
            NSPredicate *p1 = [NSPredicate predicateWithFormat:@"pinyin CONTAINS[cd] %@", term];
            NSPredicate *p2 = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", term];
            NSPredicate *p3 = [NSPredicate predicateWithFormat:@"phone CONTAINS[cd] %@", term];
            NSPredicate *p4 = [NSPredicate predicateWithFormat:@"email CONTAINS[cd] %@", term];
            NSPredicate *p = [NSCompoundPredicate orPredicateWithSubpredicates:@[p1, p2, p3, p4]];
            [subPredicates addObject:p];
        }
        NSPredicate *filter = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        self.searchData = [[self.localContactArray filteredArrayUsingPredicate:filter] mutableCopy];
    } else {
        self.searchData = nil;
    }
    
    [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self setIsSearching:YES];
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    [self setIsSearching:NO];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    BOOL isPhone = [TBUtility checkNumberString:searchBar.text];
    BOOL isEmail = [TBUtility checkEmail:searchBar.text];
    if (!isPhone && !isEmail) {
        [self.searchResultController.tableView reloadData];
        return;
    }
    
    NSDictionary *parameter;
    if (isPhone) {
        parameter = @{@"mobiles":@[searchBar.text]};
    } else {
        parameter = @{@"emails":@[searchBar.text]};
    }
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
    [[TBHTTPSessionManager sharedManager] GET:kGetUserInfoWithPhoneURLString parameters:parameter success:^(NSURLSessionDataTask *task, NSArray *responseObject){
        [SVProgressHUD dismiss];
        if (responseObject.count != 0) {
            TBUser *user = [MTLJSONAdapter modelOfClass:[TBUser class]
                                     fromJSONDictionary:responseObject[0]
                                                  error:NULL];
            TBContact *contact = [[TBContact alloc] init];
            contact.name = user.name;
            contact.pinyin = user.pinyin;
            if (isPhone) {
                NSString *finalPhone = user.phoneForLogin ? user.phoneForLogin : searchBar.text;
                contact.phone = finalPhone;
                contact.originPhone = finalPhone;
            } else {
                NSString *finalEmail = user.email ? user.email :searchBar.text;
                contact.email = finalEmail;
            }
            [self.searchData removeAllObjects];
            [self.searchData addObject:contact];
            [self.searchResultController.tableView reloadData];
        } else {
            TBContact *contact = [[TBContact alloc] init];
            contact.name = searchBar.text;
            if (isPhone) {
                contact.phone = searchBar.text;
                contact.originPhone = searchBar.text;
            } else {
                contact.email = searchBar.text;
            }
            [self.searchData removeAllObjects];
            [self.searchData addObject:contact];
            [self.searchResultController.tableView reloadData];
        }
        
    }failure:^(NSURLSessionDataTask *task, NSError *error){
        //failure
        NSString *errorCode = [TBUtility getApiErrorCodeWithError:error];
        if ([errorCode isEqualToString:@"400302"]) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Valid phonenumber", @"Valid phonenumber")];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        }
    }];
}

#pragma mark - message delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - RemindViewDelegate

- (void)clickFinishButtonInRemindView {
    [self inviteWithPhone:self.smsPhoneNumber hasAccount:NO];
    [self sendMessage];
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([segue.identifier isEqualToString:@"showPhoneContact"]) {
         PhoneContactViewController *phoneContactVC = segue.destinationViewController;
         phoneContactVC.currentTeamId = self.currentTeam.id;
         
     } else if ([segue.identifier isEqualToString:@"showQRcode"]) {
         TeamQRCodeViewController *qrCodeVC = segue.destinationViewController;
         qrCodeVC.currentTeamId = self.currentTeam.id;
     }
 }

@end
