//
//  ContactTableViewController.m
//  Talk
//
//  Created by 王卫 on 15/11/4.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "ContactTableViewController.h"
#import "JLContactTableViewCell.h"
#import "constants.h"
#import "MOUser.h"
#import "NSString+Emoji.h"
#import "TBUtility.h"
#import "ContactDataSource.h"
#import "GroupTableViewDataSource.h"
#import "MemberGroupDataSource.h"
#import "NewTopicViewController.h"
#import "ArchivedTopicViewController.h"
#import "TopicSettingController.h"
#import "GroupSettingViewController.h"
#import <UIImageView+WebCache.h>
#import <CoreData+MagicalRecord.h>

@interface ContactTableViewController ()<UISearchBarDelegate, UISearchControllerDelegate, NewTopicViewControllerDelegate, GroupSettingDelegate>

@property (strong, nonatomic) NSDictionary *allMemberDictionary;
@property (strong, nonatomic) NSArray *allMemberArray;
@property (strong, nonatomic) NSArray *sectionIdentifierArray;
@property (strong, nonatomic) NSArray *adminMembersArray;

@property (strong, nonatomic) id<UITableViewDataSource, UISearchResultsUpdating, CommonTableViewDataSourceProtocol> contactDataSource;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) UITableViewController *searchResultController;
@property (strong, nonatomic) NSMutableArray *searchResults;

@end

static NSString *const kCellIdentifier = @"JLContactTableViewCell";

@implementation ContactTableViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JLContactTableViewCell class]) bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    self.tableView.dataSource = self.contactDataSource;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexColor = [UIColor jl_redColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    if (!self.isCancelButtonNeedHide) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPress:)];
    }
    BOOL isManager = [TBUtility isManagerForCurrentAccount];
    BOOL isTypeValid = self.contactType == TBContactTypeTopic || (self.contactType == TBContactTypeMemberGroup && isManager);
    if (isTypeValid && !self.isChoosing) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    }
    switch (self.contactType) {
        case TBContactTypeMember:
            self.navigationItem.title = NSLocalizedString(@"Private Chat", @"Private Chat");
            break;
        case TBContactTypeTopic:
            self.navigationItem.title = NSLocalizedString(@"Topics", @"Topics");
            break;
        case TBContactTypeMemberGroup:
            self.navigationItem.title = NSLocalizedString(@"Member Groups", @"Member Groups");
            [self showTip];
            break;
    }
    self.definesPresentationContext = YES;
    self.extendedLayoutIncludesOpaqueBars = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(successCreateTopic:)
                                                 name:kSocketRoomCreateBySelf
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:kResumeRoomSucceedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (void)showTip {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kHasShowGroupTip]) {
        return;
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasShowGroupTip];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    UIWindow *topWindow = [TBUtility applicationTopView];
    CGRect frame = [self.view convertRect:self.navigationController.navigationBar.frame toView:topWindow];
    CGRect finalFrame = CGRectOffset(frame, 0, -20);
    AMPopTip *poptip = [[TBUtility currentAppDelegate] getPopTipWithContainerView:topWindow];
    [poptip showText:NSLocalizedString(@"Group tip", nil) direction:AMPopTipDirectionDown maxWidth:200 inView:topWindow fromFrame:finalFrame];
}

- (void)addButtonPressed:(id)sender {
    UINavigationController *temNav = (UINavigationController *)[[UIStoryboard storyboardWithName:kNewTopicStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"showAddNewTopicNav"];
    [temNav setTransitioningDelegate:[TBUtility currentAppDelegate].presentTransition];
    NewTopicViewController *newTopicVC = [temNav.viewControllers objectAtIndex:0];
    newTopicVC.delegate = self;
    if (self.contactType == TBContactTypeMemberGroup) {
        newTopicVC.isMemberGroup = YES;
    }
    [self presentViewController:temNav animated:YES completion:^{}];
}

- (void)cancelButtonPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - New Topic delegate

- (void)successCreateTopic:(NSNotification *)aNotification {
    [self dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kShareForTopic object:aNotification.object];
    }];
}

- (void)successCreateRoom:(MORoom *)room {
    [self dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kShareForMember object:room];
    }];
}

