//
//  JLShareSendController.m
//  Talk
//
//  Created by teambition-ios on 15/4/14.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "JLShareSendController.h"
#import "ShareConstants.h"
#import "JLShareViewController.h"
#import "JLSharePoster.h"
#import <MobileCoreServices/MobileCoreServices.h>

static NSString * const cellIdentifier = @"TBShareSendCell";

@interface JLShareSendController ()<UIContentContainer>
@property (strong, nonatomic) NSMutableArray *recentMessageArray;
@property (strong, nonatomic) NSMutableArray *roomsArray;
@property (strong, nonatomic) NSMutableArray *membersArray;
@property (strong, nonatomic) NSIndexPath *lastSelectedIndexPath;
@property (strong, nonatomic) NSMutableArray *selectedIndexPaths;
@property (copy, nonatomic) NSString *currentUserId;
@property (strong, nonatomic) NSDictionary *roomInfo;
@property (strong, nonatomic) NSDictionary *memberInfo;

@end

@implementation JLShareSendController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Choose", @"Choose");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Send") style:UIBarButtonItemStylePlain target:self action:@selector(send:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSUserDefaults *groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:kTalkGroupID];
    self.currentUserId = [groupDefaults objectForKey:kCurrentUserKey];
    self.selectedIndexPaths = [NSMutableArray new];
    
    self.recentMessageArray = [[NSMutableArray alloc] init];
    self.roomsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *roomDic in self.teamDic[@"rooms"]) {
        if (![roomDic[@"isQuit"] boolValue]) {
            [self.roomsArray addObject:roomDic];
        }
    }
    self.membersArray = [NSMutableArray arrayWithArray:self.teamDic[@"members"]];
    
    NSArray *allRecentMesageArray = [NSMutableArray arrayWithArray:self.teamDic[@"latestMessages"]];
    if (allRecentMesageArray.count < 5) {
        [self.recentMessageArray addObjectsFromArray:allRecentMesageArray];
    }
    else {
        for (int i = 0; i<=4; i++) {
            [self.recentMessageArray addObject:[allRecentMesageArray objectAtIndex:i]];
        }
    }
    CGFloat maxHeight = [[UIScreen mainScreen] bounds].size.height - 200;
    CGFloat minHeight = 44*5;
    CGFloat height;
    if (self.recentMessageArray.count > 0) {
        height = (self.roomsArray.count + self.membersArray.count + self.recentMessageArray.count) * 44 + 44 + 66;
    } else {
        height = (self.roomsArray.count + self.membersArray.count) * 44 + 44 + 44;
    }
    height = MAX(height, minHeight);
    self.preferredContentSize = CGSizeMake(self.view.frame.size.width, MIN(height, maxHeight));
    if ([self.uiDelegate respondsToSelector:@selector(updateContainerHeight:)]) {
        [self.uiDelegate updateContainerHeight:self.preferredContentSize.height];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - Private methods

- (void)send:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicator startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];
    if (self.isStory) {
        NSMutableArray *memberIds = [NSMutableArray new];
        for (NSIndexPath *indexPath in self.selectedIndexPaths) {
            NSDictionary *member = self.membersArray[indexPath.row];
            [memberIds addObject:member[@"_id"]];
        }
        [memberIds addObject:self.currentUserId];
        [JLSharePoster sharedPoster].memberIds = memberIds.copy;
        [JLSharePoster sharedPoster].isCreateStory = YES;
    } else {
        [JLSharePoster sharedPoster].isCreateStory = NO;
        if (self.roomInfo) {
            [JLSharePoster sharedPoster].selectedMemberId = nil;
            [JLSharePoster sharedPoster].selectedRoomId = self.roomInfo[@"_id"];
        } else {
            [JLSharePoster sharedPoster].selectedRoomId = nil;
            [JLSharePoster sharedPoster].selectedMemberId = self.memberInfo[@"_id"];
        }
    }
    
    NSExtensionItem *inputItem = self.extensionContext.inputItems.firstObject;
    NSItemProvider *itemProvider = inputItem.attachments.firstObject;
    if (inputItem.attachments.count > 1) {
        NSLog(@"inputItem.attachments: %@", inputItem.attachments);
        for (NSItemProvider *tempitemProvider in inputItem.attachments) {
            if ([tempitemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText]) {
                itemProvider = tempitemProvider;
            }
        }
    }
    
    JLSharePoster *sharePoster = [JLSharePoster sharedPoster];
    if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
        [[JLSharePoster sharedPoster] sendImageDataToStriker:sharePoster.fileData andName:sharePoster.fileName isImage:YES];
    } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList]) {
        if (self.isStory) {
            [sharePoster createStoryWithLink:sharePoster.link title:sharePoster.messageText];
        } else {
            NSString *messageContent = sharePoster.link;
            [sharePoster sendTextMessageToServer:messageContent];
        }
    } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeFileURL]) {
        [sharePoster sendImageDataToStriker:sharePoster.fileData andName:sharePoster.fileName isImage:NO];
    } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText]) {
        if (self.isStory) {
            if (sharePoster.link) {
                [sharePoster createStoryWithLink:sharePoster.link title:sharePoster.messageText];
            } else {
                [sharePoster createStoryWithIdea:sharePoster.messageText];
            }
        } else {
            if (sharePoster.link) {
                [sharePoster sendTextMessageToServer:[sharePoster.messageText stringByAppendingFormat:@" %@",sharePoster.link]];
            } else {
                [sharePoster sendTextMessageToServer:sharePoster.messageText];
            }
        }
    }
    
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (self.isStory) {
        return 1;
    } else {
        if (self.recentMessageArray.count > 0) {
            return 3;
        } else {
            return 2;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isStory) {
        return self.membersArray.count;
    }
    switch (section) {
        case 0:
            if (self.recentMessageArray.count > 0) {
                return self.recentMessageArray.count;
            } else {
                return self.roomsArray.count;
            }
            break;
        case 1:
            if (self.recentMessageArray.count > 0) {
                return self.roomsArray.count;
            } else {
                return self.membersArray.count;
            }
            break;
        case 2:
            return self.membersArray.count;
            break;
            
        default:
            return 0;
            break;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.isStory) {
        return nil;
    }
    if (self.recentMessageArray.count > 0) {
        switch (section) {
            case 0:
                return  NSLocalizedString(@"Recent", @"Recent");
                break;
            case 1:
                return  NSLocalizedString(@"Topics", @"Topics");
                break;
            case 2:
                return NSLocalizedString(@"Members", @"Members");
                break;
            default:
                return nil;
                break;
        }
    } else {
        switch (section) {
            case 0:
                return  NSLocalizedString(@"Topics", @"Topics");
                break;
            case 1:
                return NSLocalizedString(@"Members", @"Members");
                break;
            default:
                return nil;
                break;
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Dequeue a cell from self's table view.
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([self.selectedIndexPaths containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.isStory) {
        NSDictionary *memberDic = [self.membersArray objectAtIndex:indexPath.row];
        if ([memberDic[@"_id"] isEqualToString:self.currentUserId]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        cell.textLabel.text = memberDic[@"name"];
        if ([memberDic[@"prefs"][@"alias"] length] > 0) {
            cell.textLabel.text = memberDic[@"prefs"][@"alias"];
        }
        return cell;
    }
    
    NSUserDefaults *groupDefaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
    
    if (self.recentMessageArray.count > 0) {
        switch (indexPath.section) {
            case 0: {
                NSDictionary *messageDic = [self.recentMessageArray objectAtIndex:indexPath.row];
                // Judge whether the message is group or direct message
                if (messageDic[@"_roomId"]) {
                    // Get topic information
                    for (NSDictionary *roominfoDic in self.roomsArray) {
                        if ([messageDic[@"_roomId"] isEqualToString:roominfoDic[@"_id"]]) {
                            if ([roominfoDic[@"isGeneral"] boolValue]) {
                                 cell.textLabel.text = NSLocalizedString(@"General", @"General");
                            }
                            else {
                                 cell.textLabel.text = roominfoDic[@"topic"];
                            }
                           
                            break;
                        }
                    }
                    
                }
                else {
                    // Get target user when is direct message
                    NSString *creatorID = messageDic[@"_creatorId"];
                    NSString *toID = messageDic[@"_toId"];
                    NSString *targetUserID = nil;
                    
                    if ([toID isEqualToString:[groupDefaults objectForKey:kCurrentUserKey]]) {
                        targetUserID = creatorID;
                    }
                    else {
                        targetUserID = toID;
                    }
                    for (NSDictionary *memberInfoDic in self.membersArray) {
                        if ([targetUserID isEqualToString:memberInfoDic[@"_id"]]) {
                            cell.textLabel.text = memberInfoDic[@"name"];
                            if ([memberInfoDic[@"prefs"][@"alias"] length] > 0) {
                                cell.textLabel.text = memberInfoDic[@"prefs"][@"alias"];
                            }
                            break;
                        }
                    }
                    
                }
                break;
            }
            case 1: {
                NSDictionary *roomDic = [self.roomsArray objectAtIndex:indexPath.row];
                if ([roomDic[@"isGeneral"] boolValue]) {
                    cell.textLabel.text = NSLocalizedString(@"General", @"General");
                }
                else {
                    cell.textLabel.text = roomDic[@"topic"];
                }
                break;
            }
                
            case 2:{
                NSDictionary *memberDic = [self.membersArray objectAtIndex:indexPath.row];
                cell.textLabel.text = memberDic[@"name"];
                if ([memberDic[@"prefs"][@"alias"] length] > 0) {
                    cell.textLabel.text = memberDic[@"prefs"][@"alias"];
                }
                break;
            }
            default:
                return nil;
                break;
        }
    } else {
        switch (indexPath.section) {
            case 0: {
                NSDictionary *roomDic = [self.roomsArray objectAtIndex:indexPath.row];
                if ([roomDic[@"isGeneral"] boolValue]) {
                    cell.textLabel.text = NSLocalizedString(@"General", @"General");
                }
                else {
                    cell.textLabel.text = roomDic[@"topic"];
                }
                break;
            }
            case 1: {
                NSDictionary *memberDic = [self.membersArray objectAtIndex:indexPath.row];
                cell.textLabel.text = memberDic[@"name"];
                if ([memberDic[@"prefs"][@"alias"] length] > 0) {
                    cell.textLabel.text = memberDic[@"prefs"][@"alias"];
                }
                break;
            }
            default:
                return nil;
                break;
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUserDefaults *groupDefaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    if (![self.selectedIndexPaths containsObject:indexPath]) {
        if (!self.isStory) {
            [self.selectedIndexPaths removeAllObjects];
        }
        [self.selectedIndexPaths addObject:indexPath];
        [self.tableView reloadData];
    } else {
        if (self.isStory) {
            [self.selectedIndexPaths removeObject:indexPath];
            [self.tableView reloadData];
        }
    }
    if (self.isStory) {
        return;
    }
    
    if (self.recentMessageArray.count > 0) {
        switch (indexPath.section) {
            case 0: {
                NSDictionary *messageDic = [self.recentMessageArray objectAtIndex:indexPath.row];
                // Judge whether the message is group or direct message
                NSString *roomID = messageDic[@"_roomId"];
                if (roomID) {
                    // Get topic information
                    for (NSDictionary *roominfoDic in self.roomsArray) {
                        if ([messageDic[@"_roomId"] isEqualToString:roominfoDic[@"_id"]]) {
                            self.roomInfo = roominfoDic;
                            self.memberInfo = nil;
                            break;
                        }
                    }
                    
                }
                else {
                    // Get target user when is direct message
                    NSString *creatorID = messageDic[@"_creatorId"];
                    NSString *toID = messageDic[@"_toId"];
                    NSString *targetUserID = nil;
                    
                    if ([toID isEqualToString:[groupDefaults objectForKey:kCurrentUserKey]]) {
                        targetUserID = creatorID;
                    }
                    else {
                        targetUserID = toID;
                    }
                    for (NSDictionary *memberInfoDic in self.membersArray) {
                        if ([targetUserID isEqualToString:memberInfoDic[@"_id"]]) {
                            self.memberInfo = memberInfoDic;
                            self.roomInfo = nil;
                            break;
                        }
                    }
                    
                }
                break;
            }
            case 1: {
                NSDictionary *roomDic = [self.roomsArray objectAtIndex:indexPath.row];
                self.roomInfo = roomDic;
                self.memberInfo = nil;
                break;
            }
                
            case 2:{
                NSDictionary *memberDic = [self.membersArray objectAtIndex:indexPath.row];
                self.memberInfo = memberDic;
                self.roomInfo = nil;
                break;
            }
            default:
                break;
        }
    } else {
        switch (indexPath.section) {
            case 0: {
                NSDictionary *roomDic = [self.roomsArray objectAtIndex:indexPath.row];
                self.roomInfo = roomDic;
                self.memberInfo = nil;
                break;
            }
            case 1: {
                NSDictionary *memberDic = [self.membersArray objectAtIndex:indexPath.row];
                self.memberInfo = memberDic;
                self.roomInfo = nil;
                break;
            }
            default:
                break;
        }
    }
}

@end

