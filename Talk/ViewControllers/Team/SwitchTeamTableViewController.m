//
//  SwitchTeamTableViewController.m
//  Talk
//
//  Created by 王卫 on 16/1/14.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "SwitchTeamTableViewController.h"
#import "JLTeamHeaderView.h"
#import "MOTeam.h"
#import "TeamSettingViewController.h"
#import "TBTeamCell.h"
#import "TBUtility.h"
#import "NSString+Emoji.h"
#import "NewTeamViewController.h"
#import "SCViewController.h"
#import "SyncTeamsViewController.h"
#import "RootViewController.h"
#import <M13BadgeView.h>
#import <CoreData+MagicalRecord.h>
#import <Hanzi2Pinyin.h>
#import "NSString+TBUtilities.h"

@interface SwitchTeamTableViewController ()

@property (strong, nonatomic) JLTeamHeaderView *header;
@property (strong, nonatomic) UIView *fakeNavigationBar;
@property (strong, nonatomic) NSMutableArray *teamArray;
@property (assign, nonatomic) BOOL shouldNavigationBarHidden;

@end

static CGFloat const TableViewHeaderHeight = 200;
static CGFloat const DefaultSectionHeaderHeight = 20;
static CGFloat const DefaultSectionFooterHeight = 20;

@implementation SwitchTeamTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.shouldNavigationBarHidden = YES;
    
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([TBTeamCell class]) bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:NSStringFromClass([TBTeamCell class])];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.header = [[JLTeamHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), TableViewHeaderHeight)];
    self.tableView.tableHeaderView = self.header;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushSettingViewController)];
    [self.header.imageView addGestureRecognizer:tap];
    self.header.imageView.userInteractionEnabled = YES;
    
    [self.tableView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    self.header.titleLabel.text = self.currentTeam.name;
    NSString *imageName = [self.currentTeam.name getTalkTeamImageName];
    self.header.imageView.image = [UIImage imageNamed:imageName];

    self.teamArray = [MOTeam MR_findAllSortedBy:@"unread,updatedAt" ascending:NO].mutableCopy;
    for (MOTeam *tempTeam in self.teamArray) {
        if ([tempTeam.id isEqualToString:self.currentTeamID]) {
            [self.teamArray removeObject:tempTeam];
            [self.teamArray insertObject:tempTeam atIndex:0];
            break;
        }
    }
    
    [self setupNavbarButtons];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.tableView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        CGPoint offsetOld = [change[NSKeyValueChangeOldKey] CGPointValue];
        if (CGPointEqualToPoint(offset, offsetOld)) {
            return;
        }
        self.header.currentHeight = TableViewHeaderHeight - offset.y;
        if (offset.y > 0) {
            CGPoint titleCenter = [self.navigationController.view convertPoint:self.header.titleLabel.center fromView:self.header];
            if (titleCenter.y <= 42) {
                self.navigationItem.title = self.header.titleLabel.text;
                self.header.titleLabel.hidden = YES;
            } else {
                self.navigationItem.title = nil;
                self.header.titleLabel.hidden = NO;
            }
            CGRect backgroud = [self.navigationController.view convertRect:self.header.backgroudImageView.frame fromView:self.header];
            if (CGRectGetMaxY(backgroud) <= 64) {
                self.shouldNavigationBarHidden = NO;
                if (self.navigationController.navigationBarHidden) {
                    [self.navigationController setNavigationBarHidden:NO animated:NO];
                }
            } else {
                self.shouldNavigationBarHidden = YES;
                if (!self.navigationController.navigationBarHidden) {
                    [self.navigationController setNavigationBarHidden:YES animated:NO];
                }
            }
        }
    }
}

- (UIImage *)captureBackgroudImage {
    if (!self.header.backgroudImageView.image) {
        return nil;
    }
    CGRect rect = [self.header.backgroudImageView bounds];
    CGRect interestRect = CGRectMake(0, rect.size.height -64, rect.size.width, 64);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.header.backgroudImageView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageToSplitCG = image.CGImage;
    CGImageRef partOfImageCG = CGImageCreateWithImageInRect(imageToSplitCG, interestRect);
    UIImage *partOfImage = [UIImage imageWithCGImage:partOfImageCG];
    
    return partOfImage;
}

- (void)setupNavbarButtons {
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back") style:UIBarButtonItemStylePlain target:nil action:nil];
    
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.navigationController.navigationBar.frame) + 20);
    UIView *fakeNavigationBar = [[UIView alloc] initWithFrame:rect];
    
    CGRect leftButtonFrame = CGRectMake(6, 21, 40, 40);
    CGRect rightButtonFrame = CGRectMake(CGRectGetWidth(self.navigationController.navigationBar.frame) - 6- 40, 21, 40, 40);
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = leftButtonFrame;
    [leftButton setImage:[UIImage imageNamed:@"team-switch-close"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = rightButtonFrame;
    [rightButton setImage:[UIImage imageNamed:@"topic-setting"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(pushSettingViewController) forControlEvents:UIControlEventTouchUpInside];
    
    [fakeNavigationBar addSubview:leftButton];
    [fakeNavigationBar addSubview:rightButton];
    
    self.fakeNavigationBar = fakeNavigationBar;
    [self.navigationController.view addSubview:fakeNavigationBar];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"team-switch-close"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"topic-setting"] style:UIBarButtonItemStylePlain target:self action:@selector(pushSettingViewController)];
}

