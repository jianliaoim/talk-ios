//
//  JLActionSheetViewController.m
//  Talk
//
//  Created by Suric on 15/12/1.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "JLActionSheetViewController.h"
#import "DOPScrollableActionSheet.h"
#import "WXApi.h"
#import "SVProgressHUD.h"
#import "constants.h"
#import "TBUtility.h"

@interface JLActionSheetViewController ()
@end

@implementation JLActionSheetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showTeamInviteActionWithMessage:(NSString *)message {
    DOPAction *wechatSessionAction = [[DOPAction alloc] initWithName:NSLocalizedString(@"Wechat Session", @"Wechat Session") iconName:@"activity-wechat-session" handler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showWechatCopyAlertWithMessage:message];
        });
    }];
    DOPAction *wechatTimelineAction = [[DOPAction alloc] initWithName:NSLocalizedString(@"Wechat TimeLine", @"Wechat TimeLine") iconName:@"activity-wechat-timeline" handler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendReqToWechatTimelineWithMessage:message];
        });
    }];
    DOPAction *moreAction = [[DOPAction alloc] initWithName:NSLocalizedString(@"More", @"More") iconName:@"activity-more" handler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(AnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showMoreWithMessage:message];
        });
    }];
    NSArray *actions = @[@"",@[wechatSessionAction, wechatTimelineAction, moreAction]];
    DOPScrollableActionSheet *actionSheet = [[DOPScrollableActionSheet alloc] initWithActionArray:actions];
    [actionSheet show];
}

#pragma mark - Actions 

- (void)showWechatCopyAlertWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Copy inviteCode alert", @"Copy inviteCode alert") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Copy to Wechat", @"Copy to Wechat") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self sendReqToWechatSessionWithMessage:message];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:OKAction];
    [alertController addAction:cancelAction];
    if ([TBUtility currentAppDelegate].window.rootViewController.presentedViewController) {
        [[TBUtility currentAppDelegate].window.rootViewController.presentedViewController presentViewController:alertController animated:YES completion:nil];
    } else {
        [[TBUtility currentAppDelegate].window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
    alertController.view.tintColor = [UIColor jl_redColor];
}

- (void)sendReqToWechatSessionWithMessage:(NSString *)message {
    [[UIPasteboard generalPasteboard] setString:message];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTeamInviteIsCopyBySelf];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    BOOL success = [WXApi openWXApp];
    if (success) {
        DDLogDebug(@"success");
    } else {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Install Wechat", @"Install Wechat")];
    }
}

- (void)sendReqToWechatTimelineWithMessage:(NSString *)message {
    SendMessageToWXReq *inviteReq = [[SendMessageToWXReq alloc]init];
    inviteReq.text = message;
    inviteReq.bText = YES;
    inviteReq.scene = WXSceneTimeline;
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL success = [WXApi sendReq:inviteReq];
        if (success) {
            DDLogDebug(@"success");
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Install Wechat", @"Install Wechat")];
        }
    });
}

- (void)showMoreWithMessage:(NSString *)message {
    NSArray *items = [NSArray arrayWithObject:message];
    UIActivityViewController *activityController = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    if ([TBUtility currentAppDelegate].window.rootViewController.presentedViewController) {
        [[TBUtility currentAppDelegate].window.rootViewController.presentedViewController presentViewController:activityController animated:YES completion:nil];
    } else {
        [[TBUtility currentAppDelegate].window.rootViewController presentViewController:activityController animated:YES completion:nil];
    }
    activityController.view.tintColor = [UIColor blackColor];
}

@end
