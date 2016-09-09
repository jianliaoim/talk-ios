//
//  TBItemsTableViewController.m
//  Talk
//
//  Created by 史丹青 on 8/10/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "TBItemsTableViewController.h"
#import "constants.h"
#import "TBMenuItem.h"
#import "TBMessage.h"
#import "AddTagViewController.h"
#import "TBTag.h"
#import "UIActionSheet+SHActionSheetBlocks.h"
#import "TBHTTPSessionManager.h"
#import "SVProgressHUD.h"
#import "TBUtility.h"
#import "MWPhotoBrowser.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "MOMessage.h"
#import "MJRefresh.h"
#import "ShareToTableViewController.h"

@interface TBItemsTableViewController ()

@end

@implementation TBItemsTableViewController

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"TBSearchQuoteCell" bundle:nil] forCellReuseIdentifier:QuoteCellIdentifier];
    
    //placeHolderView
    _noItemsplaceHolder = (PlaceHolderView *)[[[NSBundle mainBundle]loadNibNamed:@"PlaceHolderView" owner:self options:nil] objectAtIndex:0];
    [_noItemsplaceHolder setPlaceHolderWithImage:[UIImage imageNamed:@"icon-no-items"] andTitle:NSLocalizedString(@"NO content", @"NO content") andReminder:NSLocalizedString(@"NO data reminder", @"NO data reminder")];
    
    self.messagesArray = [[NSMutableArray alloc]init];
    self.pageNumber = 1;
    
    [self setExtraCellLineHidden:self.tableView];
    [self setMJRefresh];
    [self.tableView.footer beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public

- (void)filterDataWith:(NSDictionary *)newFilterDictionary {
    self.pageNumber = 1;
    self.filterDictionary = newFilterDictionary;
    [self.messagesArray removeAllObjects];
    
    [self syncData];
}

#pragma mark - syncData

- (void)syncData {
    //syncData
}

- (void)processResponseData:(NSDictionary *)responseObject {
    NSArray *responseArray = (NSArray *)[responseObject objectForKey:@"messages"];
    for (int i = 0; i < responseArray.count; i++) {
        TBMessage *message = [MTLJSONAdapter modelOfClass:[TBMessage class]
                                           fromJSONDictionary:responseArray[i]
                                                        error:NULL];
        message.searchCellHeight = [TBSearchMessageCell calculateCellHeightWithMessage:message];
        [self.messagesArray addObject:message];
    }
    self.messagesTotal = [(NSNumber *)[responseObject objectForKey:@"total"] integerValue];
    
    [self setMJRefresh];
    if (self.messagesTotal/10 < self.pageNumber) {
        [self.tableView.footer noticeNoMoreData];
    }
    self.pageNumber++;
    [self.tableView reloadData];
    
    if (self.messagesArray.count == 0) {
        self.tableView.tableFooterView = self.noItemsplaceHolder;
        [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateNoMoreData];
    } else {
        self.tableView.tableFooterView = [[UIView alloc]init];
        [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateNoMoreData];
    }
}


#pragma mark - MJrefresh

- (void)setMJRefresh {
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(syncData)];
    // Forbid automatical refresh
    self.tableView.footer.automaticallyRefresh = YES;
    // Set title
    [self.tableView.footer setTitle:NSLocalizedString(@"Load more", @"Load more") forState:MJRefreshFooterStateIdle];
    [self.tableView.footer setTitle:NSLocalizedString(@"Loading more items...", @"Loading more items...") forState:MJRefreshFooterStateRefreshing];
    [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateNoMoreData];
}

#pragma mark - Handling long presses

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer {
    
    /*
     For the long press, the only state of interest is Began.
     When the long press is detected, find the index path of the row (if there is one) at press location.
     If there is a row at the location, create a suitable menu controller and display it.
     */
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        
        NSIndexPath *pressedIndexPath =
        [self.tableView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.tableView]];
        
        if (pressedIndexPath && (pressedIndexPath.row != NSNotFound) && (pressedIndexPath.section != NSNotFound)) {
            
            [self becomeFirstResponder];
            TBMenuItem *favoriteItem =
            [[TBMenuItem alloc] initWithTitle:NSLocalizedString(@"Favorite", @"Favorite") action:@selector(favoriteMenuButtonPressed:)];
            favoriteItem.indexPath = pressedIndexPath;
            
            TBMenuItem *tagItem =
            [[TBMenuItem alloc] initWithTitle:NSLocalizedString(@"Add tag", @"Add tag") action:@selector(addTagButtonPressed:)];
            tagItem.indexPath = pressedIndexPath;
            
            TBMenuItem *forwardItem =
            [[TBMenuItem alloc] initWithTitle:NSLocalizedString(@"Forward", @"Forward") action:@selector(forwardMenuButtonPressed:)];
            forwardItem.indexPath = pressedIndexPath;
            
            TBMenuItem *deleteItem =
            [[TBMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"Delete") action:@selector(deleteMenuButtonPressed:)];
            deleteItem.indexPath = pressedIndexPath;
            
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            
            NSString *currentID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
            TBMessage *model = [self.messagesArray objectAtIndex:pressedIndexPath.row];
            if ([model.creatorID isEqualToString:currentID] ||  [TBUtility isManagerForCurrentAccount]) {
                menuController.menuItems = @[favoriteItem,tagItem,forwardItem,deleteItem];
            } else {
                menuController.menuItems = @[favoriteItem,tagItem,forwardItem];
            }
            
            CGRect cellRect = [self.tableView rectForRowAtIndexPath:pressedIndexPath];
            // lower the target rect a bit (so not to show too far above the cell's bounds)
            cellRect.origin.y += 20.0;
            [menuController setTargetRect:cellRect inView:self.tableView];
            [menuController setMenuVisible:YES animated:YES];
        }
    }
}

