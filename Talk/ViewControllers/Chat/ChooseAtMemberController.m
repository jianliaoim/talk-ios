//
//  ChooseAtMenberController.m
//  Talk
//
//  Created by teambition-ios on 14/10/13.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "ChooseAtMemberController.h"
#import "constants.h"
#import "UIColor+TBColor.h"
#import "TBMemberCell.h"
#import "TBUser.h"
#import <Hanzi2Pinyin.h>
#import "CoreData+MagicalRecord.h"
#import "MOUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TBUtility.h"
#import "CoreData+MagicalRecord.h"
#import "SVProgressHUD.h"
#import "TBHTTPSessionManager.h"
#import "MORoom.h"
#import "FEMManagedObjectDeserializer.h"
#import "MappingProvider.h"
#import "MOUser.h"

static NSString *CellIdentifier = @"TBMemberCell";

@interface ChooseAtMemberController ()
@property (strong, nonatomic) NSMutableArray *teamMemberArray;
@property (strong, nonatomic) NSMutableDictionary*allContactsDic;  //all contact dictionary
@property (strong, nonatomic) NSMutableArray*arrayDictKey;
@end

@implementation ChooseAtMemberController

//sort method
NSInteger NameSort1(id user1, id user2, void *context)
{
    TBUser *u1,*u2;
    u1 = (TBUser*)user1;
    u2 = (TBUser*)user2;
    return  [u1.name localizedCompare:u2.name
             ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self commonInit];
    [self fetchData];
    [self sortData];
    [self updateData];
}

-(void)commonInit {
    self.title = NSLocalizedString(@"Choose At", nil) ;
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelDo:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    [self.navigationController.navigationBar setBarTintColor:self.tintColor];
    
    self.tableView.rowHeight = 65.0f;
    self.tableView.separatorColor = [UIColor colorWithRed:0.0 /255.0 green:0.0 /255.0 blue:0.0 /255.0 alpha:0.1];
    self.tableView.sectionIndexColor = self.tintColor;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    UINib *nib = [UINib nibWithNibName:CellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
}

-(void)updateData {
    if (self.chooseAtCategory != ChooseAtMemberForRoom) {
        return;
    }
    
    if (self.currentRoomMembersArray.count == 0) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
    }
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:[NSString stringWithFormat:@"%@/%@",kTopicURLString,[TBUtility currentAppDelegate].currentRoom.id]
      parameters:nil
         success:^(NSURLSessionDataTask *task, id responseObject) {
             [SVProgressHUD dismiss];
             
             // process members data
             NSArray *memberArray   = responseObject[@"members"];
             [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                 NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:[TBUtility currentAppDelegate].currentRoom.id];
                 MORoom *currentRoom = [MORoom MR_findFirstWithPredicate:predicate inContext:localContext];
                 NSArray *previousMemberArray = [MOUser findAllInTopicWithTopicId:currentRoom.id containRobot:NO];
                 for (MOUser *previousMember in previousMemberArray) {
                     [currentRoom removeMembersObject:previousMember];
                 }
                 
                 NSError *error;
                 NSArray *tbUserArray = [MTLJSONAdapter modelsOfClass:[TBUser class] fromJSONArray:memberArray error:&error];
                 for (TBUser *user in tbUserArray) {
                     MOUser *newMOUSer = [MOUser findFirstWithId:user.id inContext:localContext];
                     if (!newMOUSer) {
                         newMOUSer = [MTLManagedObjectAdapter managedObjectFromModel:user insertingIntoContext:localContext error:&error];
                     }
                     if (!newMOUSer.isGuestValue) {
                         [currentRoom addMembersObject:newMOUSer];
                     }
                 }
             } completion:^(BOOL success, NSError *error) {
                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                     [self fetchData];
                     [self sortData];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.tableView reloadData];
                     });
                 });
             }];
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             DDLogError(@"error: %@", error.localizedRecoverySuggestion);
             [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
         }];
}

- (void)fetchData {
    NSArray *memberArray;
    if (self.chooseAtCategory == ChooseAtMemberForStory) {
        NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        NSArray *userIds = [TBUtility currentAppDelegate].currentStory.members;
        memberArray = [MOUser findUsersWithIds:userIds NotIncludeIds:@[currentUserID]];
    } else if (self.chooseAtCategory == ChooseAtMemberForRoom) {
        memberArray = [MOUser findTopicMembersExceptSelfAndSortByNameWithTopicId:[TBUtility currentAppDelegate].currentRoom.id];
    } else {
        memberArray = [NSArray arrayWithObject:self.chatUser];
    }
    self.currentRoomMembersArray = [NSMutableArray arrayWithArray:memberArray];
}

- (void)sortData {
    NSMutableArray *tempAllArray = [NSMutableArray array];
    [tempAllArray addObjectsFromArray:self.currentRoomMembersArray];
    [tempAllArray sortUsingFunction:NameSort1 context:NULL];
    
    _arrayDictKey = [[NSMutableArray alloc] init];
    for (MOUser *contact in tempAllArray) {
        NSString *string = [[[Hanzi2Pinyin convertToAbbreviation:contact.name] substringToIndex:1] uppercaseString];
        if (![_arrayDictKey containsObject:string]) {
            [_arrayDictKey addObject:string];
        }
    }
    [_arrayDictKey sortUsingSelector:@selector(localizedCompare:)];
    _allContactsDic = [[NSMutableDictionary alloc] init];
    for (NSString *firstWord in _arrayDictKey) {
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for (MOUser *contact in tempAllArray) {
            NSString *string = [[[Hanzi2Pinyin convertToAbbreviation:contact.name] substringToIndex:1] uppercaseString];
            if ([string isEqualToString:firstWord])
            {
                [tempArray addObject:contact];
            }
        }
        [_allContactsDic setValue:tempArray forKey:firstWord];
    }
}

-(void)cancelDo:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:KCancelAt object:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return [self.allContactsDic count] + 1;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *indexArray = [NSMutableArray arrayWithObject:@"#"];
    [indexArray addObjectsFromArray:self.arrayDictKey];
    return indexArray;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (index == 0) {
        return 0;
    } else {
        NSInteger count = 0;
        NSLog(@"%@",title);
        for(NSString *character in self.arrayDictKey)
        {
            if([character isEqualToString:title]) {
                return count+1;
            }
            count ++;
        }
        return count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"#";
    } else {
         return [self.arrayDictKey objectAtIndex:section-1];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        NSInteger i =  [[self.allContactsDic objectForKey:[self.arrayDictKey objectAtIndex:section-1]] count];
        return i;
    }
}

//fix iOS 8.3 bug
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.section ==0 ) {
        cell.cellImageView.image = [UIImage imageNamed:@"icon-teamsetting"];
        cell.nameLabel.text = NSLocalizedString(@"Allmembers", nil);
    } else {
        MOUser *tempContact = [[_allContactsDic objectForKey:[self.arrayDictKey objectAtIndex:indexPath.section-1]] objectAtIndex:indexPath.row];
        [cell.cellImageView sd_setImageWithURL:[NSURL URLWithString:tempContact.avatarURL] placeholderImage:[UIImage imageNamed:@"avatar"] options:CACHE_POLICY];
        cell.nameLabel.text = [TBUtility getFinalUserNameWithMOUser:tempContact];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TBMemberCell *tempCell = (TBMemberCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString *tempStr = [NSString stringWithFormat:@"%@ ",tempCell.nameLabel.text];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:KSelectedAtMember object:tempStr];
}

@end
