//
//  AddTeamAfterScanQRCodeViewController.m
//  Talk
//
//  Created by 史丹青 on 6/11/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "JoinTeamAfterScanQRCodeViewController.h"
#import "UIColor+TBColor.h"
#import "TBUtility.h"
#import "NSString+Emoji.h"
#import "TBTeam.h"
#import "TBHTTPSessionManager.h"
#import "SVProgressHUD.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "RootViewController.h"

@interface JoinTeamAfterScanQRCodeViewController ()
@property (weak, nonatomic) IBOutlet UIView *teamLogoBacgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *teamLogoLabel;
@property (weak, nonatomic) IBOutlet UILabel *teamName;
@property (weak, nonatomic) IBOutlet UIButton *joinTeamButton;

@end

@implementation JoinTeamAfterScanQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DDLogDebug(self._id);
    [self.joinTeamButton setTitle:NSLocalizedString(@"Join team", @"Join team") forState:UIControlStateNormal];
    [self.teamLogoBacgroundImage setBackgroundColor:[UIColor jl_redColor]];
    [self.teamLogoLabel setText:[NSString getFirstWordWithEmojiForString:self.name]];
    [self.teamName setText:self.name];
    [self.joinTeamButton setBackgroundColor:[UIColor jl_redColor]];
    
    [self setCancelItem];
}

- (void)setCancelItem {
    if (self.isInvite) {
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
        self.navigationItem.rightBarButtonItem = cancelItem;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTranslucent:NO];
}

#pragma mark - IBAction

- (IBAction)joinTeam:(UIButton *)sender {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"please wait...", @"please wait...")];

    NSString *path;
    NSDictionary *param;
    if (self.isInvite) {
        path = KTeamJoinByInviteCodepath;
        param = @{@"inviteCode":self.inviteCode};
    } else {
        path = [NSString stringWithFormat:KTeamJoinBySignCodepath,self._id];
        param = @{@"signCode":self.signCode};
    }
    [[TBHTTPSessionManager sharedManager] POST:path parameters:param success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        [SVProgressHUD dismiss];
        TBTeam *team = [MTLJSONAdapter modelOfClass:[TBTeam class] fromJSONDictionary:responseObject error:NULL];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            MOTeam *moTeam  = [MTLManagedObjectAdapter managedObjectFromModel:team insertingIntoContext:localContext error:NULL];
            DDLogDebug(@"%@", moTeam);
        } completion:^(BOOL success, NSError *error) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[RootViewController class]]) {
                [TBUtility currentAppDelegate].isChangeTeam = YES;
                [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeamKey object:team];
            } else {
                [TBUtility currentAppDelegate].isChangeTeam = NO;
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setValue:team.id forKey:kCurrentTeamID];
                [defaults synchronize];
                NSUserDefaults *groupDeafaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
                [groupDeafaults setValue:team.id forKey:kCurrentTeamID];
                [groupDeafaults synchronize];
                
                [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:^{}];
                [UIApplication sharedApplication].keyWindow.rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"RootViewController"];
                [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...") maskType:SVProgressHUDMaskTypeClear];
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [TBUtility showMessageInError:error];
    }];
}

#pragma mark - Private Methods

- (void)cancelAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
