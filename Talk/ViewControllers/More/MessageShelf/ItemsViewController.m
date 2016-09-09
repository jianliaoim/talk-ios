//
//  ItemsViewController.m
//  Talk
//
//  Created by 史丹青 on 15/5/4.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "ItemsViewController.h"
#import "SCNavTabBarController.h"
#import "FilesTableViewController.h"
#import "LinksTableViewController.h"
#import "PostsTableViewController.h"
#import "SnippetsTableViewController.h"
#import "SheetsTableViewController.h"

#import "TBHTTPSessionManager.h"
#import "SVProgressHUD.h"
#import "constants.h"
#import "TBMessage.h"
#import "MTLJSONAdapter.h"
#import "constants.h"
#import "TBShareToCell.h"
#import "TBFilterAllCell.h"

#import "MORoom.h"
#import "MOUser.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "Hanzi2Pinyin.h"
#import "TBUtility.h"

#import "TalkGuideView.h"
#import "GuideHelper.h"

static NSString *const allCellIdentifier = @"TBFilterAllCell";
static NSString *const shareToCellIdentifier = @"TBShareToCell";
static CGFloat const filterViewLeftMargin = 55.0f;

@interface ItemsViewController ()<UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UILabel *filterTitlelabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (strong, nonatomic) FilesTableViewController *filesVC;
@property (strong, nonatomic) LinksTableViewController *linksVC;
@property (strong, nonatomic) PostsTableViewController *postsVC;
@property (strong, nonatomic) SnippetsTableViewController *snippetsVC;
@property (strong, nonatomic) SheetsTableViewController *sheetsVC;

@property (strong, nonatomic) NSMutableDictionary *searchResultDictionary;
@property (strong, nonatomic) NSMutableArray *roomsArray;
@property (strong, nonatomic) NSMutableArray *membersArray;
@property (strong, nonatomic) NSString *currentSearchString;
@property (nonatomic) BOOL isShowFilter;

@end

@implementation ItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //title
    self.titleLabel.text = NSLocalizedString(@"Items", @"Items");
    if (self.filterDictionary.allKeys.count == 0) {
        self.filterNameLabel.text = NSLocalizedString(@"All", @"All");
    }
    //filter Item
    UIBarButtonItem *filterItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon-filter"] style:UIBarButtonItemStylePlain target:self action:@selector(filterAction:)];
    self.navigationItem.rightBarButtonItem = filterItem;
    //search Bar
    self.searchBar.placeholder = NSLocalizedString(@"Topics or conversations", @"Topics or conversations");
    
    _filesVC = [[FilesTableViewController alloc] init];
    _filesVC.title = NSLocalizedString(@"Files", @"Files");
    _filesVC.filterDictionary = self.filterDictionary;
    
    _linksVC = [[LinksTableViewController alloc] init];
    _linksVC.title = NSLocalizedString(@"Links", @"Links");
    _linksVC.filterDictionary = self.filterDictionary;

    _postsVC = [[PostsTableViewController alloc] init];
    _postsVC.title = NSLocalizedString(@"Posts", @"Posts");
    _postsVC.filterDictionary = self.filterDictionary;
    
    _snippetsVC = [[SnippetsTableViewController alloc] init];
    _snippetsVC.title = NSLocalizedString(@"Code", @"Code");
    _snippetsVC.filterDictionary = self.filterDictionary;
    
    _sheetsVC = [[SheetsTableViewController alloc] init];
    _sheetsVC.title = NSLocalizedString(@"Sheets", @"Sheets");
    _sheetsVC.filterDictionary = self.filterDictionary;
    
    SCNavTabBarController *navTabBarController = [[SCNavTabBarController alloc] init];
    navTabBarController.subViewControllers = @[_filesVC, _linksVC, _postsVC, _snippetsVC, _sheetsVC];
    [navTabBarController addParentController:self];
    
    //shadowView
    self.shadowView.frame = self.view.frame;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(filterAction:)];
    [self.shadowView addGestureRecognizer:tapGesture];
    //[self.view addSubview:self.shadowView];
    
    //filterView
    self.filterTitlelabel.text = NSLocalizedString(@"Filter", @"Filter");
    CGRect originFrame = CGRectMake(kScreenWidth, 0, kScreenWidth - filterViewLeftMargin, kScreenHeight);
    [self.filterView setFrame:originFrame];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.filterView addGestureRecognizer:panGesture];
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    UIScreen *mainScreen = UIScreen.mainScreen;
    for (UIWindow *window in frontToBackWindows)
        if (window.screen == mainScreen && window.windowLevel == UIWindowLevelNormal) {
            [window addSubview:self.shadowView];
            [window addSubview:self.filterView];
            break;
        }
    
    //data
    self.roomsArray = [NSMutableArray array];
    self.membersArray = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentTeamID = [defaults valueForKey:kCurrentTeamID];
    NSPredicate *joinedTopicFilter = [NSPredicate predicateWithFormat:@"isQuit = NO AND teams.id = %@", currentTeamID];
    self.roomsArray= (NSMutableArray *)[MORoom MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:joinedTopicFilter];
    self.membersArray = (NSMutableArray *)[MOUser findAllInTeamExceptSelfWithTeamId:currentTeamID sortBy:@"pinyin"];
    
    self.searchResultDictionary = [NSMutableDictionary dictionary];
    [self.searchResultDictionary setObject:self.roomsArray forKey:kTopics];
    [self.searchResultDictionary setObject:self.membersArray forKey:kPrivateChat];
    
    [self guideView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Guide

- (void)guideView {
    if ([GuideHelper checkIsNeedGuideByKey:kGuideMessageShelf]) {
        TalkGuideView *userGuideView = [[TalkGuideView alloc] init];
        [userGuideView showWithTitle:NSLocalizedString(@"Items", @"Items") andSubtitle:NSLocalizedString(@"Manage message easily", @"Manage message easily") andReminder:NSLocalizedString(@"Message Shelf will automatically save all your file, rich text and links here.", @"Message Shelf will automatically save all your file, rich text and links here.")];
    }
}

#pragma mark - Selectors

- (void)filterAction:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchBar resignFirstResponder];
    });
    
    CGRect newFrame;
    CGFloat shadowViewAlpha;
    if (self.isShowFilter) {
        shadowViewAlpha = 0.0;
        newFrame = CGRectMake(kScreenWidth, 0, kScreenWidth - filterViewLeftMargin, kScreenHeight);
    } else {
        self.shadowView.hidden = NO;
        shadowViewAlpha = 0.5;
        newFrame = CGRectMake(filterViewLeftMargin, 0, kScreenWidth - filterViewLeftMargin, kScreenHeight);
    }
    self.isShowFilter = !self.isShowFilter;
    
    [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:3 << 16 animations:^{
        self.filterView.frame = newFrame;
        self.shadowView.alpha = shadowViewAlpha;
    } completion:^(BOOL finished) {
        if (!self.isShowFilter) {
            self.shadowView.hidden = YES;
        }
    }];
}

