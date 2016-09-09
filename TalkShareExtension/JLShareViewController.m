//
//  JLShareViewController.m
//  Talk
//
//  Created by 王卫 on 15/11/25.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "JLShareViewController.h"
#import "JLSharingTableViewController.h"
#import "JLSharePoster.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface JLShareViewController ()<JLShareExtensionDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeightConstraint;

@end

static const CGFloat kContainerFinalTopLeading = 100;

@implementation JLShareViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.containerTopConstraint.constant = CGRectGetHeight(self.view.frame);
    self.containerView.layer.cornerRadius = 5;
    self.containerView.clipsToBounds = YES;
    [JLSharePoster sharedPoster].delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.containerTopConstraint.constant = kContainerFinalTopLeading;
    [UIView animateWithDuration:0.25 delay:0 options:7<<16 animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowContainer"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        JLSharingTableViewController *viewController = (JLSharingTableViewController *)navigationController.topViewController;
        viewController.delegate = self;
    }
}

#pragma mark - JL share extension delegate

- (void)hideExtensionAfterCancel {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.containerTopConstraint.constant = CGRectGetHeight(self.view.frame);
        [UIView animateWithDuration:0.25 delay:0 options:7<<16 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"Extension" code:NSUserCancelledError userInfo:nil]];
        }];
    });
}

- (void)hideExtensionAfterPost {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.containerTopConstraint.constant = -CGRectGetHeight(self.containerView.frame)-30;
        [UIView animateWithDuration:0.25 delay:0 options:7<<16 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"Extension" code:NSUserCancelledError userInfo:nil]];
        }];
    });
}

- (void)updateContainerHeight:(CGFloat)height {
    self.containerHeightConstraint.constant = height;
    [UIView animateWithDuration:0.25 delay:0 options:7<<16 animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

@end



