- (void)didCreateMemberGroup:(MOGroup *)group {
    [self reloadTableView];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfRowsInSection = [self.contactDataSource tableView:tableView numberOfRowsInSection:indexPath.section];
    CGFloat height = JLContactCellDefaultHeight;
    if (numberOfRowsInSection == 1) {
        height += JLContactCellDefaultOffset*2;
    } else if (indexPath.row == 0 || indexPath.row == numberOfRowsInSection -1) {
        height += JLContactCellDefaultOffset;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.textColor = [UIColor tb_tableHeaderGrayColor];
    headerView.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    CGRect frame = headerView.frame;
    headerView.textLabel.frame = frame;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isChoosing) {
        if ([self.delegate respondsToSelector:@selector(didChooseItem:)]) {
            [self.delegate didChooseItem:[self.contactDataSource objectAtIndexPath:indexPath]];
        }
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (self.contactType == TBContactTypeMemberGroup) {
        MOGroup *selectedGroup = [self.contactDataSource objectAtIndexPath:indexPath];
        if (!selectedGroup) {
            return;
        }
        GroupSettingViewController *groupSetting = [[GroupSettingViewController alloc] initWithGroup:selectedGroup];
        groupSetting.delegate = self;
        [self.navigationController pushViewController:groupSetting animated:YES];
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableView && self.contactType == TBContactTypeTopic && indexPath.section == 2) {
        ArchivedTopicViewController *archivedTopicViewController = [ArchivedTopicViewController new];
        [self.navigationController pushViewController:archivedTopicViewController animated:YES];
        return;
    }
    id selected = [self.contactDataSource objectAtIndexPath:indexPath];
    if (!selected) {
        return;
    }
    self.searchController.active = NO;
    [self dismissViewControllerAnimated:NO completion:^{
        NSString *notificationName;
        if (self.contactType == TBContactTypeMember) {
            notificationName = kShareForMember;
        } else {
            notificationName = kShareForTopic;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:selected];
    }];
}

#pragma mark - Search delegate

- (void)didPresentSearchController:(UISearchController *)searchController {
    self.contactDataSource.delegate = self;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    self.contactDataSource.isSearching = NO;
    [self.tableView reloadData];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

#pragma mark - Contact data source search delegate

- (void)didUpdateSearchResults {
    [self.searchResultController.tableView reloadData];
}

#pragma mark - Group setting delegate

- (void)didUpdateGroupSetting:(MOGroup *)group {
    [self.contactDataSource refreshData];
    [self.tableView reloadData];
}

#pragma mark - Reload data

- (void)reloadTableView {
    [self.contactDataSource refreshData];
    [self.tableView reloadData];
}

#pragma mark - Getter

- (id<UITableViewDataSource, UISearchResultsUpdating>)contactDataSource {
    if (!_contactDataSource) {
        if (self.contactType == TBContactTypeMember) {
            _contactDataSource = [[ContactDataSource alloc] init];
            ((ContactDataSource *)_contactDataSource).delegate = self;
        } else if (self.contactType == TBContactTypeTopic) {
            _contactDataSource = [[GroupTableViewDataSource alloc] init];
            ((GroupTableViewDataSource *)_contactDataSource).delegate = self;
        } else if (self.contactType == TBContactTypeMemberGroup) {
            _contactDataSource = [[MemberGroupDataSource alloc] init];
            ((MemberGroupDataSource *)_contactDataSource).delegate = self;
        }
    }
    return _contactDataSource;
}

#pragma mark - Search

- (UITableViewController *)searchResultController {
    if (!_searchResultController) {
        _searchResultController = [[UITableViewController alloc] init];
        _searchResultController.tableView.delegate = self;
        _searchResultController.tableView.dataSource = self.contactDataSource;
        _searchResultController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchResultController.tableView.tableFooterView = [[UIView alloc] init];
        [_searchResultController.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JLContactTableViewCell class]) bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    }
    return _searchResultController;
}

- (UISearchController *)searchController {
    if (!_searchResultController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultController];
        _searchController.searchResultsUpdater = self.contactDataSource;
        _searchController.delegate = self;
        _searchController.searchBar.delegate = self;
        
        //Customize
        _searchController.dimsBackgroundDuringPresentation = NO;
        if (self.contactType == TBContactTypeMember) {
            _searchController.searchBar.placeholder = NSLocalizedString(@"Search Contact", @"Search Contact");
        }
        _searchController.searchBar.barTintColor = [UIColor tb_shareToSearchBarcolor];
        _searchController.searchBar.layer.borderWidth = 1.0;
        _searchController.searchBar.layer.borderColor = [UIColor tb_searchBarColor].CGColor;
        _searchController.searchBar.tintColor = [UIColor jl_redColor];
    }
    return _searchController;
}


@end