#pragma mark - handle getsture

- (void)handlePan:(UIPanGestureRecognizer *)panGesture {
    CGPoint point = [panGesture translationInView:self.view];
    DDLogDebug(@"%f",point.x);
    CGFloat filterViewWidth =  kScreenWidth - filterViewLeftMargin;
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            DDLogDebug(@"pan begin");
            break;
            
        case UIGestureRecognizerStateChanged: {
            if (point.x > 0) {
                CGRect newFrame = CGRectMake(filterViewLeftMargin + point.x, 0, kScreenWidth - filterViewLeftMargin, kScreenHeight);
                self.filterView.frame = newFrame;
                
                CGFloat newAlpha = (filterViewWidth - point.x)/filterViewWidth * 0.5;
                self.shadowView.alpha = newAlpha;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
            DDLogDebug(@"pan Ended");
            if (point.x > filterViewWidth/2) {
                self.isShowFilter = YES;
                [self filterAction:nil];
            } else {
                self.isShowFilter = NO;
                [self filterAction:nil];
            }
            break;
        case UIGestureRecognizerStateCancelled: {
            DDLogDebug(@"pan cancel");
            break;
        }
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.searchResultDictionary.allKeys.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else {
        NSString *key = [self.searchResultDictionary.allKeys objectAtIndex:section - 1];
        NSArray *valueArray = [self.searchResultDictionary objectForKey:key];
        return valueArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    } else {
        NSString *key = [self.searchResultDictionary.allKeys objectAtIndex:section - 1];
        return NSLocalizedString(key, key);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBShareToCell *searchcell;
    TBFilterAllCell *allCell;
    if (indexPath.section == 0) {
        allCell = [tableView dequeueReusableCellWithIdentifier:allCellIdentifier forIndexPath:indexPath];
        allCell.nameCell.text = NSLocalizedString(@"All", @"All");
        allCell.tintColor = [UIColor jl_redColor];
        if (self.filterDictionary.allKeys.count == 0) {
            allCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.filterNameLabel.text = NSLocalizedString(@"All", @"All");
        } else {
            allCell.accessoryType = UITableViewCellAccessoryNone;
        }
        return allCell;
    }
    else {
        NSString *key = [self.searchResultDictionary.allKeys objectAtIndex:indexPath.section -1];
        searchcell = [tableView dequeueReusableCellWithIdentifier:shareToCellIdentifier forIndexPath:indexPath];
        searchcell.tintColor = [UIColor jl_redColor];

        if ([kPrivateChat isEqualToString:key]) {
            NSArray *membersArray = [self.searchResultDictionary objectForKey:kPrivateChat];
            searchcell.nameLabel.textColor = [UIColor tb_otherFileColor];
            MOUser *tempUser = [membersArray objectAtIndex:indexPath.row];
            [searchcell setUser:tempUser];
            
            if ([self.filterDictionary.allKeys containsObject:@"_toId"] && [[self.filterDictionary objectForKey:@"_toId"] isEqualToString:tempUser.id]) {
                searchcell.accessoryType = UITableViewCellAccessoryCheckmark;
                self.filterNameLabel.text = [TBUtility getFinalUserNameWithMOUser:tempUser];
            } else {
                searchcell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        else if ([kTopics isEqualToString:key]) {
            NSArray *topicsArray = [self.searchResultDictionary objectForKey:kTopics];
            searchcell.nameLabel.textColor = [UIColor tb_otherFileColor];
            MORoom *tempRoom = [topicsArray objectAtIndex:indexPath.row];
            [searchcell setRoom:tempRoom];
            
            if ([self.filterDictionary.allKeys containsObject:@"_roomId"] && [[self.filterDictionary objectForKey:@"_roomId"] isEqualToString:tempRoom.id]) {
                searchcell.accessoryType = UITableViewCellAccessoryCheckmark;
                self.filterNameLabel.text = [TBUtility getTopicNameWithIsGeneral:tempRoom.isGeneralValue andTopicName:tempRoom.topic];
            } else {
                searchcell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        return searchcell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor tb_tableHeaderGrayColor];
    header.textLabel.font = [UIFont systemFontOfSize:14.0];
    CGRect headerFrame = header.frame;
    headerFrame.origin.x = 15;
    header.textLabel.frame = headerFrame;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self filterAction:nil];
    
    NSMutableDictionary *tempFilterDictionary = [NSMutableDictionary dictionary];
    if (indexPath.section == 0) {
    }
    else {
        NSString *key = [self.searchResultDictionary.allKeys objectAtIndex:indexPath.section -1];
        if ([kPrivateChat isEqualToString:key]) {
            NSArray *membersArray = [self.searchResultDictionary objectForKey:kPrivateChat];
            MOUser *tempUser = [membersArray objectAtIndex:indexPath.row];
            [tempFilterDictionary setObject:tempUser.id forKey:@"_toId"];
        }
        else if ([kTopics isEqualToString:key]) {
            NSArray *topicsArray = [self.searchResultDictionary objectForKey:kTopics];
            MORoom *tempRoom = [topicsArray objectAtIndex:indexPath.row];
            [tempFilterDictionary setObject:tempRoom.id forKey:@"_roomId"];
        }
    }
    self.filterDictionary = [NSDictionary dictionaryWithDictionary:tempFilterDictionary];
    [self.tableView reloadData];
    
    [_filesVC filterDataWith:tempFilterDictionary];
    [_linksVC filterDataWith:tempFilterDictionary];
    [_postsVC filterDataWith:tempFilterDictionary];
    [_snippetsVC filterDataWith:tempFilterDictionary];
    [_sheetsVC filterDataWith:tempFilterDictionary];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchBar resignFirstResponder];
    });
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText  {
    self.searchResultDictionary = [NSMutableDictionary dictionary];
    if (searchText.length == 0) {
        [self.searchResultDictionary setObject:self.roomsArray forKey:kTopics];
        [self.searchResultDictionary setObject:self.membersArray forKey:kPrivateChat];
    } else {
        //for search result
        NSString *searchLowercaseString = searchText.lowercaseString;
        
        NSMutableArray *searchRoomResults = [[NSMutableArray alloc]init];
        for (MORoom *tempRoom in self.roomsArray) {
            NSString *abbreviationString = [Hanzi2Pinyin convertToAbbreviation:tempRoom.topic];
            NSString *pinyinString = [[Hanzi2Pinyin convert:tempRoom.topic] stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([[tempRoom.topic lowercaseString] rangeOfString:searchLowercaseString].location != NSNotFound || [pinyinString rangeOfString:searchLowercaseString].location != NSNotFound || [abbreviationString rangeOfString:searchLowercaseString].location != NSNotFound) {
                [searchRoomResults addObject:tempRoom];
                continue;
            }
        }
        
        NSMutableArray *searchMemeberResults = [[NSMutableArray alloc]init];
        for (MOUser *tempUSer in self.membersArray) {
            NSString *userName = [TBUtility getFinalUserNameWithMOUser:tempUSer];
            NSString *abbreviationString = [Hanzi2Pinyin convertToAbbreviation:userName];
            NSString *pinyinString = [[Hanzi2Pinyin convert:userName] stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([[userName lowercaseString] rangeOfString:searchLowercaseString].location != NSNotFound || [pinyinString rangeOfString:searchLowercaseString].location != NSNotFound || [abbreviationString rangeOfString:searchLowercaseString].location != NSNotFound) {
                [searchMemeberResults addObject:tempUSer];
            }
        }
        
        if (searchMemeberResults.count > 0) {
            [self.searchResultDictionary setObject:searchMemeberResults forKey:kPrivateChat];
        }
        if (searchRoomResults.count > 0) {
            [self.searchResultDictionary setObject:searchRoomResults forKey:kTopics];
        }
    }
    
    [self.tableView reloadData];
}


@end
