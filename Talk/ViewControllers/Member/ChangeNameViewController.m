//
//  ChangeNameViewController.m
//  Talk
//
//  Created by Shire on 9/29/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import "ChangeNameViewController.h"
#import "TBHTTPSessionManager.h"
#import "constants.h"
#import "SVProgressHUD.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>

#import "MOTeam.h"
#import "MOUser.h"
#import "TBUser.h"
#import "TBUtility.h"
#import "TBSocketManager.h"
#import "NSString+TBUtilities.h"

@interface ChangeNameViewController ()<UITextFieldDelegate>

@property (copy, nonatomic) NSString *userID;
@property (weak, nonatomic) IBOutlet UITextField *nameField;

- (IBAction)nameChanged:(UITextField *)sender;
- (IBAction)donePressed:(UIBarButtonItem *)sender;

@end

@implementation ChangeNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

-(void)viewDidAppear:(BOOL)animated
{
   dispatch_async(dispatch_get_main_queue(), ^{
       [self.nameField becomeFirstResponder];

   });
   
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helper

- (void)commonInit {
    self.nameField.placeholder = self.title;
    self.nameField.text = self.name;
    self.nameField.delegate = self;
    self.nameField.enablesReturnKeyAutomatically = YES;
    self.nameField.returnKeyType = UIReturnKeyDone;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.userID = [defaults valueForKey:kCurrentUserKey];
}

#pragma mark - Text view delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameField) {
        [self.nameField resignFirstResponder];
        return NO;
    }
    return YES;
}


#pragma mark - Selector

- (IBAction)nameChanged:(UITextField *)sender {
    self.navigationItem.rightBarButtonItem.enabled = ![self.nameField.text isEqualToString:self.name];
}

- (IBAction)donePressed:(UIBarButtonItem *)sender {
    NSString *newName = self.nameField.text;
    if (newName.length == 0 && !self.isEditAlias && !self.isEditEmail) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Can not be nil", @"Can not be nil")];
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *keyValue;
    if (self.isEditEmail) {
        keyValue = @"email";
    } else {
        keyValue = @"name";
        [SVProgressHUD showWithStatus:NSLocalizedString(@"please wait...", @"please wait...")];
    }
    [parameters setValue:newName forKey:keyValue];
    if (self.isEditTag) {
        NSMutableDictionary *paramForTag = [NSMutableDictionary dictionaryWithObjectsAndKeys:newName, @"name", nil];
        TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
        [manager PUT:[NSString stringWithFormat:@"%@/%@",kTagsURLString,self.tagId]  parameters:paramForTag success:^(NSURLSessionDataTask *task, NSArray *responseObject) {
            DDLogDebug(@"%@", responseObject);
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Done")];
            [[NSNotificationCenter defaultCenter] postNotificationName:kEditTagSuccessNotification object:Nil];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DDLogDebug(@"%@", error.localizedDescription);
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];
    } else if (self.isEditTeamName) {
        TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
        [manager PUT:[NSString stringWithFormat:@"%@/%@",kTeamURLString,[[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID]]
          parameters:parameters
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 [self processTeamData:responseObject];
             }
             failure:^(NSURLSessionDataTask *task, NSError *error) {
                 DDLogError(@"error: %@", error.localizedRecoverySuggestion);
                 [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
             }];
    }
    else if (self.isEditAlias) {
        NSDictionary *params = @{@"prefs": @{@"alias":newName}};
        TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
        [manager PUT:[NSString stringWithFormat:@"%@/%@",kTeamURLString,[[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID]]
          parameters:params
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 [SVProgressHUD dismiss];
                 NSString *newAlias = [[responseObject objectForKey:@"prefs"] objectForKey:@"alias"];
                 [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                     NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
                     MOUser *user = [MOUser findFirstWithId:userID inContext:localContext];
                     user.alias = newAlias;
                 } completion:^(BOOL success, NSError *error) {
                     [[NSNotificationCenter defaultCenter] postNotificationName:kPersonalInfoChangeNotification object:newName];
                     [self.navigationController popViewControllerAnimated:YES];
                 }];
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 DDLogError(@"error: %@", error.localizedRecoverySuggestion);
                 [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
             }];
    } else if (self.isEditEmail) {
        if ([newName isQQEmail]) {
            [self remindQQEmailWithParams:parameters newName:newName];
        } else {
            [self updateNameWithParams:parameters newName:newName];
        }
    } else {
        [self updateNameWithParams:parameters newName:newName];
    }
}

- (void)remindQQEmailWithParams:(NSDictionary *)parameters newName:(NSString *)newName {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"QQ Email Remind", @"QQ Email Remind") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *backAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Back and Edit", @"Back and Edit") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD dismiss];
        [self.nameField becomeFirstResponder];
    }];
    [alertController addAction:backAction];
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", @"Continue") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self updateNameWithParams:parameters newName:newName];
    }];
    [alertController addAction:continueAction];
    [self presentViewController:alertController animated:YES completion:nil];
    alertController.view.tintColor = [UIColor jl_redColor];
}

- (void)updateNameWithParams:(NSDictionary *)parameters newName:(NSString *)newName {
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager PUT:[NSString stringWithFormat:@"users/%@", self.userID]
      parameters:parameters
         success:^(NSURLSessionDataTask *task, id responseObject) {
             DDLogVerbose(@"Successfully updated name");
             [[TBSocketManager sharedManager] userUpdateWith:responseObject completion:^(BOOL success, NSError *error) {
                 [SVProgressHUD dismiss];
                 [[NSNotificationCenter defaultCenter] postNotificationName:kPersonalInfoChangeNotification object:newName];
                 [self.navigationController popViewControllerAnimated:YES];
             }];
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
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
            currentTeam.name = [responseDic objectForKey:@"name"];
    } completion:^(BOOL success, NSError *error) {
        if (success) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Done")];
            [[NSNotificationCenter defaultCenter] postNotificationName:kEditTeamNameNotification object:[responseDic objectForKey:@"name"]];
            [self.navigationController popViewControllerAnimated:YES];
        }
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
