//
// Created by Shire on 10/16/14.
// Copyright (c) 2014 jiaoliao. All rights reserved.
//


#import "AddTeamMembersViewController.h"
#import "UIColor+TBColor.h"
#import "TBHTTPSessionManager.h"
#import <Hanzi2Pinyin/Hanzi2Pinyin.h>
#import <AddressBook/AddressBook.h>
#import "SVProgressHUD.h"
#import "constants.h"
#import "RootViewController.h"
#import "TBUtility.h"
#import "TBSocketManager.h"

#define kUI7NavigationBarHeight 0

@interface NSString(stripWhitespace)
@end

@implementation NSString(stripWhitespace)

- (NSString *)stripWhitespace {
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    NSArray *parts = [self componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    return [filteredArray componentsJoinedByString:@""];
};
@end

@implementation AddTeamMembersViewController {

    UIBarButtonItem *_refreshView;
    UIBarButtonItem *_loginButton;
    UIBarButtonItem *_cancelButton;
}

#pragma mark - init

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Contacts", @"Contacts");
        self.view.backgroundColor = [UIColor whiteColor];
    }

    return self;
}

#pragma mark - view cycle

- (void)loadView {
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = NSLocalizedString(@"Email", @"Email");

    APTokenField *tokenField = [[APTokenField alloc] init];
    tokenField.labelText = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Email", @"Email")];
    tokenField.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    tokenField.placeholder.text = NSLocalizedString(@"EMAIL_ADD_PLACEHOLDER", @"EMAIL_ADD_PLACEHOLDER");
    tokenField.tokenFieldDataSource = self;
    tokenField.tokenFieldDelegate = self;
    self.tokenField = tokenField;
    [self.view addSubview:tokenField];
    [tokenField becomeFirstResponder];

    _loginButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", @"Add") style:UIBarButtonItemStyleDone target:self action:@selector(submit:)];
    _cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed:)];
    [self enableSubmit:NO];
    self.navigationItem.rightBarButtonItem = _loginButton;
    //self.navigationItem.leftBarButtonItem = _cancelButton;

    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.frame = CGRectMake(0, 0, 40, 40);
    [activityView startAnimating];
    _refreshView = [[UIBarButtonItem alloc] initWithCustomView:activityView];
}

- (void)cancelPressed:(id)cancelPressed {
    [SVProgressHUD dismiss];
    [self.tokenField resignFirstResponder];
    if (self.creatingTeam) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (self.presentedViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    [self loadContacts];
    [self.tokenField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Contacts

-(BOOL)isABAddressBookCreateWithOptionsAvailable {
    return &ABAddressBookCreateWithOptions != NULL;
}

- (void)loadContacts {
    if (!self.contacts) {
        self.contacts = @[];
    }

    ABAddressBookRef addressBook;
    if ([self isABAddressBookCreateWithOptionsAvailable]) {
        CFErrorRef error = nil;
        addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // callback can occur in background, address book must be accessed on thread it was created on
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    // error
                } else if (!granted) {
                    // denied
                } else {
                    // access granted
                    [self AddressBookUpdated:addressBook info:NULL];
                    CFRelease(addressBook);
                    [self.tokenField.resultsTable reloadData];
                }
            });
        });
    }

}

