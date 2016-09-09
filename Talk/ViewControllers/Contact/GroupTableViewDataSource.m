//
//  GroupTableViewController.m
//  Talk
//
//  Created by 王卫 on 15/11/5.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "GroupTableViewDataSource.h"
#import "JLContactTableViewCell.h"
#import "MOUser.h"
#import "TBUtility.h"
#import "NSString+Emoji.h"
#import "MORoom.h"
#import <Hanzi2Pinyin.h>
#import <CoreData+MagicalRecord.h>

@interface GroupTableViewDataSource ()
@property (strong, nonatomic) NSArray *allMemberArray;
@property (strong, nonatomic) NSDictionary *allMemberDictionary;

@property (strong, nonatomic) NSArray *searchResults;

@end

static NSString *const kCellIdentifier = @"JLContactTableViewCell";
static NSString *const kJoinedGroup = @"JoinedGroup";
static NSString *const kJoinableGroup = @"JoinableGroup";

@implementation GroupTableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isSearching) {
        return 1;
    }
    return self.allMemberDictionary.allKeys.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
        return self.searchResults.count;
    }
    
    switch (section) {
        case 0:
            return [self.allMemberDictionary[kJoinedGroup] count];
        case 1: {
            return [self.allMemberDictionary[kJoinableGroup] count];
        }
        case 2: {
            return 1;
        }
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JLContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.avatarImageView.contentMode = UIViewContentModeCenter;
    
    NSDictionary *topicAttributes = @{ NSForegroundColorAttributeName : [UIColor tb_otherFileColor],
                                       NSFontAttributeName : [UIFont systemFontOfSize:17]};
    MORoom *room = nil;
    if (self.isSearching) {
        room = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        if (indexPath.section == 0) {
            room = [self.allMemberDictionary[kJoinedGroup] objectAtIndex:indexPath.row];
        } else if (indexPath.section == 1) {
            room = [self.allMemberDictionary[kJoinableGroup] objectAtIndex:indexPath.row];
        } else {
            NSMutableAttributedString *archivedTopic = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"View All Archived Topics", @"View All Archived Topics") attributes:topicAttributes];
            cell.nameLabel.attributedText = archivedTopic;
            cell.avatarImageView.image = [UIImage imageNamed:@"icon-archive"];
            return cell;
        }
    }
    
    //Get topic string
    NSString *topicString = [TBUtility getTopicNameWithIsGeneral:room.isGeneralValue andTopicName:room.topic] ?: @"";
    NSMutableAttributedString *topicAttributeString = [[NSMutableAttributedString alloc] initWithString:topicString
                                                                                            attributes:topicAttributes];
    
    cell.nameLabel.attributedText = topicAttributeString;
    if (!room.color) {
        room.color = @"doc";
    }
    cell.avatarImageView.tintColor = [UIColor tb_blueColor];
    UIImage *image;
    if (room.isPrivateValue) {
        image = [[UIImage imageNamed:@"icon-lock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        image = [UIImage imageNamed:@"TopicLogo"];
    }
    [cell.avatarImageView setImage:image];
    cell.avatarImageView.contentMode = UIViewContentModeScaleToFill;
    
    if (indexPath.row == 0) {
        cell.cellPosition = JLContactCellPositionTop;
    } else {
        cell.cellPosition = JLContactCellPositionNormal;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.isSearching) {
        return nil;
    }
    switch (section) {
        case 0:
            return NSLocalizedString(@"Joined", @"Joined");
        case 1:
            return NSLocalizedString(@"Joinable", @"Joinable");
        case 2:
            return NSLocalizedString(@"Archived", @"Archived");
    }
    return nil;
}

#pragma mark - Common data source protocol

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSearching) {
        return [self.searchResults objectAtIndex:indexPath.row];
    }
    if (indexPath.section == 0) {
        return [self.allMemberDictionary[kJoinedGroup] objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        return [self.allMemberDictionary[kJoinableGroup] objectAtIndex:indexPath.row];
    } else {
        return nil;
    }
}

- (void)refreshData {
    self.allMemberArray = nil;
    self.allMemberDictionary = nil;
}

#pragma mark - search updating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text.lowercaseString;
    self.searchResults = nil;
    if (searchString.length > 0) {
        self.isSearching = YES;
        NSMutableArray *tempArray = [NSMutableArray new];
        for (MORoom *room in self.allMemberArray) {
            NSString *roomName = [TBUtility getTopicNameWithIsGeneral:room.isGeneralValue andTopicName:room.topic] ?: @"";
            NSString *pinyin = [Hanzi2Pinyin convert:roomName];
            NSString *abbreviationString = [Hanzi2Pinyin convertToAbbreviation:roomName];
            if ([[roomName lowercaseString] rangeOfString:searchString].location != NSNotFound || [pinyin rangeOfString:searchString].location != NSNotFound || [abbreviationString rangeOfString:searchString].location != NSNotFound) {
                [tempArray addObject:room];
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

- (NSDictionary *)allMemberDictionary {
    if (!_allMemberDictionary) {
        NSMutableDictionary *tempDictionary = [NSMutableDictionary new];
        NSArray *joinedGroup = [self.allMemberArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isQuit = NO"]];
        NSArray *joinableGroup = [self.allMemberArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isQuit = YES AND isPrivate = NO"]];
        
        tempDictionary[kJoinedGroup] = joinedGroup;
        tempDictionary[kJoinableGroup] = joinableGroup;
        _allMemberDictionary = tempDictionary.copy;
    }
    return _allMemberDictionary;
}

- (NSArray *)allMemberArray {
    if (!_allMemberArray) {
        NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
        NSPredicate *memberPredicate = [NSPredicate predicateWithFormat:@"(isArchived = NO) AND (teams.id = %@)", currentTeamID];
        NSSortDescriptor *createSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
        _allMemberArray = [[MORoom MR_findAllWithPredicate:memberPredicate] sortedArrayUsingDescriptors:@[createSortDescriptor]];
    }
    return _allMemberArray;
}


@end
