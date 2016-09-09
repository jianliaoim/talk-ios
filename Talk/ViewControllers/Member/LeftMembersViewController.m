//
//  LeftMembersViewController.m
//  Talk
//
//  Created by 史丹青 on 8/6/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "LeftMembersViewController.h"
#import <Hanzi2Pinyin.h>
#import "TBUtility.h"
#import "NSString+Emoji.h"
#import "TBMemberCell.h"

static NSString *CellIdentifier = @"TBMemberCell";

@interface LeftMembersViewController ()

@property (strong, nonatomic) NSMutableDictionary *allMembersDic;
@property (strong, nonatomic) NSMutableArray *arrayDictKey;
@property (nonatomic) BOOL isEnteringChatVC;

@end

@implementation LeftMembersViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Left members", @"Left members");
    [self sortWithName];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor tb_tableViewSeperatorColor];
    self.tableView.sectionIndexColor = [UIColor jl_redColor];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    self.isEnteringChatVC = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

-(void)sortWithName {
    //init data and sort
    NSMutableArray *tempAllArray = [NSMutableArray arrayWithArray:self.leftMembers];
    [tempAllArray sortUsingFunction:UserNameSort context:NULL];
    
    _arrayDictKey = [[NSMutableArray alloc] init];
    _allMembersDic = [[NSMutableDictionary alloc] init];
    
    for (MOUser *contact in tempAllArray) {
        NSString *string = [NSString getFirstWordWithEmojiForString:[Hanzi2Pinyin convertToAbbreviation:[TBUtility getFinalUserNameWithMOUser:contact]]];
        if (![_arrayDictKey containsObject:string]) {
            [_arrayDictKey addObject:string];
            [_allMembersDic setObject:[NSMutableArray arrayWithObject:contact] forKey:string];
        }  else {
            NSMutableArray *newArray = [_allMembersDic objectForKey:string];
            [newArray addObject:contact];
            [_allMembersDic setObject:newArray forKey:string];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return [self.allMembersDic count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger i =  [(self.allMembersDic)[(self.arrayDictKey)[(NSUInteger) section]] count];
    return i;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TBDefaultCellHeight;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.arrayDictKey;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSInteger count = 0;
    for(NSString *character in self.arrayDictKey)
    {
        if([character isEqualToString:title])
        {
            return count;
        }
        count ++;
    }
    return count + 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (self.arrayDictKey)[(NSUInteger) section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *currentIndex = [self.arrayDictKey objectAtIndex:indexPath.section];
    NSArray *sectionUserArray = [self.allMembersDic objectForKey:currentIndex];
    MOUser *user = [sectionUserArray objectAtIndex:indexPath.row];
    NSString *nameString = [TBUtility getFinalUserNameWithMOUser:user];
    cell.nameLabel.text = nameString;
    [cell.cellImageView  sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:user.avatarURL] andPlaceholderImage:[UIImage imageNamed:@"avatar"] options:0 progress:nil completed:nil];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = [UIColor tb_tableHeaderGrayColor];
    header.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //prevent add to many chat ViewController
    if (self.isEnteringChatVC) {
        return;
    }
    self.isEnteringChatVC = YES;
    
    MOUser *moUser = [(self.allMembersDic)[(self.arrayDictKey)[(NSUInteger) indexPath.section]] objectAtIndex:(NSUInteger) indexPath.row];
    
    ChatViewController *tempChatVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    tempChatVC.title = [TBUtility getFinalUserNameWithMOUser:moUser];
    tempChatVC.roomType = ChatRoomTypeForTeamMember;
    tempChatVC.chatStyle = ChatStyleLeft;
    tempChatVC.currentToMember = moUser;
    [TBUtility currentAppDelegate].currentRoom = nil;
    tempChatVC.refreshWhenViewDidLoad = YES;
    [tempChatVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:tempChatVC animated:YES];
}


@end
