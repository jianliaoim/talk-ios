//
//  SearchViewController.m
//  Talk
//
//  Created by Suric on 15/4/28.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "SearchViewController.h"
#import "constants.h"
#import "TBShareToCell.h"
#import "UIAlertView+Blocks.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "Hanzi2Pinyin.h"
#import "TBHTTPSessionManager.h"
#import "SVProgressHUD.h"
#import "MTLJSONAdapter.h"
#import "TBMessage.h"
#import "TBSearchMessageCell.h"
#import "TBSearchQuoteCell.h"
#import "TBUtility.h"
#import "TBSearchBar.h"
#import "SearchMessageViewController.h"

static NSString *HistoryIdentifier = @"TBHistoryCell";
static NSString *SearchIdentifier = @"TBSearchCell";
static NSString *MessageIdentifier = @"TBSearchMessageCell";
static NSString *QuoteIdentifier = @"TBSearchQuoteCell";
static NSInteger const firstShowMaxNum = 3;
static NSString * const kSearchMessageVCSegue = @"ShowSearchMessageVCSegue";

@interface SearchViewController ()
@property (weak, nonatomic) IBOutlet TBSearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIView *noHIstoryHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *noHistoryLabel;
@property (weak, nonatomic) IBOutlet UIView *loadingFooterView;
@property (weak, nonatomic) IBOutlet UILabel *footerLoadingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *footerLoupeImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *searchIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) NSMutableDictionary *searchResultDictionary;
@property (strong, nonatomic) NSMutableArray *sectionTitleArray;
@property (strong, nonatomic) NSMutableArray *roomsArray;
@property (strong, nonatomic) NSMutableArray *membersArray;
@property (strong, nonatomic) NSString *currentSearchString;
@property (strong, nonatomic) NSMutableArray *reloadSectionKeyArray;
@property (nonatomic) BOOL isSearchingHistory;
@end