- (void)AddressBookUpdated:(ABAddressBookRef)addressBook info:(CFDictionaryRef)info {
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);

    NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:(NSUInteger) nPeople];
    for (int i = 0; i < nPeople; i++) {
        // Get the next address book record.
        ABRecordRef record = CFArrayGetValueAtIndex(allPeople, i);

        // Get array of email addresses from address book record.
        ABMultiValueRef emailMultiValue = ABRecordCopyValue(record, kABPersonEmailProperty);
        NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonLastNameProperty);
        NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(record, kABPersonFirstNameProperty);
        NSString *lastNamePhonetic = lastName ? [Hanzi2Pinyin convert:lastName]: nil;
        NSString *firstNamePhonetic = firstName ? [Hanzi2Pinyin convert:firstName]: nil;
        NSString *pinyin1 = [[NSString stringWithFormat:@"%@%@", lastNamePhonetic, firstNamePhonetic] stripWhitespace];
        NSString *pinyin2 = [[NSString stringWithFormat:@"%@%@", firstNamePhonetic, lastNamePhonetic] stripWhitespace];

        NSArray *emailArray = (__bridge_transfer NSArray *) ABMultiValueCopyArrayOfAllValues(emailMultiValue);
        CFRelease(emailMultiValue);
        [emailArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *personDict = [NSMutableDictionary dictionary];
            [personDict setValue:lastName forKey:@"lastName"];
            [personDict setValue:firstName forKey:@"firstName"];
            [personDict setValue:pinyin1 forKey:@"pinyin1"];
            [personDict setValue:pinyin2 forKey:@"pinyin2"];
            [personDict setValue:obj forKey:@"email"];
            [contacts addObject:personDict];
        }];
    }
    _contacts = contacts;
    self.filteredContacts = _contacts;
}

#pragma mark - TokenField data source

- (NSString *)tokenField:(APTokenField *)tokenField titleForObject:(id)anObject {
    NSString *lastName = [anObject valueForKey:@"lastName"];
    NSString *firstName = [anObject valueForKey:@"firstName"];
    if (nil == lastName && nil == firstName) {
        return NSLocalizedString(@"Unknown", @"Unknown");
    } else if (nil == lastName) {
        return firstName;
    } else if (nil == firstName) {
        return lastName;
    }
    return [NSString stringWithFormat:@"%@ %@", [anObject valueForKey:@"lastName"], [anObject valueForKey:@"firstName"]];
}

- (NSUInteger)numberOfResultsInTokenField:(APTokenField *)tokenField {
    return self.filteredContacts.count;
}

- (id)tokenField:(APTokenField *)tokenField objectAtResultsIndex:(NSUInteger)index1 {
    return (self.filteredContacts)[index1];
}

