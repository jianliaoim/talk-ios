//
//  JLShareTeamController.m
//  Talk
//
//  Created by teambition-ios on 15/4/14.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "JLShareTeamController.h"
#import "JLShareSendController.h"
#import "JLShareSessionManager.h"

static NSString * const cellIdentifier = @"TBShareTeamCell";

@interface JLShareTeamController ()<JLShareSendControllerDelgate>

@end

@implementation JLShareTeamController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Choose Team", @"Choose Team");
    CGFloat maxHeight = [[UIScreen mainScreen] bounds].size.height - 200;
    NSInteger minRow = MAX(self.allTeamArray.count, 5);
    CGFloat height = minRow * 44 + CGRectGetHeight(self.navigationController.navigationBar.frame);
    self.preferredContentSize = CGSizeMake(self.view.frame.size.width, height > maxHeight ? maxHeight : height);
    if ([self.uiDelegate respondsToSelector:@selector(updateContainerHeight:)]) {
        [self.uiDelegate updateContainerHeight:self.preferredContentSize.height];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allTeamArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *teamInfo = [self.allTeamArray objectAtIndex:indexPath.row];
    cell.textLabel.text = teamInfo[@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(didSelectTeamWith:)]) {
        [_delegate didSelectTeamWith:[self.allTeamArray objectAtIndex:indexPath.row]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