- (void)popViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pushSettingViewController {
    TeamSettingViewController *teamSettingViewController = [[UIStoryboard storyboardWithName:@"TeamSetting" bundle:nil] instantiateViewControllerWithIdentifier:@"TeamSettingViewController"];
    teamSettingViewController.currentTeam = self.currentTeam;
    [self.navigationController pushViewController:teamSettingViewController animated:YES];
}

#pragma mark --

- (void)viewWillAppear:(BOOL)animated {
    if (self.shouldNavigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [super viewWillAppear:animated];
    if (self.transitionCoordinator) {
        [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.fakeNavigationBar.alpha = 1;
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.fakeNavigationBar.alpha = 1;
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    if (self.transitionCoordinator) {
        [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.fakeNavigationBar.alpha = 0;
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.fakeNavigationBar.alpha = 0;
        }];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.header.imageForNavigationBar) {
        self.header.imageForNavigationBar = [self captureBackgroudImage];
    }
    [self.navigationController.navigationBar setBackgroundImage:self.header.imageForNavigationBar forBarMetrics:UIBarMetricsDefault];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tableView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
}


#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.teamArray.count;
        case 1:
            return 3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBTeamCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TBTeamCell class]) forIndexPath:indexPath];
    cell.InitialNameLabel.hidden = YES;
    cell.teambitionLogo.hidden = YES;
    cell.badgeButton.hidden = YES;
    cell.dotView.hidden = YES;
    if (indexPath.section == 0) {
        MOTeam *team = self.teamArray[indexPath.row];
        cell.nameLabel.text = team.name;
        
        if ([team.id isEqualToString:self.currentTeamID]) {
            cell.cellImageView.image = [UIImage imageNamed:@"icon-teamlogo-colorful"];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.tintColor = [UIColor jl_redColor];
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.cellImageView.image = [UIImage imageNamed:@"icon-teamlogo-gray"];
            if (team.unread.intValue > 0 ) {
                NSString *unreadNumber = [NSString stringWithFormat:@"%@",team.unread];
                [cell.badgeButton setTitle:unreadNumber forState:UIControlStateNormal];
                cell.badgeButton.hidden = NO;
                cell.badgeButton.enabled = NO;
            }
            else
            {
                if ([[TBUtility currentAppDelegate].allNewTeamIdArray containsObject:team.id] || team.hasUnreadValue) {
                    cell.dotView.hidden = NO;
                }
            }
        }
    } else {
        cell.InitialNameLabel.hidden = YES;
        cell.cellImageView.hidden = NO;
        cell.cellImageView.layer.borderWidth = 0;
        if (indexPath.row == 0) {
            cell.nameLabel.text = NSLocalizedString(@"Create a new team", nil);
            cell.cellImageView.image = [UIImage imageNamed:@"icon-team-add"];
        } else if (indexPath.row == 1) {
            cell.nameLabel.text = NSLocalizedString(@"Scan to join a team", nil);
            cell.cellImageView.image = [UIImage imageNamed:@"icon-scan"];
        } else {
            cell.nameLabel.text = NSLocalizedString(@"Sync from Teambition", nil);
            cell.cellImageView.image = [UIImage imageNamed:@"icon-sync"];
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), DefaultSectionHeaderHeight)];
    header.backgroundColor = [UIColor clearColor];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 1/[UIScreen mainScreen].scale)];
    line.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    [header addSubview:line];
    return header;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DefaultSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return DefaultSectionFooterHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        MOTeam *team = self.teamArray[indexPath.row];
        if ([team.id isEqualToString:self.currentTeamID]) {
            [self popViewController];
            return;
        } else {
            if ([[TBUtility currentAppDelegate].allNewTeamIdArray containsObject:team.id]) {
                [[TBUtility currentAppDelegate].allNewTeamIdArray removeObject:team.id];
            }
            [TBUtility currentAppDelegate].isChangeTeam = YES;
            [self popViewController];
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeamKey object:team];
        }
    } else {
        switch (indexPath.row) {
            case 0: {
                NewTeamViewController *newTeamViewController = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"NewTeamViewController"];
                newTeamViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:newTeamViewController animated:YES];
                break;
            }
            case 1: {
                [TBUtility sendAnalyticsEventWithCategory:kAnalyticsCategorySwitchTeams action:kAnalyticsActionScanTeam label:@"" value:nil];
                SCViewController *scViewController = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"SCViewController"];
                scViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:scViewController animated:YES];
                break;
            }
            case 2: {
                [TBUtility sendAnalyticsEventWithCategory:kAnalyticsCategorySwitchTeams action:kAnalyticsActionSyncTeam label:@"" value:nil];
                SyncTeamsViewController *syncVC = [[UIStoryboard storyboardWithName:kLoginStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"SyncTeamsViewController"];
                syncVC.hidesBottomBarWhenPushed = YES;
                syncVC.delegate = self.delegate;
                [self.navigationController pushViewController:syncVC animated:YES];
                break;
            }
        }
    }
}

@end
