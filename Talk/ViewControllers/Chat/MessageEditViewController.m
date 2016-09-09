//
//  MessageEditViewController.m
//  Talk
//
//  Created by teambition-ios on 15/1/13.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "MessageEditViewController.h"
#import "SVProgressHUD.h"

@interface MessageEditViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *editNavigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *titleNavigationItem;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@end

@implementation MessageEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleNavigationItem.title = NSLocalizedString(@"Edit Message", @"Edit Message");
    self.view.layer.masksToBounds = YES;
    self.view.layer.cornerRadius = 8.f;
    self.saveBtn.layer.masksToBounds = YES;
    self.saveBtn.layer.cornerRadius = 5.f;

    self.editNavigationBar.barTintColor = [UIColor whiteColor];
    [self.editNavigationBar setTintColor:self.tintColor];
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    [self.editNavigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    self.saveBtn.backgroundColor = self.tintColor;
    
    self.messageTextView.text = self.editMessage.messageStr;
    [self.saveBtn setTitle:NSLocalizedString(@"Save", @"Save") forState:UIControlStateNormal];
    [self.saveBtn setEnabled:NO];
    self.saveBtn.alpha = 0.5;
}
- (IBAction)editCancel:(id)sender {
    [self.messageTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:NULL];
    if ([_delegate respondsToSelector:@selector(messageEditCancel)]) {
        [_delegate messageEditCancel];
    }
}

- (IBAction)editSave:(id)sender {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Edit...", @"Edit...")];
    
    [self.messageTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:NULL];
    if ([_delegate respondsToSelector:@selector(messageEditSaveWith:andOriginMessage:)]) {
        [_delegate messageEditSaveWith:self.messageTextView.text andOriginMessage:self.editMessage];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:self.editMessage.messageStr]) {
        [self.saveBtn setEnabled:NO];
        self.saveBtn.alpha = 0.5;
    } else {
       [self.saveBtn setEnabled:YES];
        self.saveBtn.alpha = 1.0;
    }
}

@end
