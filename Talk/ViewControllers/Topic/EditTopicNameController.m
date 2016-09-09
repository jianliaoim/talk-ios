//
//  EditTopicNameController.m
//  Talk
//
//  Created by teambition-ios on 14/10/15.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "EditTopicNameController.h"
#import "constants.h"
#import "SVProgressHUD.h"
#import "TBHTTPSessionManager.h"
#import "TBUtility.h"
#import <CoreData+MagicalRecord.h>

#import "MOUser.h"
#import "MORoom.h"
#import "MOGroup.h"
#import "MONotification.h"

@interface EditTopicNameController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UITextView *nameTextView;
@end

static CGFloat textViewMargin = 0;

@implementation EditTopicNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.cancelItem.title = NSLocalizedString(@"Cancel", @"Cancel");
    self.saveItem.title = NSLocalizedString(@"Save", @"Save");
    self.nameTextView.text = self.nameStr;
    self.nameTextView.delegate = self;
    if (!self.isEditingTopicName && !self.isEditingGroupName) {
        if (!self.nameStr) {
            self.placeholderLabel.text = NSLocalizedString(@"No target", @"No target");
            self.placeholderLabel.hidden = NO;
        }
    }
   
    NSString *currentUserID   = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentUserKey];
    NSString *currentRoomCreatorID = [TBUtility currentAppDelegate].currentRoom.creatorID;
    MOUser *currentMOMembe = [MOUser findFirstWithId:currentUserID];
    if ([currentMOMembe.role isEqualToString:@"owner"] || [currentMOMembe.role isEqualToString:@"admin"] ||[currentRoomCreatorID isEqualToString:currentUserID]) {
        self.nameTextView.editable = YES;
    } else {
        self.nameTextView.editable = NO;
        self.navigationItem.rightBarButtonItem = nil;
    }
    if ([TBUtility currentAppDelegate].currentRoom.isGeneral.boolValue && self.isEditingTopicName) {
        self.nameTextView.editable = NO;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    if (self.nameTextView.userInteractionEnabled) {
        [self.nameTextView becomeFirstResponder];
    }
}

- (IBAction)cancelDone:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveDone:(id)sender
{
    [self.nameTextView resignFirstResponder];
    
    if (self.isEditingTopicName) {
        if (self.nameTextView.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Invalid group name", @"Invalid group name")];
            return;
        }
        
        NSPredicate *roomPredicate = [NSPredicate predicateWithFormat:@"topic = %@", self.nameTextView.text];
        MORoom *existRoom = [MORoom MR_findFirstWithPredicate:roomPredicate];
        if (existRoom) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"group name exists", @"group name exists")];
            [self.nameTextView becomeFirstResponder];
            return;
        }
    } else if (self.isEditingGroupName) {
        if (self.nameTextView.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Invalid group name", @"Invalid group name")];
            return;
        }
        NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"name = %@", self.nameTextView.text];
        MOGroup *exsitGroup = [MOGroup MR_findFirstWithPredicate:groupPredicate];
        if (exsitGroup) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"group name exists", @"group name exists")];
            [self.nameTextView becomeFirstResponder];
            return;
        }
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        [[TBHTTPSessionManager sharedManager] PUT:[NSString stringWithFormat:kUpdateGroupURLString, self.group.id] parameters:@{@"name":self.nameTextView.text} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                MOGroup *localGroup = [self.group MR_inContext:localContext];
                localGroup.name = responseObject[@"name"];
            } completion:^(BOOL success, NSError *error) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Done")];
                [[NSNotificationCenter defaultCenter] postNotificationName:kEditMemberGroupInfoNotification object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
        }];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    NSDictionary *params;
    if (self.isEditingTopicName) {
        params = [NSDictionary dictionaryWithObjectsAndKeys:self.nameTextView.text,@"topic",nil];
    } else {
        params = [NSDictionary dictionaryWithObjectsAndKeys:self.nameTextView.text,@"purpose",nil];
    }
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
        NSPredicate *predacate = [TBUtility roomPredicateForCurrentTeamWithRoomId:[TBUtility currentAppDelegate].currentRoom.id];
        MORoom *currentRoom  = [MORoom MR_findFirstWithPredicate:predacate inContext:localContext];
        MONotification *relatedNotification = [MONotification MR_findFirstByAttribute:@"targetID" withValue:currentRoom.id inContext:localContext];
        if (self.isEditingTopicName) {
            currentRoom.topic = [responseDic objectForKey:@"topic"];
            if ([relatedNotification.type isEqualToString:kNotificationTypeRoom]) {
                NSMutableDictionary *target = [relatedNotification.target mutableCopy];
                target[@"topic"] = [responseDic objectForKey:@"topic"];
                relatedNotification.target = target.copy;
            }
        } else {
            currentRoom.purpose = [responseDic objectForKey:@"purpose"];
            if ([relatedNotification.type isEqualToString:kNotificationTypeRoom]) {
                NSMutableDictionary *target = [relatedNotification.target mutableCopy];
                target[@"purpose"] = [responseDic objectForKey:@"purpose"];
                relatedNotification.target = target.copy;
            }
        }
    } completion:^(BOOL success, NSError *error) {
        if (self.isEditingTopicName) {
            [TBUtility currentAppDelegate].currentRoom.topic = [responseDic objectForKey:@"topic"];
        } else {
            [TBUtility currentAppDelegate].currentRoom.purpose = [responseDic objectForKey:@"purpose"];
        }
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Done")];
        [[NSNotificationCenter defaultCenter] postNotificationName:kEditTopicInfoNotification object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.placeholderLabel.hidden = (textView.text.length > 0);
    [self.tableView beginUpdates];
    [self.tableView reloadData];
    [self.tableView beginUpdates];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = [self getCellHeightWith:self.nameTextView.text];
    return MAX(36, cellHeight);
}

- (CGFloat)getCellHeightWith:(NSString *)text {
    CGFloat contentViewWidth = [[UIScreen mainScreen] bounds].size.width - 2 * textViewMargin;
    CGSize tempsize = CGSizeMake(contentViewWidth,CGFLOAT_MAX);
    UITextView *temLabel = [[UITextView alloc]initWithFrame:CGRectZero];
    temLabel.font = [UIFont systemFontOfSize:16.0];
    temLabel.text = text;
    CGSize size = [temLabel sizeThatFits:tempsize];
    return ceil(size.height);
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
