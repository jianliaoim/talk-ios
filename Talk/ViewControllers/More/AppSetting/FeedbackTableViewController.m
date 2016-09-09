//
//  FeedbackTableViewController.m
//  Talk
//
//  Created by teambition-ios on 14/12/16.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "FeedbackTableViewController.h"
#import "SVProgressHUD.h"
#import "TBHTTPSessionManager.h"
#import "constants.h"
#import "MOUser.h"
#import "TBUtility.h"

#import <sys/types.h>
#import <sys/sysctl.h>
#import <sys/utsname.h>

@interface FeedbackTableViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@end

@implementation FeedbackTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"FeedBack", @"FeedBack");
    self.placeholderLabel.text = NSLocalizedString(@"please enter", @"please enter");
    if (self.isReport) {
        self.contentTextView.text = self.reportContentStr;
        if (self.reportContentStr.length == 0) {
            self.placeholderLabel.hidden = NO;
        } else {
            self.placeholderLabel.hidden = YES;
        }
    }
}
- (IBAction)done:(id)sender {
    if (self.contentTextView.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"please enter full infomation", @"please enter full infomation")];
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString *versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildNUmber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *buildNo = [NSString stringWithFormat:@"%@ (Build %@)",versionStr,buildNUmber];
    NSString *currentuserId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
    MOUser *currentUser = [MOUser findFirstWithId:currentuserId];
    NSString *userEmail = [TBUtility dealForNilWithString:currentUser.email];
    NSString *userMobile = [TBUtility dealForNilWithString:currentUser.mobile];
    NSString *allContentStr;
    if (self.isReport) {
        allContentStr = [NSString stringWithFormat:@"Content: %@\nMessageID: %@\nDevice: %@\nSystemVersion: %@\nBuildNO: %@\nUserId: %@\nEmail: %@\nPhone: %@",self.contentTextView.text,self.reportMessageID,deviceString,systemVersion,buildNo,currentuserId,userEmail,userMobile];
    } else {
        allContentStr = [NSString stringWithFormat:@"Content: %@\nDevice: %@\nSystemVersion: %@\nBuildNO: %@\nUserId: %@\nEmail: %@\nPhone: %@",self.contentTextView.text,deviceString,systemVersion,buildNo,currentuserId,userEmail, userMobile];
    }
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"iOS Feedback",@"title",
                            allContentStr,@"text",nil];
    NSString *feedbackAPIString = [kAPIBaseURLString stringByAppendingString:kFeedbackPath];
    [[TBHTTPSessionManager sharedManager]POST:feedbackAPIString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
       if (self.isReport) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Succeed Report", @"Succeed Report")];
       } else {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Succeed", @"Succeed")];
       }
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"%@",error);
         [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.placeholderLabel.hidden = NO;
    } else {
       self.placeholderLabel.hidden = YES;
    }
}

@end
