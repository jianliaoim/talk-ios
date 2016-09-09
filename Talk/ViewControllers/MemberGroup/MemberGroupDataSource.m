//
//  MemberGroupDataSource.m
//  Talk
//
//  Created by 王卫 on 15/12/23.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "MemberGroupDataSource.h"
#import "MOGroup.h"
#import "JLContactTableViewCell.h"
#import "TBUtility.h"
#import "NSString+Emoji.h"
#import <CoreData+MagicalRecord.h>

@interface MemberGroupDataSource ()

@property (strong, nonatomic) NSArray *allMemberArray;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSMutableArray *selectedIndexPathArray;

@end

static NSString *const kCellIdentifier = @"JLContactTableViewCell";

@implementation MemberGroupDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return self.searchResults.count;
    }
    return self.allMemberArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JLContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if ([self.selectedIndexPathArray containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    NSDictionary *groupAttributes = @{ NSForegroundColorAttributeName:[UIColor tb_otherFileColor],
                                       NSFontAttributeName: [UIFont systemFontOfSize:17]};
    MOGroup *group = nil;
    if (self.isSearching) {
        group = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        group = [self.allMemberArray objectAtIndex:indexPath.row];
    }
    NSMutableAttributedString *groupAttributedString = [[NSMutableAttributedString alloc] initWithString:group.name
                                                                                              attributes:groupAttributes];
    cell.nameLabel.attributedText = groupAttributedString;
    if (indexPath.row == 0) {
        cell.cellPosition = JLContactCellPositionTop;
    } else {
        cell.cellPosition = JLContactCellPositionNormal;
    }
    cell.avatarImageView.image = [UIImage imageNamed:@"icon-member-group"];
    return cell;
}

#pragma mark - common data source protocol

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearching) {
        return [self.searchResults objectAtIndex:indexPath.row];
    } else {
        return [self.allMemberArray objectAtIndex:indexPath.row];
    }
}

- (void)refreshData {
    self.allMemberArray = nil;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.selectedIndexPathArray) {
        self.selectedIndexPathArray = [NSMutableArray new];
    }
    if ([self.selectedIndexPathArray containsObject:indexPath]) {
        [self.selectedIndexPathArray removeObject:indexPath];
    } else {
        [self.selectedIndexPathArray addObject:indexPath];
    }
}

#pragma mark - search updating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    self.searchResults = nil;
    if (searchString.length > 0) {
        self.isSearching = YES;
        NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString];
        self.searchResults = [self.allMemberArray filteredArrayUsingPredicate:groupPredicate];
    } else {
        self.isSearching = NO;
    }
    if ([self.delegate respondsToSelector:@selector(didUpdateSearchResults)]) {
        [self.delegate didUpdateSearchResults];
    }
}

#pragma mark - getter

- (NSArray *)allMemberArray {
    if (!_allMemberArray) {
        NSSortDescriptor *createSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
        NSString *currentTeamId = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"teamId = %@", currentTeamId];
        _allMemberArray = [[MOGroup MR_findAllWithPredicate:predicate] sortedArrayUsingDescriptors:@[createSortDescriptor]];
    }
    return _allMemberArray;
}

@end
