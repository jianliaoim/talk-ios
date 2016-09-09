//
//  SearchMessageViewController.m
//  Talk
//
//  Created by Suric on 16/2/17.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "SearchMessageViewController.h"
#import "JLFilterButton.h"
#import "UIColor+TBColor.h"
#import "JLFilterScrollView.h"
#import "TBMessage.h"
#import "TBSearchMessageCell.h"
#import "TBSearchQuoteCell.h"
#import "constants.h"
#import "MOUser.h"
#import "MORoom.h"
#import "NSManagedObject+MagicalFinders.h"
#import "TBUtility.h"
#import "TBTag.h"
#import "TBSearchBar.h"
#import "TBHTTPSessionManager.h"
#import "SVProgressHUD.h"
#import "PlaceHolderView.h"
#import "MJRefresh.h"

static NSString *MessageIdentifier = @"TBSearchMessageCell";
static NSString *QuoteIdentifier = @"TBSearchQuoteCell";
static NSString *FilterTableViewCellIdentifier = @"FilterTableViewCell";
static CGFloat const filterCellHeight = 40.0;

@interface SearchMessageViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet TBSearchBar *searchBar;
@property (weak, nonatomic) IBOutlet JLFilterScrollView *filterScrollView;
@property (weak, nonatomic) IBOutlet JLFilterButton *memberButton;
@property (weak, nonatomic) IBOutlet JLFilterButton *locationButton;
@property (weak, nonatomic) IBOutlet JLFilterButton *tagButton;
@property (weak, nonatomic) IBOutlet JLFilterButton *typeButton;
@property (weak, nonatomic) IBOutlet JLFilterButton *timeButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *dimmingView;
@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UITableView *filterTableView;
@property (weak, nonatomic) IBOutlet UIView *bottomGradientView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filterViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filterViewHeightConstraint;
@property (strong, nonatomic) PlaceHolderView *noItemsplaceHolder;
@property (strong, nonatomic) JLFilterButton *selectedButton;

@property (strong, nonatomic) NSArray *allTeamMemberArray;
@property (strong, nonatomic) NSArray *allLocationArray;
@property (strong, nonatomic) NSArray *allTagArray;
@property (strong, nonatomic) NSArray *allTypeArray;
@property (strong, nonatomic) NSArray *allTimeArray;
@property (strong, nonatomic) NSArray *typeNameArray;
@property (strong, nonatomic) NSArray *timeNameArray;
@property (strong, nonatomic) NSMutableArray *allSearchedMessageArray;

@property (nonatomic) NSInteger memberSelectedRow;
@property (nonatomic) NSInteger locationSelectedRow;
@property (nonatomic) NSInteger tagSelectedRow;
@property (nonatomic) NSInteger typeSelectedRow;
@property (nonatomic) NSInteger timeSelectedRow;
@property (nonatomic) NSInteger selectedButtonTag;
@property (nonatomic) int pageNumber;
@end

@implementation SearchMessageViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSearchBar];
    [self setupFilterView];
    [self setupPlaceHolderView];
    [self setupFilterData];
    [self setMJRefresh];
    
    self.allSearchedMessageArray = [[NSMutableArray alloc]init];
    [self.allSearchedMessageArray addObjectsFromArray:self.inputSearchedMessageArray];
    self.pageNumber = 1;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TBSearchQuoteCell" bundle:nil] forCellReuseIdentifier:QuoteIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TBSearchMessageCell" bundle:nil] forCellReuseIdentifier:MessageIdentifier];
}