@implementation SearchViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reloadSectionKeyArray  =[[NSMutableArray alloc]init];
    [self commonInit];
    [self.tableView registerNib:[UINib nibWithNibName:@"TBSearchQuoteCell" bundle:nil] forCellReuseIdentifier:QuoteIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TBSearchMessageCell" bundle:nil] forCellReuseIdentifier:MessageIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
    [[UILabel appearanceWhenContainedIn:[TBSearchBar class], nil] setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    [[UILabel appearanceWhenContainedIn:[TBSearchBar class], nil] setTextColor:[[UIColor grayColor] colorWithAlphaComponent:0.7f]];
}

- (void)commonInit {
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", @"Cancel") forState:UIControlStateNormal];
    [[UILabel appearanceWhenContainedIn:[TBSearchBar class], nil] setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    [self.searchBar setImage:[UIImage imageNamed:@"icon-loupe"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.searchBar setImage:[UIImage imageNamed:@"icon-search-cancel"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    [self.searchBar setImage:[UIImage imageNamed:@"icon-search-cancel-selected"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateHighlighted];
    self.searchBar.placeholder = NSLocalizedString(@"Search everything", @"Search everything");
    [self.searchBar becomeFirstResponder];
    
    CGRect searchBarFrame = CGRectMake(0, 0, kScreenWidth - 30 , 33);
    self.titleView.frame = searchBarFrame;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.titleView];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.noHistoryLabel.text = NSLocalizedString(@"Your search history", @"Your search history");
    UIImage *footLoupeImage = [[UIImage imageNamed:@"icon-loupe"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.footerLoupeImageView.tintColor = [UIColor tb_subTextColor];
    self.footerLoupeImageView.image = footLoupeImage;
    
    self.sectionTitleArray = [NSMutableArray array];
    NSArray *historyArray = [[NSUserDefaults standardUserDefaults] arrayForKey:kSearchHistory];
    if (historyArray.count == 0) {
        self.tableView.tableHeaderView = self.noHIstoryHeaderView;
    } else {
        self.searchResultDictionary = (NSMutableDictionary *)@{kHistory: [NSArray arrayWithArray:historyArray]};
        [self.sectionTitleArray addObject:kHistory];
    }
    self.roomsArray = [NSMutableArray array];
    self.membersArray = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentTeamID = [defaults valueForKey:kCurrentTeamID];
    NSPredicate *joinedTopicFilter = [NSPredicate predicateWithFormat:@"isArchived = NO AND teams.id = %@", currentTeamID];
    self.roomsArray= (NSMutableArray *)[MORoom MR_findAllSortedBy:@"createdAt" ascending:NO withPredicate:joinedTopicFilter];
    self.membersArray = (NSMutableArray *)[MOUser findAllInTeamExceptSelfWithTeamId:currentTeamID sortBy:@"pinyin"];
    
    self.isSearchingHistory = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)searchConversations:(id)sender {
    [self.reloadSectionKeyArray removeAllObjects];
    [TBUtility saveSearchHistoryWithString:self.searchBar.text];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchBar resignFirstResponder];
    });
    [self searchConversationsWithText:self.currentSearchString];
}

- (IBAction)cancel:(id)sender {
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)searchConversationsWithText:(NSString *)searchString {
    self.footerLoadingLabel.text = NSLocalizedString(@"Loading results", @"Loading results");
    self.searchIndicatorView.hidden = NO;
    [self.searchIndicatorView startAnimating];
    
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    NSDictionary *paramsDic  =[NSDictionary dictionaryWithObjectsAndKeys:currentTeamID,@"_teamId",
                                                                         searchString,@"q",
                                                                        [NSNumber numberWithInt:30],@"limit",nil];
    
    [[TBHTTPSessionManager sharedManager]POST:kSearchURLString parameters:paramsDic success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        NSArray *searchedMessageArray = [MTLJSONAdapter modelsOfClass:[TBMessage class] fromJSONArray:[responseDictionary objectForKey:@"messages"] error:nil];
        NSMutableArray *messageArray  =[NSMutableArray array];
        for (TBMessage *message in searchedMessageArray) {
            message.searchCellHeight = [TBSearchMessageCell calculateCellHeightWithMessage:message];
            [messageArray addObject:message];
        }
        
        DDLogDebug(@"Search array Count : %lu",(unsigned long)messageArray.count);
        [self.searchIndicatorView stopAnimating];
        if (messageArray.count == 0) {
            self.footerLoadingLabel.text = NSLocalizedString(@"No results", @"No results");
        } else {
            self.tableView.tableFooterView = nil;
            [self.searchResultDictionary setObject:[NSArray arrayWithArray:messageArray] forKey:kConversations];
            [self.tableView reloadData];
       }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        
        [self.searchIndicatorView stopAnimating];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.sectionTitleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSString *key = [self.sectionTitleArray objectAtIndex:section];
    NSArray *valueArray = [self.searchResultDictionary objectForKey:key];
    
    if ([kHistory isEqualToString:key]) {
        return valueArray.count + 1;
    } else {
        if (valueArray.count > firstShowMaxNum && ![self.reloadSectionKeyArray containsObject:key]) {
            return firstShowMaxNum + 1;
        } else {
            return valueArray.count;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [self.sectionTitleArray objectAtIndex:indexPath.section];
    if ([kConversations isEqualToString:key]) {
        NSArray *valueArray = [self.searchResultDictionary objectForKey:key];
        if (valueArray.count > firstShowMaxNum && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1  && ![self.reloadSectionKeyArray containsObject:key]) {
            return 50;
        }
        NSArray *messageArray = [self.searchResultDictionary objectForKey:kConversations];
        TBMessage *message = [messageArray objectAtIndex:indexPath.row];
        return message.searchCellHeight;
    } else {
        return 50;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *key = [self.sectionTitleArray objectAtIndex:section];
    return NSLocalizedString(key, key);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBShareToCell *searchcell;
    UITableViewCell *historyCell;
    TBSearchMessageCell *messageCell;
    TBSearchQuoteCell *quoteCell;
    NSString *key = [self.sectionTitleArray objectAtIndex:indexPath.section];
    
    if ([kHistory isEqualToString:key]) {
        historyCell = [tableView dequeueReusableCellWithIdentifier:HistoryIdentifier forIndexPath:indexPath];
        
        NSArray *searchHistoryArray = [self.searchResultDictionary objectForKey:kHistory];
        if (indexPath.row == searchHistoryArray.count) {
            historyCell.textLabel.text = NSLocalizedString(@"Clear history", @"Clear history");
            historyCell.textLabel.textColor = [UIColor tb_HighlightColor];
            UIImage *clearImage = [[UIImage imageNamed:@"icon-search-clear"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            historyCell.imageView.tintColor = [UIColor tb_HighlightColor];
            historyCell.imageView.image = clearImage;
        } else {
            NSString *searchString = [searchHistoryArray objectAtIndex:indexPath.row];
            historyCell.textLabel.text = searchString;
            historyCell.imageView.image = [UIImage imageNamed:@"icon-time"];
            historyCell.textLabel.textColor = [UIColor tb_otherFileColor];
            historyCell.imageView.hidden = NO;
        }
    }
    else if([kMembers isEqualToString:key] |[kTopics isEqualToString:key]) {
        searchcell = [tableView dequeueReusableCellWithIdentifier:SearchIdentifier forIndexPath:indexPath];
        searchcell.searchString = self.currentSearchString;
        
        if ([kMembers isEqualToString:key]) {
            NSArray *membersArray = [self.searchResultDictionary objectForKey:kMembers];
            if (membersArray.count > firstShowMaxNum && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1 && ![self.reloadSectionKeyArray containsObject:key]) {
                UIImage *moreImage = [[UIImage imageNamed:@"icon-more"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                searchcell.avatarImageView.tintColor = [UIColor tb_HighlightColor];
                searchcell.avatarImageView.image = moreImage;
                searchcell.nameLabel.textColor = [UIColor tb_HighlightColor];
                searchcell.nameLabel.text = NSLocalizedString(@"View more contacts", @"View more contacts");
            } else {
                searchcell.nameLabel.textColor = [UIColor tb_otherFileColor];
                [searchcell setUser:[membersArray objectAtIndex:indexPath.row]];
            }
        }
        else if ([kTopics isEqualToString:key]) {
            NSArray *topicsArray = [self.searchResultDictionary objectForKey:kTopics];
            if (topicsArray.count > firstShowMaxNum && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1 && ![self.reloadSectionKeyArray containsObject:key]) {
                UIImage *moreImage = [[UIImage imageNamed:@"icon-more"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                searchcell.avatarImageView.tintColor = [UIColor tb_HighlightColor];
                searchcell.avatarImageView.image = moreImage;
                searchcell.nameLabel.text = NSLocalizedString(@"View more topics", @"View more topics");
                searchcell.nameLabel.textColor = [UIColor tb_HighlightColor];
            } else {
                searchcell.nameLabel.textColor = [UIColor tb_otherFileColor];
                [searchcell setRoom:[topicsArray objectAtIndex:indexPath.row]];
            }
        }
        
        return searchcell;
    }
    else {
        NSArray *messageArray = [self.searchResultDictionary objectForKey:kConversations];
        if (messageArray.count > firstShowMaxNum && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1 && ![self.reloadSectionKeyArray containsObject:key]) {
            searchcell = [tableView dequeueReusableCellWithIdentifier:SearchIdentifier forIndexPath:indexPath];
            UIImage *moreImage = [[UIImage imageNamed:@"icon-more"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            searchcell.avatarImageView.tintColor = [UIColor jl_redColor];
            searchcell.avatarImageView.image = moreImage;
            searchcell.nameLabel.text = NSLocalizedString(@"View more conversations", @"View more conversations");
            searchcell.nameLabel.textColor = [UIColor jl_redColor];
            
            return searchcell;
        } else {
            TBMessage *message = [messageArray objectAtIndex:indexPath.row];
            if (message.attachments.count > 0) {
                TBAttachment *firstAttachment = [message.attachments firstObject];
                quoteCell = (TBSearchQuoteCell *)[tableView dequeueReusableCellWithIdentifier:QuoteIdentifier forIndexPath:indexPath];
                quoteCell.currentSearchString = self.currentSearchString;
                if (messageArray.count > 0) {
                    [quoteCell setModel:[messageArray objectAtIndex:indexPath.row] andAttachemnt:firstAttachment];
                    quoteCell.seperator.hidden = NO;
                }
                return quoteCell;
            } else
                messageCell = (TBSearchMessageCell *)[tableView dequeueReusableCellWithIdentifier:MessageIdentifier forIndexPath:indexPath];
                messageCell.currentSearchString = self.currentSearchString;
                TBAttachment *attatchment = message.attachments.firstObject;
                if (messageArray.count > 0) {
                    [messageCell setModel:message andAttachemnt:attatchment];
                    messageCell.seperator.hidden = NO;
                }
                return messageCell;
            }
        }
    return historyCell;
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
    NSString *key = [self.sectionTitleArray objectAtIndex:indexPath.section];
    if ([kHistory isEqualToString:key]) {
        NSArray *searchHistoryArray = [self.searchResultDictionary objectForKey:kHistory];
        if (indexPath.row == searchHistoryArray.count) {
            [UIAlertView showWithTitle:nil
                               message:NSLocalizedString(@"Are you Sure", @"Are you Sure")
                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                     otherButtonTitles:@[NSLocalizedString(@"Sure", @"Sure")]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == 1) {
                                      [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:kSearchHistory];
                                      [[NSUserDefaults standardUserDefaults] synchronize];
                                      self.searchResultDictionary = (NSMutableDictionary *)@{};
                                      [self.sectionTitleArray removeAllObjects];
                                      
                                      [self.tableView reloadData];
                                      self.tableView.tableHeaderView = self.noHIstoryHeaderView;
                                  }
                              }];
            
        } else {
            NSString *searchString = [searchHistoryArray objectAtIndex:indexPath.row];
            self.searchBar.text = searchString;
            self.isSearchingHistory = YES;
            [self searchBar:self.searchBar textDidChange:searchString];
        }
    } else if ([kMembers isEqualToString:key]) {
        NSArray *membersArray = [self.searchResultDictionary objectForKey:kMembers];
        if (membersArray.count > 3 && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1 && ![self.reloadSectionKeyArray containsObject:key]) {
            [self.reloadSectionKeyArray addObject:kMembers];
            [self.tableView beginUpdates];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.sectionTitleArray indexOfObject:key]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        } else {
            [self.navigationController dismissViewControllerAnimated:NO completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kShareForMember object:[membersArray objectAtIndex:indexPath.row]];

            }];
        }
        
    } else if ([kTopics isEqualToString:key]) {
        NSArray *topicsArray = [self.searchResultDictionary objectForKey:kTopics];
        if (topicsArray.count > 3 && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1 && ![self.reloadSectionKeyArray containsObject:key]) {
            [self.reloadSectionKeyArray addObject:kTopics];
            [self.tableView beginUpdates];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[self.sectionTitleArray indexOfObject:key]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        } else {
            [self.navigationController dismissViewControllerAnimated:NO completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kShareForTopic object:[topicsArray objectAtIndex:indexPath.row]];
            }];
        }
    } else if ([kConversations isEqualToString:key]) {
        NSArray *messageArray = [self.searchResultDictionary objectForKey:kConversations];
        if (messageArray.count > 3 && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1 && ![self.reloadSectionKeyArray containsObject:key]) {
            [self performSegueWithIdentifier:kSearchMessageVCSegue sender:messageArray];
        } else {
            [self.navigationController dismissViewControllerAnimated:NO completion:^{
                TBMessage *message = [messageArray objectAtIndex:indexPath.row];
                [[NSNotificationCenter defaultCenter] postNotificationName:KEnterChatForSearchMessage object:message];
            }];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchBar resignFirstResponder];
    });
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText  {
    self.tableView.tableHeaderView = nil;
    self.tableView.tableFooterView = nil;
    [self.reloadSectionKeyArray removeAllObjects];
    self.footerLoadingLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Search messages about", @"Search messages about"),searchText];
    
    if (searchText.length == 0) {
        //for search history
        [self.sectionTitleArray removeAllObjects];
        NSArray *historyArray = [[NSUserDefaults standardUserDefaults] arrayForKey:kSearchHistory];
        if (historyArray.count == 0) {
            self.tableView.tableHeaderView = self.noHIstoryHeaderView;
            self.searchResultDictionary = (NSMutableDictionary *)@{};
        } else {
            self.searchResultDictionary = (NSMutableDictionary *)@{kHistory: historyArray};
            [self.sectionTitleArray addObject:kHistory];
        }
        
        [self.tableView reloadData];
        
    } else {
        self.tableView.tableFooterView = self.loadingFooterView;
        self.footerLoadingLabel.text = NSLocalizedString(@"Loading results", @"Loading results");
        self.searchIndicatorView.hidden = NO;
        [self.searchIndicatorView startAnimating];
        self.searchResultDictionary = (NSMutableDictionary *)@{};
        [self.sectionTitleArray removeAllObjects];
        [self.tableView reloadData];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //for search result
            NSString *searchLowercaseString = searchText.lowercaseString;
            
            NSMutableArray *searchRoomResults = [[NSMutableArray alloc]init];
            for (MORoom *tempRoom in self.roomsArray) {
                NSString *topicName = [TBUtility getTopicNameWithIsGeneral:tempRoom.isGeneralValue andTopicName:tempRoom.topic];
                NSString *abbreviationString = [Hanzi2Pinyin convertToAbbreviation:topicName];
                NSString *pinyinName = [[Hanzi2Pinyin convert:topicName] stringByReplacingOccurrencesOfString:@" " withString:@""];
                if ([[topicName lowercaseString] rangeOfString:searchLowercaseString].location != NSNotFound || [abbreviationString rangeOfString:searchLowercaseString].location != NSNotFound || [[pinyinName lowercaseString] rangeOfString:searchLowercaseString].location != NSNotFound) {
                    [searchRoomResults addObject:tempRoom];
                    continue;
                }
            }
            
            NSMutableArray *searchMemeberResults = [[NSMutableArray alloc]init];
            for (MOUser *tempUSer in self.membersArray) {
                NSString *userName = [TBUtility getFinalUserNameWithMOUser:tempUSer];
                NSString *abbreviationString = [Hanzi2Pinyin convertToAbbreviation:userName];
                NSString *pinyinName = [[Hanzi2Pinyin convert:userName] stringByReplacingOccurrencesOfString:@" " withString:@""];
                if ([[userName lowercaseString] rangeOfString:searchLowercaseString].location != NSNotFound || [abbreviationString rangeOfString:searchLowercaseString].location != NSNotFound || [[pinyinName lowercaseString] rangeOfString:searchLowercaseString].location != NSNotFound) {
                    [searchMemeberResults addObject:tempUSer];
                }
            }
            NSMutableDictionary *resultDictionary  =[NSMutableDictionary dictionary];
            if (searchRoomResults.count > 0) {
                [resultDictionary setObject:searchRoomResults forKey:kTopics];
                [self.sectionTitleArray addObject:kTopics];
            }
            if (searchMemeberResults.count > 0) {
                [resultDictionary setObject:searchMemeberResults forKey:kMembers];
                [self.sectionTitleArray addObject:kMembers];
            }
            [resultDictionary setObject:@[] forKey:kConversations];
            [self.sectionTitleArray addObject:kConversations];
            //set current search string
            self.currentSearchString = searchLowercaseString;
            self.searchResultDictionary = resultDictionary;

            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.searchBar.text isEqualToString:searchText]) {
                    [self.searchIndicatorView stopAnimating];
                    self.footerLoadingLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Search messages about", @"Search messages about"),searchText];
                    self.searchIndicatorView.hidden = YES;
                    [self.tableView reloadData];
                    
                    if (self.isSearchingHistory) {
                        self.isSearchingHistory = NO;
                        [self searchConversations:nil];
                    }
                }
            });
        });
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchConversations:nil];
}

#pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:kSearchMessageVCSegue]) {
         SearchMessageViewController *searchMessageVC = [segue destinationViewController];
         searchMessageVC.inputSearchedMessageArray = sender;
         searchMessageVC.currentSearchString = self.currentSearchString;
     }
 }

@end