- (void)tokenField:(APTokenField *)tokenField searchQuery:(NSString *)query {
    if (![[query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        NSArray *terms = [query componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSMutableArray *subPredicates = [NSMutableArray array];
        for(NSString *term in terms) {
            if([term length] == 0) { continue; }
            NSPredicate *p = [NSPredicate predicateWithFormat:@"email CONTAINS[cd] %@ || firstName CONTAINS[cd] %@ || lastName CONTAINS[cd] %@ || pinyin1 CONTAINS[cd] %@ || pinyin2 CONTAINS[cd] %@", term, term, term, term, term];
            [subPredicates addObject:p];
        }
        NSPredicate *filter = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:filter];
    } else {
        self.filteredContacts = self.contacts;
    }
}

- (UITableViewCell *)tokenField:(APTokenField *)tokenField tableView:(UITableView *)tableView cellForIndex:(NSUInteger)index1 {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.detailTextLabel.textColor = [UIColor tb_textGray];
    }
    NSDictionary *person = [self tokenField:tokenField objectAtResultsIndex:index1];
    cell.textLabel.text = [self tokenField:tokenField titleForObject:person];
    cell.detailTextLabel.text = [person valueForKey:@"email"];

    if ([[tokenField.tokens valueForKey:@"object"] indexOfObject:person] != NSNotFound) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.tintColor = [UIColor jl_redColor];
    
    return cell;
}

#pragma mark - TokenField delegate

- (void)tokenField:(APTokenField *)tokenField tableView:(UITableView *)tableView didSelectIndex:(NSUInteger)index {
    id object = [self tokenField:tokenField objectAtResultsIndex:index];
    if ([[tokenField.tokens valueForKey:@"object"] indexOfObject:object] == NSNotFound) {
        [tokenField addObject:object];
    } else {
        [tokenField removeObject:object];
    }
}

- (void)tokenFieldDidReturn:(APTokenField *)tokenField {
    NSString *query = [tokenField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([query isEqualToString:@""]) {
        [tokenField resetField];
    } else if (self.filteredContacts.count) {
        id object = (self.filteredContacts)[0];
        if ([[tokenField.tokens valueForKey:@"object"] indexOfObject:object] == NSNotFound) {
            [tokenField addObject:object];
        } else {
            [tokenField resetField];
        }
    } else {
        NSMutableDictionary *personDict = [NSMutableDictionary dictionary];
        [personDict setValue:query forKey:@"lastName"];
        [personDict setValue:query forKey:@"email"];
        [tokenField addObject:personDict];
    }
    [tokenField.resultsTable reloadData];
}

- (void)tokenField:(APTokenField *)tokenField didAddObject:(id)object {
    [self validateForm];
}


- (void)tokenField:(APTokenField *)tokenField didRemoveObject:(id)object {
    [self validateForm];
    [self.tokenField.resultsTable reloadData];
}


#pragma mark - Helper & selector

- (void)beginSigning {
    [self enableSubmit:NO];
    self.navigationItem.rightBarButtonItem = _refreshView;
}

- (void)endSigning {
    self.navigationItem.rightBarButtonItem = _loginButton;
    [self enableSubmit:YES];
}

- (IBAction)submit:(id)sender {
    NSArray *emailsAddressArray = (NSArray *)[[self.tokenField.tokens valueForKey:@"object"] valueForKey:@"email"];
    if (emailsAddressArray.count == 0) {
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];

    NSString *currentTeamID;
    if (self.creatingTeam)
    {
        currentTeamID = self.creatingTeam.id;
    } else
    {
        currentTeamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    }
    NSDictionary *paramsDic  =[NSDictionary dictionaryWithObjectsAndKeys:emailsAddressArray,@"emails",nil];
    [[TBHTTPSessionManager sharedManager]POST:[NSString stringWithFormat:@"%@/%@/%@",kTeamURLString,currentTeamID,kAddTopicMemberURLString] parameters:paramsDic success:^(NSURLSessionDataTask *task, id responseObject) {
        [self.tokenField resignFirstResponder];
        if (self.creatingTeam) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[RootViewController class]]) {
                [TBUtility currentAppDelegate].isChangeTeam = YES;
                [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeamKey object:self.creatingTeam];
            }
            else
            {
                [TBUtility currentAppDelegate].isChangeTeam = NO;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setValue:self.creatingTeam.id forKey:kCurrentTeamID];
                [defaults synchronize];
                
                NSUserDefaults *groupDeafaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
                [groupDeafaults setValue:self.creatingTeam.id forKey:kCurrentTeamID];
                [groupDeafaults synchronize];
                
                [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:^{}];
                [UIApplication sharedApplication].keyWindow.rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"RootViewController"];
                [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...") maskType:SVProgressHUDMaskTypeClear];
            }

        } else {
            if (self.presentingViewController) {
                [self dismissViewControllerAnimated:YES completion:^{
                    NSArray *newMemberArray = (NSArray *)responseObject;
                    [newMemberArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [[TBSocketManager sharedManager] teamJoinWith:obj];
                    }];
                }];
            } else {
                NSArray *newMemberArray = (NSArray *)responseObject;
                [newMemberArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [[TBSocketManager sharedManager] teamJoinWith:obj];
                }];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Done")];
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    [self resizeViewWithOptions:notification up:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self resizeViewWithOptions:notification up:NO];
}

- (void)resizeViewWithOptions:(NSNotification *)notification up:(BOOL)up {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardRect;

    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];


    float viewWidth = self.view.bounds.size.width;
    float viewHeight = self.view.bounds.size.height;

    // keyboard animation
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];

    CGFloat keyboardTop = up ? viewHeight - keyboardRect.size.height : viewHeight;
    CGRect tokenFrame = CGRectMake(0, 0, viewWidth, keyboardTop);
    tokenFrame.origin.y += kUI7NavigationBarHeight;
    self.tokenField.frame = tokenFrame;

    [UIView commitAnimations];
}

#pragma mark -Helper
- (void)validateForm {
    if (self.tokenField.objectCount) {
        [self enableSubmit:YES];
    } else {
        [self enableSubmit:NO];
    }
}

- (void)enableSubmit:(BOOL)enabled {
    [_loginButton setEnabled:enabled];
}

@end