- (void)setupSearchBar {
    CGRect searchBarFrame = CGRectMake(0, 0, kScreenWidth - 60 , CGRectGetHeight(self.searchBar.frame));
    self.searchBar.frame = searchBarFrame;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.searchBar];
    [[UILabel appearanceWhenContainedIn:[TBSearchBar class], nil] setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7f]];
    [self.searchBar setImage:[UIImage imageNamed:@"icon-loupe"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.searchBar setImage:[UIImage imageNamed:@"icon-search-cancel"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    [self.searchBar setImage:[UIImage imageNamed:@"icon-search-cancel-selected"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateHighlighted];
    self.searchBar.text = self.currentSearchString;
}

- (void)setupFilterView {
    [self setupBottomGradientView];
    self.timeButton.seperatorLine.hidden = YES;
    self.filterTableView.tableFooterView = [[UIView alloc]init];
    self.filterTableView.separatorColor = [UIColor tb_tableViewSeperatorColor];
}

- (void)setupBottomGradientView {
    CAGradientLayer *alphaGradientLayer = [CAGradientLayer layer];
    NSArray *colors =[NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor,(id)[UIColor whiteColor].CGColor, nil];
    [alphaGradientLayer setColors:colors];
    [alphaGradientLayer setStartPoint:CGPointMake(0.5f, 0.0f)];
    [alphaGradientLayer setEndPoint:CGPointMake(0.5f, 0.8f)];
    [alphaGradientLayer setFrame:[self.bottomGradientView bounds]];
    [[self.bottomGradientView layer] setMask:alphaGradientLayer];
    self.bottomGradientView.userInteractionEnabled = YES;
}

- (void)setupPlaceHolderView {
    self.noItemsplaceHolder = (PlaceHolderView *)[[[NSBundle mainBundle]loadNibNamed:@"PlaceHolderView" owner:self options:nil] objectAtIndex:0];
    [self.noItemsplaceHolder setPlaceHolderWithImage:[UIImage imageNamed:@"icon-no-info"] andTitle:NSLocalizedString(@"No message found", nil) andReminder:NSLocalizedString(@"Research message", nil)];
}

- (void)setupFilterData {
    self.selectedButtonTag = -1;
    
    self.allTeamMemberArray = [self fetchAllUserArray];
    self.allLocationArray = [MORoom findAllJoinedRoomInCurrentTeam];
    self.allTagArray = [TBUtility currentAppDelegate].currentTeamTagArray;
    self.allTypeArray = @[@"file",@"rtf",@"url",@"snippet"];
    self.allTimeArray = @[@"day",@"week",@"month",@"quarter"];
    self.typeNameArray = @[NSLocalizedString(@"Files", nil),NSLocalizedString(@"Posts", nil),NSLocalizedString(@"Links", nil),NSLocalizedString(@"Code", nil)];
    self.timeNameArray = @[NSLocalizedString(@"Last day", nil),NSLocalizedString(@"Last week", nil),NSLocalizedString(@"Last month", nil),NSLocalizedString(@"Last three month", nil)];
    
    self.memberSelectedRow = 0;
    self.locationSelectedRow = 0;
    self.tagSelectedRow = 0;
    self.typeSelectedRow = 0;
    self.timeSelectedRow = 3;
}

- (NSArray *)fetchAllUserArray {
    NSSortDescriptor *pinyinSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pinyin" ascending:YES];
    NSArray *noQuitUserArray = [[MOUser findAllInCurrentTeamWithcontainQuit:NO] sortedArrayUsingDescriptors:@[pinyinSortDescriptor]];
    NSArray *quitUserArray = [[MOUser findAllQuitMembersInCurrentTeam] sortedArrayUsingDescriptors:@[pinyinSortDescriptor]];
    NSMutableArray *allUserArray = [NSMutableArray arrayWithArray:noQuitUserArray];
    [allUserArray addObjectsFromArray:quitUserArray];
    return allUserArray;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UILabel appearanceWhenContainedIn:[TBSearchBar class], nil] setTextColor:[[UIColor grayColor] colorWithAlphaComponent:0.7f]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Accessors

- (void)setMemberSelectedRow:(NSInteger)memberSelectedRow {
    _memberSelectedRow = memberSelectedRow;
    [self.memberButton setTitle:[self memberTitleAtRow:memberSelectedRow] forState:UIControlStateNormal];
}

- (void)setLocationSelectedRow:(NSInteger)locationSelectedRow {
    _locationSelectedRow = locationSelectedRow;
    [self.locationButton setTitle:[self locationTitleAtRow:locationSelectedRow] forState:UIControlStateNormal];
}

- (void)setTagSelectedRow:(NSInteger)tagSelectedRow {
    _tagSelectedRow = tagSelectedRow;
    [self.tagButton setTitle:[self tagTitleAtRow:tagSelectedRow] forState:UIControlStateNormal];
}

- (void)setTypeSelectedRow:(NSInteger)typeSelectedRow {
    _typeSelectedRow = typeSelectedRow;
    [self.typeButton setTitle:[self typeTitleAtRow:typeSelectedRow] forState:UIControlStateNormal];
}

- (void)setTimeSelectedRow:(NSInteger)timeSelectedRow {
    _timeSelectedRow = timeSelectedRow;
    [self.timeButton setTitle:[self timeTitleAtRow:timeSelectedRow] forState:UIControlStateNormal];
}

#pragma mark - IBActions

- (IBAction)clickAction:(JLFilterButton *)sender {
    [self searchBarCancelButtonClicked:self.searchBar];
    if (sender.tag < 2) {
        [self.filterScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        [self.filterScrollView scrollRectToVisible:self.timeButton.frame animated:YES];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        if (self.selectedButtonTag >= 0) {
            self.selectedButton.directionImageView.transform = CGAffineTransformIdentity;
            [self.selectedButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        if (self.selectedButtonTag != sender.tag) {
            sender.directionImageView.transform = CGAffineTransformMakeRotation(M_PI);
            [sender setTitleColor:[UIColor jl_redColor] forState:UIControlStateNormal];
        }
    }];
    if (self.selectedButtonTag == sender.tag) {
        [self hideFilterView];
    } else {
        self.selectedButton = sender;
        self.selectedButtonTag = sender.tag;
        [self showFilterViewWithButton:sender.tag];
    }
}

- (IBAction)tapDimmingAction:(id)sender {
    [self hideFilterView];
}

#pragma mark - Private Methods

- (void)showFilterViewWithButton:(NSInteger)tag {
    NSInteger itemsCount = [self tableView:self.filterTableView numberOfRowsInSection:0];
    CGFloat filterViewHeight = itemsCount * filterCellHeight;
    CGFloat filterViewMAXHeight = kScreenHeight - 200;
    if (filterViewHeight > filterViewMAXHeight) {
        filterViewHeight = filterViewMAXHeight;
    }
    self.filterViewHeightConstraint.constant = filterViewHeight;
    [self.filterView layoutIfNeeded];
    [self.filterTableView reloadData];
    
    self.dimmingView.hidden = NO;
    self.filterView.hidden = NO;
    self.dimmingView.backgroundColor = [UIColor clearColor];
    self.filterViewTopConstraint.constant = -filterViewHeight;
    [self.filterView layoutIfNeeded];
    self.filterViewTopConstraint.constant = 0;
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.dimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        [self.filterView layoutIfNeeded];
    } completion:nil];
}

- (void)hideFilterView {
    self.selectedButtonTag = -1;
    
    CGFloat filterViewHeight = CGRectGetHeight(self.filterView.frame);
    self.filterViewTopConstraint.constant = -filterViewHeight;
    [UIView animateWithDuration:0.2 animations:^{
        self.selectedButton.directionImageView.transform = CGAffineTransformIdentity;
        [self.selectedButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.dimmingView.backgroundColor = [UIColor clearColor];
        [self.filterView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.dimmingView.hidden = YES;
        self.filterView.hidden = YES;
    }];
}

- (void)showPlaceHodeView {
    self.tableView.tableHeaderView = self.noItemsplaceHolder;
}

- (void)hidePlaceHolderView {
    if (self.tableView.tableHeaderView) {
        self.tableView.tableHeaderView = nil;
    }
}

#pragma mark-Filter Title

- (NSString *)memberTitleAtRow:(NSInteger)row {
    if (row == 0) {
        return NSLocalizedString(@"All members", nil);
    } else {
        MOUser *user = [self.allTeamMemberArray objectAtIndex:row - 1];
        NSString *finalName = [TBUtility getFinalUserNameWithMOUser:user];
        if (user.isQuitValue) {
            NSString *roleString = NSLocalizedString(@"・Left member", @"・Left member");
            finalName = [finalName stringByAppendingString:roleString];
        }
        return finalName;
    }
}

- (NSString *)locationTitleAtRow:(NSInteger)row {
    if (row == 0) {
        return NSLocalizedString(@"All positions", nil);
    } else if (row == 1) {
        return NSLocalizedString(@"Private chat", nil);
    } else {
        MORoom *room = [self.allLocationArray objectAtIndex:row - 2];
        return [TBUtility getTopicNameWithIsGeneral:room.isGeneralValue andTopicName:room.topic];
    }
}

- (NSString *)tagTitleAtRow:(NSInteger)row {
    if (row == 0) {
        return NSLocalizedString(@"No filter", nil);
    } else if (row == 1) {
        return NSLocalizedString(@"All tags", nil);
    } else {
        TBTag *tag = [self.allTagArray objectAtIndex:row - 2];
        return tag.tagName;
    }
}

- (NSString *)typeTitleAtRow:(NSInteger)row {
    if (row == 0) {
        return NSLocalizedString(@"All types", nil);
    } else {
        NSString *typeName = [self.typeNameArray objectAtIndex:row - 1];
        return typeName;
    }
}

- (NSString *)timeTitleAtRow:(NSInteger)row {
    NSString *timeName = [self.timeNameArray objectAtIndex:row];
    return timeName;
}

#pragma mark-Search Message

- (NSDictionary *)getSearchRequestParameters {
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    NSMutableDictionary *paramsDic  =[NSMutableDictionary dictionaryWithObjectsAndKeys:currentTeamID,@"_teamId",
                                      self.searchBar.text,@"q",
                                      [NSNumber numberWithInt:30],@"limit",
                                      [NSNumber numberWithInt:self.pageNumber],@"page",nil];
    if (self.memberSelectedRow != 0) {
        MOUser *user = [self.allTeamMemberArray objectAtIndex:self.memberSelectedRow - 1];
        [paramsDic setObject:user.id forKey:@"_creatorId"];
    }
    if (self.locationSelectedRow != 0) {
        if (self.locationSelectedRow == 1) {
            [paramsDic setObject:[NSNumber numberWithBool:YES] forKey:@"isDirectMessage"];
        } else {
            MORoom *room = [self.allLocationArray objectAtIndex:self.locationSelectedRow - 2];
            [paramsDic setObject:room.id forKey:@"_roomId"];
            
        }
    }
    if (self.tagSelectedRow != 0) {
        if (self.tagSelectedRow == 1) {
            [paramsDic setObject:[NSNumber numberWithBool:YES] forKey:@"hasTag"];
        } else {
            TBTag *tag = [self.allTagArray objectAtIndex:self.tagSelectedRow - 2];
            [paramsDic setObject:tag.tagId forKey:@"_tagId"];
        }
    }
    if (self.typeSelectedRow != 0) {
        NSString *typeSearchKey = [self.allTypeArray objectAtIndex:self.typeSelectedRow - 1];
        [paramsDic setObject:typeSearchKey forKey:@"type"];
    }
    if (self.timeSelectedRow != 3) {
        NSString *timeSearchKey = [self.allTimeArray objectAtIndex:self.timeSelectedRow];
        [paramsDic setObject:timeSearchKey forKey:@"timeRange"];
    }
    
    return paramsDic;
}

- (void)searchFirstPageMessage {
    self.pageNumber = 1;
    [self searchMessage];
}

- (void)searchMessage {
    if (self.pageNumber == 1) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...") maskType:SVProgressHUDMaskTypeClear];
    }
    
    NSDictionary *paramsDic = [self getSearchRequestParameters];
    [[TBHTTPSessionManager sharedManager]POST:kSearchURLString parameters:paramsDic success:^(NSURLSessionDataTask *task, id responseObject) {
        [SVProgressHUD dismiss];
        [self processSearchedResponse:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [TBUtility showMessageInError:error];
    }];
}

- (void)processSearchedResponse:(NSDictionary *)responseObject {
    if (self.pageNumber == 1) {
        [self.allSearchedMessageArray removeAllObjects];
    }
    
    NSDictionary *responseDictionary = (NSDictionary *)responseObject;
    NSArray *messageJsonArray = responseDictionary[@"messages"];
    int total = [responseDictionary[@"total"] intValue];
    [self setMJRefresh];
    if (total <= self.allSearchedMessageArray.count + messageJsonArray.count) {
        [self.tableView.footer noticeNoMoreData];
    }
    
    self.currentSearchString = self.searchBar.text;
    if (messageJsonArray.count == 0) {
        [self.tableView reloadData];
        [self showPlaceHodeView];
    } else {
        [self hidePlaceHolderView];
        NSArray *searchedMessageArray = [MTLJSONAdapter modelsOfClass:[TBMessage class] fromJSONArray:messageJsonArray error:nil];
        for (TBMessage *message in searchedMessageArray) {
            message.searchCellHeight = [TBSearchMessageCell calculateCellHeightWithMessage:message];
            [self.allSearchedMessageArray addObject:message];
        }
        [self.tableView reloadData];
        if (self.pageNumber > 1) {
            self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + CGRectGetHeight(self.filterScrollView.frame));
        } else {
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
}

#pragma mark-MJRefresh

- (void)setMJRefresh {
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreItems)];
    // Forbid automatical refresh
    self.tableView.footer.automaticallyRefresh = YES;
    // Set title
    [self.tableView.footer setTitle:NSLocalizedString(@"Load more", @"Load more") forState:MJRefreshFooterStateIdle];
    [self.tableView.footer setTitle:NSLocalizedString(@"Loading more items...", @"Loading more items...") forState:MJRefreshFooterStateRefreshing];
    [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateNoMoreData];
}

- (void)loadMoreItems{
    self.pageNumber++;
    [self searchMessage];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self hideFilterView];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    self.searchBar.text = self.currentSearchString;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [TBUtility saveSearchHistoryWithString:self.searchBar.text];
    [self.searchBar resignFirstResponder];
    [self searchFirstPageMessage];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.filterTableView) {
        switch (self.selectedButtonTag) {
            case 0:
                return self.allTeamMemberArray.count + 1;
                break;
            case 1:
                return self.allLocationArray.count + 2;
                break;
            case 2:
                return self.allTagArray.count + 2;
                break;
            case 3:
                return self.allTypeArray.count + 1;
                break;
            case 4:
                return self.allTimeArray.count;
                break;
            default:
                return 0;
                break;
        }
    } else {
        return self.allSearchedMessageArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.filterTableView) {
        return filterCellHeight;
    } else {
        TBMessage *message = [self.allSearchedMessageArray objectAtIndex:indexPath.row];
        return message.searchCellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.filterTableView) {
        UITableViewCell *filterCell = [tableView dequeueReusableCellWithIdentifier:FilterTableViewCellIdentifier forIndexPath:indexPath];
        filterCell.textLabel.textColor = [UIColor lightGrayColor];
        filterCell.textLabel.font = [UIFont systemFontOfSize:14.0];
        filterCell.accessoryType = UITableViewCellAccessoryNone;
        filterCell.tintColor = [UIColor jl_redColor];
        switch (self.selectedButtonTag) {
            case 0:
                filterCell.textLabel.text = [self memberTitleAtRow:indexPath.row];
                if (indexPath.row == self.memberSelectedRow) {
                    filterCell.textLabel.textColor = [UIColor jl_redColor];
                    filterCell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 1:
                filterCell.textLabel.text = [self locationTitleAtRow:indexPath.row];
                if (indexPath.row == self.locationSelectedRow) {
                    filterCell.textLabel.textColor = [UIColor jl_redColor];
                    filterCell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 2:
                filterCell.textLabel.text = [self tagTitleAtRow:indexPath.row];
                if (indexPath.row == self.tagSelectedRow) {
                    filterCell.textLabel.textColor = [UIColor jl_redColor];
                    filterCell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 3:
                filterCell.textLabel.text = [self typeTitleAtRow:indexPath.row];
                if (indexPath.row == self.typeSelectedRow) {
                    filterCell.textLabel.textColor = [UIColor jl_redColor];
                    filterCell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 4:
                filterCell.textLabel.text = [self timeTitleAtRow:indexPath.row];
                if (indexPath.row == self.timeSelectedRow) {
                    filterCell.textLabel.textColor = [UIColor jl_redColor];
                    filterCell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            default:
                break;
        }
        return filterCell;
    } else {
        TBSearchMessageCell *messageCell;
        TBSearchQuoteCell *quoteCell;
        TBMessage *message = [self.allSearchedMessageArray objectAtIndex:indexPath.row];
        if (message.attachments.count > 0) {
            TBAttachment *firstAttachment = [message.attachments firstObject];
            quoteCell = (TBSearchQuoteCell *)[tableView dequeueReusableCellWithIdentifier:QuoteIdentifier forIndexPath:indexPath];
            quoteCell.currentSearchString = self.currentSearchString;
            if (self.allSearchedMessageArray.count > 0) {
                [quoteCell setModel:[self.allSearchedMessageArray objectAtIndex:indexPath.row] andAttachemnt:firstAttachment];
                quoteCell.seperator.hidden = NO;
            }
            return quoteCell;
        } else {
            messageCell = (TBSearchMessageCell *)[tableView dequeueReusableCellWithIdentifier:MessageIdentifier forIndexPath:indexPath];
            messageCell.currentSearchString = self.currentSearchString;
            TBAttachment *attatchment = message.attachments.firstObject;
            if (self.allSearchedMessageArray.count > 0) {
                [messageCell setModel:message andAttachemnt:attatchment];
                messageCell.seperator.hidden = NO;
            }
            return messageCell;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.filterTableView) {
        switch (self.selectedButtonTag) {
            case 0:
                self.memberSelectedRow = indexPath.row;
                break;
            case 1:
                self.locationSelectedRow = indexPath.row;
                break;
            case 2:
                self.tagSelectedRow = indexPath.row;
                break;
            case 3:
                self.typeSelectedRow = indexPath.row;
                break;
            case 4:
                self.timeSelectedRow = indexPath.row;
                break;
            default:
                break;
        }
        [self searchFirstPageMessage];
        [self hideFilterView];
    } else {
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            TBMessage *message = [self.allSearchedMessageArray objectAtIndex:indexPath.row];
            [[NSNotificationCenter defaultCenter] postNotificationName:KEnterChatForSearchMessage object:message];
        }];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self searchBarCancelButtonClicked:self.searchBar];
}


@end