- (void)favoriteMenuButtonPressed:(UIMenuController *)menuController {
    TBMenuItem *item = (TBMenuItem *)[[UIMenuController sharedMenuController] menuItems][0];
    if (item.indexPath) {
        TBMessage *model = [self.messagesArray objectAtIndex:item.indexPath.row];
        [self favoriteMessageWithID:model.id];
    }
}

- (void)favoriteMessageWithID:(NSString *)messageID {
    [[TBHTTPSessionManager sharedManager] POST:kFavoritesURLString parameters:@{@"_messageId": messageID} success:^(NSURLSessionDataTask *task, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Added", @"Added")];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failed,Please try later", @"Failed,Please try later")];
    }];
}

- (void)addTagButtonPressed:(UIMenuController *)menuController {
    TBMenuItem *item = (TBMenuItem *)[[UIMenuController sharedMenuController] menuItems][0];
    if (item.indexPath) {
        TBMessage *model = [self.messagesArray objectAtIndex:item.indexPath.row];
        [self addTagWithID:model.id withArray:model.tags];
    }
}

- (void)forwardMenuButtonPressed:(UIMenuController *)menuController {
    TBMenuItem *menuItem = (TBMenuItem *)[[UIMenuController sharedMenuController] menuItems][0];
    if (menuItem.indexPath) {
        TBMessage * tempModel = [self.messagesArray objectAtIndex:menuItem.indexPath.row];
        [self forwardMessageWithMessageIdArray:[NSArray arrayWithObject:tempModel.id]];
    }
}

- (void)forwardMessageWithMessageIdArray:(NSArray *)messageIdArray {
    UINavigationController *shareNavigationController = [[UIStoryboard storyboardWithName:kShareStoryboard bundle:nil] instantiateInitialViewController];
    ShareToTableViewController *shareViewController = [shareNavigationController.viewControllers objectAtIndex:0];
    shareViewController.forwardMessageIdArray = [NSArray arrayWithArray:messageIdArray];
    [self presentViewController:shareNavigationController animated:YES completion:nil];
}

- (void)addTagWithID:(NSString *)messageID withArray:(NSArray *)tags {
    AddTagViewController *addTagVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"AddTagViewController"];
    addTagVC.viewModel = [[AddTagViewModel alloc] init];
    addTagVC.viewModel.messageId = messageID;
    NSArray *tbTagsArray = [MTLJSONAdapter modelsOfClass:[TBTag class] fromJSONArray:tags error:NULL];
    [addTagVC.viewModel.selectedTags addObjectsFromArray:tbTagsArray];
    [self.navigationController pushViewController:addTagVC animated:YES];
}

- (void)deleteMenuButtonPressed:(UIMenuController *)menuController {
    UIActionSheet *actionSheet = [UIActionSheet SH_actionSheetWithTitle:NSLocalizedString(@"Sure to Delete", @"Sure to Delete")];
    [actionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Delete", @"Delete") withBlock:^(NSInteger theButtonIndex) {
        TBMenuItem *item = (TBMenuItem *)[[UIMenuController sharedMenuController] menuItems][0];
        if (item.indexPath) {
            TBMessage *model = [self.messagesArray objectAtIndex:item.indexPath.row];
            [self deleteMessageWithMessageID:model.id andPhotoBrowser:nil];
        }
    }];
    [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:^(NSInteger theButtonIndex) {
    }];
    [actionSheet showInView:self.view];
}

-(void)deleteMessageWithMessageID:(NSString *)deletedMessageID andPhotoBrowser:(MWPhotoBrowser *)browser
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Deleting", @"Deleting")];
    [[TBHTTPSessionManager sharedManager]DELETE:[NSString stringWithFormat:@"%@/%@",kSendMessageURLString,deletedMessageID] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Success to delete message");
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            MOMessage *moMessage = [MOMessage MR_findFirstByAttribute:@"id" withValue:deletedMessageID inContext:localContext];
            if (moMessage) {
                [moMessage MR_deleteInContext:localContext];
                [[NSNotificationCenter defaultCenter]postNotificationName:kSocketMessageRemove object:deletedMessageID];
            }
            else{
                DDLogDebug(@"haven't find message");
            }
            [SVProgressHUD dismiss];
        }];
        
        if (browser) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        for (TBMessage *model in self.messagesArray) {
            if ([model.id isEqualToString:deletedMessageID]) {
                NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:[self.messagesArray indexOfObject:model] inSection:0];
                [self.messagesArray removeObject:model];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:deleteIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
                
                break;
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Fail to delete message");
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
    
}

#pragma mark - Tableview data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.messagesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBMessage *model = self.messagesArray[indexPath.row];
    return  model.searchCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBSearchQuoteCell *cell = [tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier forIndexPath:indexPath];
    TBMessage *linkMessageModel = self.messagesArray[indexPath.row];
    TBAttachment *firstAttachment = [linkMessageModel.attachments firstObject];
    [cell setModel:linkMessageModel andAttachemnt:firstAttachment];
    if (cell.longPressRecognizer == nil) {
        UILongPressGestureRecognizer *longPressRecognizer =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        cell.longPressRecognizer = longPressRecognizer;
    }
    
    return cell;
}

- (void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}


@end
