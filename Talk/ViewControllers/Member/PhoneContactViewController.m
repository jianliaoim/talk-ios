//
//  PhoneContactViewController.m
//  Talk
//
//  Created by 史丹青 on 6/24/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "PhoneContactViewController.h"
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
#import "UIColor+TBColor.h"
#import "TBUtility.h"

@interface PhoneContactViewController ()
@property (weak, nonatomic) IBOutlet UITableView *contactTableView;
@property (strong, nonatomic) NSMutableArray *localContactArray;
@property (strong, nonatomic) NSMutableDictionary *contactSectionMemberDic;
@property (strong, nonatomic) NSMutableArray *contactSectionKeyArray;
@property (strong, nonatomic) NSMutableArray *searchData;
@property (assign, nonatomic) BOOL isSearching;
@property (assign, nonatomic) ABAddressBookRef addressBook;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableViewController *searchResultController;
@property (nonatomic, strong) TBContact *selectedContact;

@end

@implementation PhoneContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self commonInit];
    _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    [self checkAddressBookAccess];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Init

- (void)commonInit {
    
    self.title = NSLocalizedString(@"Local Contacts", @"Local Contacts");
    self.contactTableView.sectionIndexColor = [UIColor jl_redColor];
    
    self.localContactArray = [[NSMutableArray alloc] init];
    self.contactSectionMemberDic = [[NSMutableDictionary alloc] init];
    self.contactSectionKeyArray = [[NSMutableArray alloc] init];
    self.searchData = [[NSMutableArray alloc] init];
    
    self.contactTableView.sectionIndexBackgroundColor=[UIColor clearColor];
    self.contactTableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
    [self setIsSearching:NO];
    
    if (self.currentTeamId > 0) {
    } else {
        self.currentTeamId = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    }
}

- (UITableViewController *)searchResultController {
    if (!_searchResultController) {
        //Create searchResultController for UISearchController
        _searchResultController = [[UITableViewController alloc] init];
        _searchResultController.tableView.delegate = self;
        _searchResultController.tableView.dataSource = self;
        [_searchResultController.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
        _searchController.dimsBackgroundDuringPresentation = NO;
        _searchController.searchBar.placeholder = NSLocalizedString(@"Search Contact", @"Search Contact");
        _searchController.searchBar.backgroundImage = [UIImage imageNamed:@"icon-contact-search-background"];
        _searchController.searchBar.barTintColor = [UIColor whiteColor];
        _searchController.searchBar.tintColor = [UIColor jl_redColor];
    }
    return _searchController;
}

#pragma mark - IBAction

- (IBAction)inviteContactByPhone:(TBButton *)sender {
    TBContact *contact;
    if (self.isSearching) {
        contact = (self.searchData)[sender.indexPath.row];
    } else {
        contact = (self.contactSectionMemberDic)[(self.contactSectionKeyArray)[sender.indexPath.section]][sender.indexPath.row];
    }
    [self getUserInfo:contact];
}

#pragma mark - Private

- (void)getLocalContact {
    NSArray *contactsArray = [TBContact fetchTeamContactsWithTeamId:self.currentTeamId ABAddressBookRef:self.addressBook];
    [self.localContactArray addObjectsFromArray:contactsArray];
    [self.localContactArray sortUsingFunction:compareWithFirstCharacter context:NULL];
    for (TBContact *contact in self.localContactArray) {
        //contact in section
        NSString *string = [NSString getFirstWordWithEmojiForString:contact.pinyin];
        if (![self.contactSectionKeyArray containsObject:string]) {
            [self.contactSectionKeyArray addObject:string];
            [self.contactSectionMemberDic setObject:[NSMutableArray arrayWithObject:contact] forKey:string];
        }  else {
            NSMutableArray *newArray = [self.contactSectionMemberDic objectForKey:string];
            [newArray addObject:contact];
            [self.contactSectionMemberDic setObject:newArray forKey:string];
        }
    }
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
        case  kABAuthorizationStatusRestricted: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Privacy Warning", @"Privacy Warning")
                                                            message:NSLocalizedString(@"Permission was not granted for Contacts", @"Permission was not granted for Contacts")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

// Prompt the user for access to their Address Book data
-(void)requestAddressBookAccess {
    PhoneContactViewController * __weak weakSelf = self;
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error){
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf getLocalContact];
            });
        }
    });
}

