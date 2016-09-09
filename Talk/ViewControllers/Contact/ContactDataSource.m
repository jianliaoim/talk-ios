//
//  ContactDataSource.m
//  Talk
//
//  Created by 王卫 on 15/11/4.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "ContactDataSource.h"
#import "JLContactTableViewCell.h"
#import "MOUser.h"
#import "TBUtility.h"
#import "NSString+Emoji.h"
#import <Hanzi2Pinyin.h>
#import <CoreData+MagicalRecord.h>

@interface ContactDataSource ()

@property (strong, nonatomic) NSDictionary *allMemberDictionary;
@property (strong, nonatomic) NSArray *allMemberArray;
@property (strong, nonatomic) NSArray *sectionIdentifierArray;
@property (strong, nonatomic) NSArray *adminMembersArray;
@property (strong, nonatomic) NSArray *abbreviationArray;

@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSString *searchString;

@end

static NSString *const kCellIdentifier = @"JLContactTableViewCell";

@implementation ContactDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSearching) {
        return 1;
    }
    return self.sectionIdentifierArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return self.searchResults.count;
    }
    NSString *sectionIdentifier = self.sectionIdentifierArray[section];
    return ((NSArray *)self.allMemberDictionary[sectionIdentifier]).count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.isSearching) {
        return nil;
    }
    NSMutableArray *titles = self.sectionIdentifierArray.mutableCopy;
    [titles removeObject:NSLocalizedString(@"Admin", @"Admin")];
    return titles.copy;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (self.isSearching) {
        return 0;
    }
    return [self.sectionIdentifierArray indexOfObject:title];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.isSearching) {
        return nil;
    }
    return self.sectionIdentifierArray[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JLContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    //Get user
    MOUser *user = nil;
    if (self.isSearching) {
        user = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        NSString *sectionIdentier = self.sectionIdentifierArray[indexPath.section];
        user = [self.allMemberDictionary[sectionIdentier] objectAtIndex:indexPath.row];
    }
    
    //Get name string
    NSString *nameString = [TBUtility getFinalUserNameWithMOUser:user] ?: @"";
    NSDictionary *nameAttributes = @{ NSForegroundColorAttributeName : [UIColor tb_otherFileColor],
                                      NSFontAttributeName : [UIFont systemFontOfSize:17]};
    NSMutableAttributedString *nameAttributeString = [[NSMutableAttributedString alloc] initWithString:nameString
                                                                                            attributes:nameAttributes];
    
    //Get role string
    NSString *roleString = nil;
    if ([user.role isEqualToString:@"owner"]) {
        roleString = NSLocalizedString(@"・Owner", @"・Owner");
    } else if ([user.role isEqualToString:@"admin"]) {
        roleString = NSLocalizedString(@"・Admin", @"・Admin");
    }
    NSDictionary *roleAttribute = @{NSForegroundColorAttributeName : [UIColor tb_textGray],
                                    NSFontAttributeName : [UIFont systemFontOfSize:14]};
    
    //Cat
    if (roleString) {
        [nameAttributeString appendAttributedString:[[NSAttributedString alloc] initWithString:roleString attributes:roleAttribute]];
    }
    
    //Configure cell
    cell.nameLabel.attributedText = nameAttributeString;
    [cell.avatarImageView sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:user.avatarURL] andPlaceholderImage:[UIImage imageNamed:@"avatar"] options:0 progress:nil completed:nil];
    if (indexPath.row == 0) {
        cell.cellPosition = JLContactCellPositionTop;
    } else {
        cell.cellPosition = JLContactCellPositionNormal;
    }
    return cell;
}

#pragma mark - Common data source protocol

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearching) {
        return [self.searchResults objectAtIndex:indexPath.row];
    }
    NSString *sectionIdentifer = self.sectionIdentifierArray[indexPath.section];
    return [self.allMemberDictionary[sectionIdentifer] objectAtIndex:indexPath.row];
}

- (void)refreshData {
    self.allMemberArray = nil;
    self.allMemberDictionary = nil;
    self.adminMembersArray = nil;
    self.sectionIdentifierArray = nil;
    self.abbreviationArray = nil;
}

#pragma mark - search updating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text.lowercaseString;
    self.searchResults = nil;
    if (searchString.length > 0) {
        //Refer to SearchViewController search member
        self.isSearching = YES;
        NSMutableArray *tempArray = [NSMutableArray new];
        for (MOUser *user in self.allMemberArray) {
            NSString *userName = [TBUtility getFinalUserNameWithMOUser:user];
            NSString *pinyin = user.pinyin;
            NSString *abbreviationString = [Hanzi2Pinyin convertToAbbreviation:userName];
            if ([[userName lowercaseString] rangeOfString:searchString].location != NSNotFound || [pinyin rangeOfString:searchString].location != NSNotFound || [abbreviationString rangeOfString:searchString].location != NSNotFound) {
                [tempArray addObject:user];
            }
        }
        self.searchResults = tempArray.copy;
    } else {
        self.isSearching = NO;
    }
    if ([self.delegate respondsToSelector:@selector(didUpdateSearchResults)]) {
        [self.delegate didUpdateSearchResults];
    }
}

#pragma mark - Getter

- (NSArray *)sectionIdentifierArray {
    if (!_sectionIdentifierArray) {
        NSMutableArray *allKeys = [self.allMemberDictionary.allKeys sortedArrayUsingSelector:@selector(localizedCompare:)].mutableCopy;
        [allKeys removeObject:NSLocalizedString(@"Admin", @"Admin")];
        [allKeys insertObject:NSLocalizedString(@"Admin", @"Admin") atIndex:0];
        _sectionIdentifierArray = allKeys.copy;
    }
    return _sectionIdentifierArray;
}

- (NSDictionary *)allMemberDictionary {
    if (!_allMemberDictionary) {
        NSMutableDictionary *tempDictionary = [NSMutableDictionary new];
        
        MOUser *talkAI = [MOUser TalkAI];
        NSMutableArray *adminArray = [NSMutableArray new];
        if (talkAI) {
            [adminArray addObject:talkAI];
        }
        
        //Reflect Admins to MOUser
        NSArray *adminUsers = [MOUser findAdminUsersInCurrentTeam];
        [adminArray addObjectsFromArray:adminUsers];
        
        if (adminArray.count > 0) {
            tempDictionary[NSLocalizedString(@"Admin", @"Admin")] = adminArray;
        }
        
        for (MOUser *user in self.allMemberArray) {
            if ([adminArray containsObject:user]) {
                continue;
            }
            NSString *firstLetter = [NSString getFirstWordWithEmojiForString:user.pinyin];
            if ([tempDictionary.allKeys containsObject:firstLetter]) {
                [tempDictionary[firstLetter] addObject:user];
            } else {
                NSMutableArray *newArray = [NSMutableArray new];
                [newArray addObject:user];
                tempDictionary[firstLetter] = newArray;
            }
        }
        
        _allMemberDictionary = [tempDictionary copy];
    }
    return _allMemberDictionary;
}

- (NSArray *)allMemberArray {
    if (!_allMemberArray) {
        NSString *currentTeamId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
        _allMemberArray = [MOUser findAllInTeamExceptSelfWithTeamId:currentTeamId sortBy:@"pinyin"];
    }
    return _allMemberArray;
}


@end