NSInteger compareWithFirstCharacter(TBContact *contact1, TBContact *contact2, void *context) {
    return [contact1.pinyin localizedCompare:contact2.pinyin];
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
    [[TBHTTPSessionManager sharedManager] GET:kGetUserInfoWithPhoneURLString parameters:parameter success:^(NSURLSessionDataTask *task, NSDictionary *responseObject){
        if (responseObject.count != 0) {
            [self inviteWithContact:contact hasAccount:YES];
        } else {
            [self.searchController.searchBar resignFirstResponder];
            RemindView *remindView = (RemindView *)[[[NSBundle mainBundle] loadNibNamed:@"RemindView" owner:self options:nil] objectAtIndex:0];
            [remindView showWithTitle:NSLocalizedString(@"Invite to Talk", @"Invite to Talk") reminder:NSLocalizedString(@"You can invite TA to Jianliao", @"You can invite TA to Jianliao") rightButtonName:NSLocalizedString(@"Invite", @"Invite") color:[UIColor jl_redColor]];
            remindView.delegate = self;
            [self.navigationController.view addSubview:remindView];
            self.selectedContact = contact;
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

- (void)inviteWithContact:(TBContact *)contact hasAccount:(BOOL)hasJianLiaoAccount {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"please wait...", @"please wait...")];
    NSDictionary *parameter;
    if ([contact.phone length] > 0) {
        parameter = @{@"mobile":contact.phone};
    } else if ([contact.email length] > 0) {
        parameter = @{@"email":contact.email};
    }
    if (!parameter) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Invalid phone number or email ", nil)];
        return;
    }
    [[TBHTTPSessionManager sharedManager] POST:[NSString stringWithFormat:kTeamInviteURLString,[[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID]] parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject){
        //success
        if (hasJianLiaoAccount) {
            [[TBSocketManager sharedManager] teamJoinWith:responseObject];
            contact.isInTeam = YES;
        } else {
            [[TBSocketManager sharedManager] invitationCreatWith:responseObject];
            contact.isInvited = YES;
        }
        if (self.isSearching) {
            [self.searchResultController.tableView reloadData];
        } else {
            [self.contactTableView reloadData];
        }
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Invite success", @"Invite success")];
    }failure:^(NSURLSessionDataTask *task, NSError *error){
        //failure
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

#pragma mark - tableview datasource

- (BOOL)isSearchResultTableView:(UITableView *)tableView {
    return [tableView isEqual:self.searchResultController.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self isSearchResultTableView:tableView]) {
        return 1;
    } else {
        return self.contactSectionMemberDic.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.searchResultController.tableView]) {
        return self.searchData.count;
    } else {
        return [(self.contactSectionMemberDic)[(self.contactSectionKeyArray)[section]] count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.searchResultController.tableView]) {
        return nil;
    } else {
        return (self.contactSectionKeyArray)[(NSUInteger) section];
    }

}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.searchResultController.tableView]) {
        return nil;
    } else {
        return self.contactSectionKeyArray;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBContactCell *cell = [self.contactTableView dequeueReusableCellWithIdentifier:@"contactCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    TBContact *contact;
    if ([tableView isEqual:self.searchResultController.tableView]) {
        contact = (self.searchData)[indexPath.row];
    } else {
        contact = (self.contactSectionMemberDic)[(self.contactSectionKeyArray)[indexPath.section]][indexPath.row];
    }
    [cell setupCellWithTBContact:contact];
    cell.contactInviteButton.indexPath = indexPath;
    [cell.contactInviteButton addTarget:self action:@selector(inviteContactByPhone:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
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


#pragma mark = RemindViewDelegate

- (void)clickFinishButtonInRemindView {
    [self inviteWithContact:self.selectedContact hasAccount:NO];
}

@end
