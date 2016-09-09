//
//  FavoritesTableViewController.m
//  Talk
//
//  Created by Suric on 15/6/1.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "TBHTTPSessionManager.h"
#import "constants.h"
#import "SVProgressHUD.h"
#import "MTLJSONAdapter.h"
#import "TBMessage.h"
#import "TBUtility.h"
#import "TBSearchMessageCell.h"
#import "TBSearchQuoteCell.h"
#import "UIColor+TBColor.h"
#import "MWPhotoBrowser.h"
#import "AZAPreviewController.h"
#import "AZAPreviewItem.h"
#import "VoicePlayViewController.h"
#import "TBRefreshViewController.h"
#import "MJRefresh.h"
#import "HyperDetailViewController.h"
#import "PlaceHolderView.h"
#import "TBMenuItem.h"
#import "AddTagViewController.h"
#import "TBTag.h"
#import "UIActionSheet+SHActionSheetBlocks.h"
#import "CoreData+MagicalRecord.h"
#import "MOMessage.h"
#import "TBAttachment.h"
#import "ShareToTableViewController.h"
#import "Talk-Swift.h"
#import "MGSwipeButton.h"
#import "JLWebViewController.h"

static NSString *MessageIdentifier = @"TBSearchMessageCell";
static NSString *QuoteCellIdentifier = @"TBSearchQuoteCell";
static NSInteger const limitNum = 20;
static CGFloat const swipeButtonWidth = 60;

@interface FavoritesTableViewController ()<QLPreviewControllerDataSource,QLPreviewControllerDelegate, AZAPreviewControllerDelegate, MWPhotoBrowserDelegate,MGSwipeTableCellDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate>

//navigation items
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelItem;
//toolbar items
@property (weak, nonatomic) IBOutlet UIBarButtonItem *removeItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkItem;

@property (nonatomic) BOOL isSearching;

@property (weak, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UIImageView *noInfoImageView;
@property (weak, nonatomic) IBOutlet UILabel *noReultLabel;
@property (weak, nonatomic) IBOutlet UILabel *notInLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicatorView;

@property (strong, nonatomic) NSMutableArray *allFavoritesArray;
@property (strong, nonatomic) NSMutableArray *photos;
@property (nonatomic) NSInteger photosTotal;
@property (nonatomic) int photosCountInFilesArray;
@property (strong, nonatomic) MWPhotoBrowser *browser;
@property (strong, nonatomic) NSMutableArray *previewItems; //for preview file
//The searchResults array contains the content filtered as a result of a search.
@property (nonatomic) NSMutableArray *searchResults;

@property (strong, nonatomic) PlaceHolderView *noTagsplaceHolder;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableViewController *searchResultController;

@end

@implementation FavoritesTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    if (self.type == JLCategoryTypeTag) {
        self.title = self.tag.tagName;
        self.tableView.tableHeaderView = Nil;
        self.noTagsplaceHolder = (PlaceHolderView *)[[[NSBundle mainBundle]loadNibNamed:@"PlaceHolderView" owner:self options:nil] objectAtIndex:0];
        [self.noTagsplaceHolder setPlaceHolderWithImage:[UIImage imageNamed:@"icon-no-tag"] andTitle:NSLocalizedString(@"No tags", @"No tags") andReminder:NSLocalizedString(@"Long press on message to add tag", @"Long press on message to add tag")];
    } else if (self.type == JLCategoryTypeAt) {
        self.title = NSLocalizedString(@"@Messages", @"@Messages");
        self.tableView.tableHeaderView = Nil;
        self.noTagsplaceHolder = (PlaceHolderView *)[[[NSBundle mainBundle] loadNibNamed:@"PlaceHolderView" owner:self options:nil] objectAtIndex:0];
        [self.noTagsplaceHolder setPlaceHolderWithImage:[UIImage imageNamed:@"icon-no-info"] andTitle:NSLocalizedString(@"No results", @"No results") andReminder:@""];
    } else {
        self.title = NSLocalizedString(@"Favorites", @"Favorites");
        self.editItem.title = NSLocalizedString(@"Select", @"Select");
        self.cancelItem.title = NSLocalizedString(@"Cancel", @"Cancel");
        self.navigationItem.rightBarButtonItem = self.editItem;
    }
    
    //toolbar items
    self.navigationController.toolbar.tintColor = [UIColor blackColor];

    //tableFootView
    self.noReultLabel.text = NSLocalizedString(@"No results", @"No results");
    self.loadingIndicatorView.color = [UIColor grayColor];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelection = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"TBSearchMessageCell" bundle:nil] forCellReuseIdentifier:MessageIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TBSearchQuoteCell" bundle:nil] forCellReuseIdentifier:QuoteCellIdentifier];
    
    [self.searchResultController.tableView registerClass:[TBSearchMessageCell class] forCellReuseIdentifier:MessageIdentifier];
    [self.searchResultController.tableView registerClass:[TBSearchQuoteCell class] forCellReuseIdentifier:QuoteCellIdentifier];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg.png"]];
    
    _photos = [[NSMutableArray alloc]init];
    _photosCountInFilesArray = 0;
    //preview related
    _previewItems = [[NSMutableArray alloc]init];
    _allFavoritesArray = [[NSMutableArray alloc]init];
    _searchResults = [[NSMutableArray alloc]init];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchFavoritesData];
    });
    [self setMJRefresh];
    self.definesPresentationContext = YES;
}

- (UITableViewController *)searchResultController {
    if (!_searchResultController) {
        _searchResultController = [[UITableViewController alloc] init];
        _searchResultController.tableView.delegate = self;
        _searchResultController.tableView.dataSource = self;
        _searchResultController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchResultController.tableView.tableFooterView = [[UIView alloc] init];
    }
    return _searchResultController;
}

- (UISearchController *)searchController {
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultController];
        _searchController.searchResultsUpdater = self;
        _searchController.delegate = self;
        _searchController.searchBar.delegate = self;
        //Customize
        _searchController.searchBar.tintColor = [UIColor jl_redColor];
        _searchController.searchBar.placeholder = NSLocalizedString(@"Search", @"Search");
        UIImage *backgoundImage = [[UIImage imageNamed:@"icon-search-backgound"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_searchController.searchBar setBackgroundImage:backgoundImage];
        _searchController.searchBar.barTintColor = [UIColor tb_shareToSearchBarcolor];
    }
    return _searchController;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)setMJRefresh {
    [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(fetchFavoritesData)];
    // Forbid automatical refresh
    self.tableView.footer.automaticallyRefresh = YES;
    // Set title
    [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateIdle];
    [self.tableView.footer setTitle:NSLocalizedString(@"Loading more items...", @"Loading more items...") forState:MJRefreshFooterStateRefreshing];
    [self.tableView.footer setTitle:NSLocalizedString(@"", @"") forState:MJRefreshFooterStateNoMoreData];
}

- (void)fetchFavoritesData {
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    NSDictionary *params;
    if (self.type == JLCategoryTypeTag) {
        if (self.allFavoritesArray.count == 0) {
            params = @{@"_teamId": currentTeamID,@"limit":[NSNumber numberWithInteger:limitNum],@"_tagId":self.tag.tagId};
        } else {
            TBMessage *lastModel = self.allFavoritesArray.lastObject;
            params = @{@"_teamId": currentTeamID,@"_maxId":lastModel.id,@"limit":[NSNumber numberWithInteger:limitNum],@"_tagId":self.tag.tagId};
        }
        [[TBHTTPSessionManager sharedManager] GET:kMessagesTagsURLString parameters:params
                                          success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                                              [self dealResponseData:responseObject];
                                          } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                              [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed,Please try later", @"Failed,Please try later")];
                                          }];
    } else if (self.type == JLCategoryTypeAt) {
        if (self.allFavoritesArray.count == 0) {
            params = @{@"_teamId": currentTeamID,@"limit":[NSNumber numberWithInteger:limitNum]};
        } else {
            TBMessage *lastModel = self.allFavoritesArray.lastObject;
            params = @{@"_teamId": currentTeamID,@"_maxId":lastModel.id,@"limit":[NSNumber numberWithInteger:limitNum]};
        }
        [[TBHTTPSessionManager sharedManager] GET:kAtMeMessageURLString parameters:params
                                          success:^(NSURLSessionDataTask *task, id responseObject) {
                                              [self dealResponseData:responseObject];
                                          } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                              [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed,Please try later", @"Failed,Please try later")];
                                          }];
    } else {
        if (self.allFavoritesArray.count == 0) {
            params = @{@"_teamId": currentTeamID,@"limit":[NSNumber numberWithInteger:limitNum]};
        } else {
            TBMessage *lastModel = self.allFavoritesArray.lastObject;
            params = @{@"_teamId": currentTeamID,@"_maxId":lastModel.id,@"limit":[NSNumber numberWithInteger:limitNum]};
        }
        [[TBHTTPSessionManager sharedManager] GET:kFavoritesURLString parameters:params
                                          success:^(NSURLSessionDataTask *task, id responseObject) {
                                              [self dealResponseData:responseObject];
                                          } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                              [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed,Please try later", @"Failed,Please try later")];
                                          }];
    }
}

- (void)dealResponseData:(id)responseObject {
    if (self.isSearching) {
        [self.searchResults removeAllObjects];
    }
    
    NSArray *messageJsonArray = (NSArray *)responseObject;
    NSMutableArray *responseArray  = [NSMutableArray array];
    [messageJsonArray enumerateObjectsUsingBlock:^( NSDictionary *messageDictionary, NSUInteger idx, BOOL * _Nonnull stop) {
        TBMessage *message = [MTLJSONAdapter modelOfClass:[TBMessage class] fromJSONDictionary:messageDictionary error:NULL];
        message.originMessageId = messageDictionary[@"_messageId"];
        message.searchCellHeight = [TBSearchMessageCell calculateCellHeightWithMessage:message];
        [responseArray addObject:message];
        if (self.isSearching) {
            [self.searchResults addObject:message];
        } else {
            [self.allFavoritesArray addObject:message];
        }
    }];
    [self fetchPhotos];
    [self setMJRefresh];
    if (responseArray.count < limitNum) {
        [self.tableView.footer noticeNoMoreData];
    }
    
    [self updateEditItem];
    if (self.isSearching) {
        [self.searchResultController.tableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

- (void)fetchPhotos {
    NSArray *modelArray;
    if (self.isSearching) {
        modelArray = self.searchResults;
    } else {
        modelArray = self.allFavoritesArray;
    }
    self.photosCountInFilesArray = 0;
    [self.photos removeAllObjects];
    for (TBMessage *model in modelArray) {
        for (TBAttachment *tempAttchment in model.attachments) {
            NSString *tempFileCategory =  tempAttchment.data[kFileCategory];
            if ([tempFileCategory isEqualToString:kFileCategoryImage]) {
                self.photosCountInFilesArray++;
                if (self.photosCountInFilesArray > self.photos.count) {
                    NSString *fileName = (NSString *)tempAttchment.data[kFileName];
                    NSString *fileDownloadUrlString = (NSString *)tempAttchment.data[kFileDownloadUrl];
                    NSURL *attachmentURL = [NSURL URLWithString:fileDownloadUrlString];
                    MWPhoto *photo = [MWPhoto photoWithURL:attachmentURL];
                    photo.caption = fileName;
                    photo.messageID = model.id;
                    photo.tagsArray = model.tags;
                    [self.photos addObject:photo];
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- IBActions

- (IBAction)editAction:(id)sender {
    [self.tableView setEditing:YES animated:YES];
    [self updateTableViewOffset];

    [self setToolbarItemsEnable:NO];
    self.checkItem.enabled = NO;
    [self updateButtonsToMatchTableState];
}

- (void)setToolbarItemsEnable:(BOOL)enable {
    self.removeItem.enabled = enable;
    self.forwardItem.enabled = enable;
}

- (IBAction)cancelAction:(id)sender {
    [self.tableView setEditing:NO animated:YES];
    [self updateTableViewOffset];

    [self updateButtonsToMatchTableState];
}

- (void)updateTableViewOffset {
    CGFloat currentOffset = self.tableView.contentOffset.y;
    CGFloat searchBarHeight = CGRectGetHeight(self.searchController.searchBar.frame);
    [UIView animateWithDuration:0.6 delay:0.3 usingSpringWithDamping:1.0 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (self.tableView.isEditing) {
            self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, currentOffset + searchBarHeight);
        } else {
            if (currentOffset != -64) {
                self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, currentOffset - searchBarHeight);
            }
        }
    } completion:nil];
}

- (IBAction)deleteAction:(id)sender {
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *deleteArray =[NSMutableArray array];
    NSMutableArray *favoriteIds =[NSMutableArray array];
    for (NSIndexPath *indexPath in selectedRows) {
        TBMessage *model = [self.allFavoritesArray objectAtIndex:indexPath.row];
        [favoriteIds addObject:model.id];
        [deleteArray addObject:model];
    }
    
    [[TBHTTPSessionManager sharedManager] POST:[NSString stringWithFormat:@"%@/%@",kFavoritesURLString,@"batchremove"] parameters:@{@"_favoriteIds": favoriteIds}
                                         success:^(NSURLSessionDataTask *task, id responseObject) {
                                             [self.tableView beginUpdates];
                                             [self.allFavoritesArray removeObjectsInArray:deleteArray];
                                             [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
                                             [self.tableView endUpdates];
                                             
                                             [self cancelAction:nil];
                                             [self updateEditItem];
                                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                             [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failed,Please try later", @"Failed,Please try later")];
                                             [self cancelAction:nil];
                                         }];
    
}

- (void)updateButtonsToMatchTableState
{
    if (self.tableView.editing)
    {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = self.cancelItem;
        [self.navigationController setToolbarHidden:NO animated:YES];
    } else {
        self.title = NSLocalizedString(@"Favorites", @"Favorites");
        self.navigationItem.leftBarButtonItem = self.navigationController.navigationItem.backBarButtonItem;
        if (self.allFavoritesArray.count > 0) {
            self.editItem.enabled = YES;
        } else {
            self.editItem.enabled = NO;
        }
        self.navigationItem.rightBarButtonItem = self.editItem;
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

- (IBAction)removeItemAction:(id)sender {
    UIActionSheet *actionSheet = [UIActionSheet SH_actionSheetWithTitle:NSLocalizedString(@"Sure to Delete", @"Sure to Delete")];
    [actionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Delete", @"Delete") withBlock:^(NSInteger theButtonIndex) {
        [self deleteAction:sender];
    }];
    [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:^(NSInteger theButtonIndex) {
    }];
    [actionSheet showInView:self.view];
}

- (IBAction)forwardItemAction:(id)sender {
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *forwardIds =[NSMutableArray array];
    for (NSIndexPath *indexPath in selectedRows) {
        TBMessage *model = [self.allFavoritesArray objectAtIndex:indexPath.row];
        [forwardIds addObject:model.id];
    }
    [self forwardMessageWithMessageIdArray:forwardIds];
}

- (IBAction)checkItemAction:(id)sender {
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSIndexPath *indexPath = [selectedRows objectAtIndex:0];
    TBMessage *message = [self.allFavoritesArray objectAtIndex:indexPath.row];
    [self cancelAction:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:KEnterChatForSearchMessage object:message];    
}


#pragma mark - Handling long presses

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer {
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
            
            TBMenuItem *copyItem =
            [[TBMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", @"Copy") action:@selector(copyMessage:)];
            copyItem.indexPath = pressedIndexPath;
            
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            TBMessage *message = [self.allFavoritesArray objectAtIndex:pressedIndexPath.row];
            if (self.type == JLCategoryTypeTag) {
                if (message.attachments.count > 0) {
                    menuController.menuItems = @[favoriteItem,tagItem,forwardItem];
                } else {
                    menuController.menuItems = @[copyItem,favoriteItem,tagItem,forwardItem];
                }
            } else {
                if (message.attachments.count > 0) {
                    menuController.menuItems = @[];
                } else {
                    menuController.menuItems = @[copyItem];
                }
            }
            
            CGRect cellRect = [self.tableView rectForRowAtIndexPath:pressedIndexPath];
            cellRect.origin.y += 20.0;
            [menuController setTargetRect:cellRect inView:self.tableView];
            [menuController setMenuVisible:YES animated:YES];
        }
    }
}

- (void)favoriteMenuButtonPressed:(UIMenuController *)menuController {
    TBMenuItem *item = (TBMenuItem *)[[UIMenuController sharedMenuController] menuItems][0];
    if (item.indexPath) {
        TBMessage *messsage = [self.allFavoritesArray objectAtIndex:item.indexPath.row];
        [self favoriteMessageWithID:messsage.id];
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
        TBMessage *messsage = [self.allFavoritesArray objectAtIndex:item.indexPath.row];
        [self addTagWithID:messsage.id withArray:messsage.tags];
    }
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
            TBMessage *messsage = [self.allFavoritesArray objectAtIndex:item.indexPath.row];
            [self deleteMessageWithMessageID:messsage.id andPhotoBrowser:nil];
        }
    }];
    [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:^(NSInteger theButtonIndex) {
    }];
    [actionSheet showInView:self.view];
}

-(void)deleteMessageWithMessageID:(NSString *)deletedMessageID andPhotoBrowser:(MWPhotoBrowser *)browser {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Deleting", @"Deleting")];
    [[TBHTTPSessionManager sharedManager]DELETE:[NSString stringWithFormat:@"%@/%@",kSendMessageURLString,deletedMessageID] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"Success to delete message");
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            MOMessage *moMessage = [MOMessage MR_findFirstByAttribute:@"id" withValue:deletedMessageID inContext:localContext];
            if (moMessage) {
                [moMessage MR_deleteInContext:localContext];
                [[NSNotificationCenter defaultCenter]postNotificationName:kSocketMessageRemove object:deletedMessageID];
            } else {
                DDLogDebug(@"haven't find message");
            }
            [SVProgressHUD dismiss];
        }];
        
        if (browser) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        for (TBMessage *message in self.allFavoritesArray) {
            if ([message.id isEqualToString:deletedMessageID]) {
                NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:[self.allFavoritesArray indexOfObject:message] inSection:0];
                [self.allFavoritesArray removeObject:message];
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

- (void)forwardMenuButtonPressed:(UIMenuController *)menuController {
    TBMenuItem *menuItem = (TBMenuItem *)[[UIMenuController sharedMenuController] menuItems][0];
    if (menuItem.indexPath) {
        TBMessage * tempModel = [self.allFavoritesArray objectAtIndex:menuItem.indexPath.section];
        [self forwardMessageWithMessageIdArray:[NSArray arrayWithObject:tempModel.id]];
    }
}

- (void)forwardMessageWithMessageIdArray:(NSArray *)messageIdArray {
    UINavigationController *shareNavigationController = [[UIStoryboard storyboardWithName:kShareStoryboard bundle:nil] instantiateInitialViewController];
    ShareToTableViewController *shareViewController = [shareNavigationController.viewControllers objectAtIndex:0];
    shareViewController.forwardMessageIdArray = [NSArray arrayWithArray:messageIdArray];
    shareViewController.isFavorite = YES;
    [self presentViewController:shareNavigationController animated:YES completion:nil];
}

- (void)copyMessage:(UIMenuController *)menuController {
    TBMenuItem *item = (TBMenuItem *)[[UIMenuController sharedMenuController] menuItems][0];
    if (item.indexPath) {
        TBMessage *messsage = [self.allFavoritesArray objectAtIndex:item.indexPath.row];
        [[UIPasteboard generalPasteboard] setString:messsage.messageStr];
    }
}

#pragma mark - MGSwipeTableCellDelegate

-(NSArray *) createRoomRightButtons {
    NSMutableArray * buttons = [NSMutableArray array];
    [buttons addObject:[self removeButton]];
    [buttons addObject:[self forwardButton]];
    return buttons;
}

- (MGSwipeButton *)forwardButton {
    NSString *imageString;
    if ([TBUtility systemLanguageIsChinese]) {
        imageString = @"icon-forward-cn";
    } else {
        imageString = @"icon-forward-en";
    }
    MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:imageString] backgroundColor:[UIColor tb_subTextColor] padding:0 callback:^BOOL(MGSwipeTableCell * sender){
        return YES;
    }];
    [button setButtonWidth:swipeButtonWidth];
    return button;
}

- (MGSwipeButton *)removeButton {
    NSString *imageString;
    if ([TBUtility systemLanguageIsChinese]) {
        imageString = @"icon-remove-cn";
    } else {
        imageString = @"icon-remove-en";
    }
    MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:imageString] backgroundColor:[UIColor tb_redColor] padding:0 callback:^BOOL(MGSwipeTableCell * sender){
        return YES;
    }];
    [button setButtonWidth:swipeButtonWidth];
    return button;
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction {
    if (direction == MGSwipeDirectionLeftToRight) {
        return NO;
    } else {
        return YES;
    }
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*)cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    TBMessage *model = [self getModelForIndex:indexPath andTableView:self.tableView];
    if (index == 0) {
        UIActionSheet *actionSheet = [UIActionSheet SH_actionSheetWithTitle:NSLocalizedString(@"Sure to Delete", @"Sure to Delete")];
        [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:^(NSInteger theButtonIndex) {
        }];
        [actionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Delete", @"Delete") withBlock:^(NSInteger theButtonIndex) {
            [self deleteFavoriteWithIndex:indexPath];
        }];
        [actionSheet showInView:self.view];
    } else if (index == 1) {
        [self forwardMessageWithMessageIdArray:[NSArray arrayWithObject:model.id]];
        [cell hideSwipeAnimated:NO];
    }
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchResultController.tableView) {
        return [self.searchResults count];
    } else {
        return self.allFavoritesArray.count;
    }
}

- (TBMessage *)getModelForIndex:(NSIndexPath *)indexPath andTableView:(UITableView *)tableView {
    TBMessage *message;
    if (tableView == self.searchResultController.tableView) {
        message = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        message = [self.allFavoritesArray objectAtIndex:indexPath.row];
    }
    return message;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == JLCategoryTypeFavourite) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBMessage *model = [self getModelForIndex:indexPath andTableView:tableView];
    if (model.attachments.count > 0) {
        TBAttachment *firstAttachment = [model.attachments firstObject];
        TBSearchQuoteCell *cell = [self.tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        [cell setModel:model andAttachemnt:firstAttachment];
        if (cell.longPressRecognizer == nil) {
            UILongPressGestureRecognizer *longPressRecognizer =
            [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            cell.longPressRecognizer = longPressRecognizer;
        }
        if (self.type == JLCategoryTypeFavourite) {
            cell.rightButtons = [self createRoomRightButtons];
        }
        return cell;
    } else {
        //Text message(no attachment)
        TBSearchMessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MessageIdentifier forIndexPath:indexPath];
        cell.delegate = self;
        [cell setModel:model andAttachemnt:nil];
        if (cell.longPressRecognizer == nil) {
            UILongPressGestureRecognizer *longPressRecognizer =
            [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            cell.longPressRecognizer = longPressRecognizer;
        }
        if (self.type == JLCategoryTypeFavourite) {
            cell.rightButtons = [self createRoomRightButtons];
        }
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TBMessage *model = [self getModelForIndex:indexPath andTableView:tableView];
    if (model.displayMode == kDisplayModeMessage) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBMessage *model = [self getModelForIndex:indexPath andTableView:tableView];
    return model.searchCellHeight;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        [self updateTitleAndToolItemsWith:selectedRows];
    }
}

- (void)updateTitleAndToolItemsWith:(NSArray *)selectedRows {
    if (selectedRows.count > 0) {
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Seleted Favorites", @"Seleted Favorites"),[NSString stringWithFormat:@"%lu",(unsigned long)selectedRows.count]];
        [self setToolbarItemsEnable:YES];
    } else {
        self.title = NSLocalizedString(@"Favorites", @"Favorites");
        [self setToolbarItemsEnable:NO];
    }
    self.checkItem.enabled = selectedRows.count == 1 ? YES : NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        [self updateTitleAndToolItemsWith:selectedRows];
        return;
    }
    
    TBMessage *tapModel = [self getModelForIndex:indexPath andTableView:tableView];
    if (tapModel.attachments.count > 0) {
        TBAttachment *attachment = [tapModel.attachments firstObject];
        NSString *category = attachment.category;
        //file
        if ([category isEqualToString:kDisplayModeFile]) {
            NSString *fileCategory = attachment.data[kFileCategory];
            if ([fileCategory isEqualToString:kFileCategoryImage]) {
                self.browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
                self.browser.displayActionButton = YES;
                self.browser.displayNavArrows = NO;
                self.browser.displaySelectionButtons = NO;
                self.browser.zoomPhotosToFill = YES;
                self.browser.alwaysShowControls = NO;
                self.browser.enableGrid = NO;
                self.browser.startOnGrid = NO;
                
                // Optionally set the current visible photo before displaying
                NSArray *modelArray;
                if (self.isSearching) {
                    modelArray = self.searchResults;
                } else {
                    modelArray = self.allFavoritesArray;
                }
                int currentPhotoIndex = -1;
                for (TBMessage *model in modelArray) {
                    BOOL isFound = NO;
                    for (TBAttachment *tempAttchment in model.attachments) {
                        NSString *tempFileCategory =  tempAttchment.data[kFileCategory];
                        if ([tempFileCategory isEqualToString:kFileCategoryImage]) {
                            currentPhotoIndex++;
                            NSString *tempAttachmentKey = (NSString *)tempAttchment.data[kFileKey];
                            NSString *attachmentKey = (NSString *)attachment.data[kFileKey];
                            if ([tempAttachmentKey isEqualToString:attachmentKey]) {
                                isFound = YES;
                                break;
                            }
                        }
                    }
                    if (isFound) {
                        break;
                    }
                }
                [self.browser setCurrentPhotoIndex:currentPhotoIndex];
                [self.navigationController pushViewController:self.browser animated:YES];
                
                // Manipulate
                [self.browser showNextPhotoAnimated:YES];
                [self.browser showPreviousPhotoAnimated:YES];
            } else {
                // Remote files
                NSURL *filePreviewItemURL = [NSURL URLWithString:attachment.data[kFileDownloadUrl]];
                NSString *fileName = attachment.data[kFileName];
                NSString *filekey = attachment.data[kFileKey];
                CGFloat fileSize = [attachment.data[kFileSize] floatValue];
                AZAPreviewItem *filePreviewItem = [AZAPreviewItem previewItemWithURL:filePreviewItemURL
                                                                               title:fileName
                                                                             fileKey:filekey];
                filePreviewItem.fileSize = fileSize;
                [_previewItems removeAllObjects];
                [_previewItems addObjectsFromArray:[NSArray arrayWithObjects:filePreviewItem, nil]];
                // preview controller
                AZAPreviewController *previewController = [[AZAPreviewController alloc] init];
                previewController.navigationController.navigationBar.translucent = NO;
                previewController.dataSource = self;
                previewController.delegate = self;
                [self.navigationController pushViewController:previewController animated:YES];
            }
        }
        // speech
        else if ([category isEqualToString:kDisplayModeSpeech]) {
            [self performSegueWithIdentifier:@"AudioDetails" sender:self];
        }
        // rtf
        else if ([category isEqualToString:kDisplayModeRtf]) {
            [self jumpToQuoteURLWith:attachment];
        }
        //snippet
        else if ([category isEqualToString:kDisplayModeSnippet]) {
            NSString *codeType = attachment.data[kCodeType];
            CodeViewController *codeVC = [[CodeViewController alloc]init];
            codeVC.codeTitle = attachment.data[kQuoteTitle];
            codeVC.language = codeType;
            codeVC.snippet = attachment.data[kQuoteText];
            [self.navigationController pushViewController:codeVC animated:YES];
        }
        //quote
        else if ([category isEqualToString:kDisplayModeQuote]) {
            [self jumpToQuoteURLWith:attachment];
        }
    }
    
    if (self.type == JLCategoryTypeAt) {
        //Enter chat
        TBMessage *message = [self.allFavoritesArray objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:KEnterChatForSearchMessage object:message];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)jumpToQuoteURLWith:(TBAttachment *)attachment {
    NSString *redirectURLString = attachment.data[kQuoteRedirectUrl];
    if (redirectURLString) {
        JLWebViewController *jsViewController = [[JLWebViewController alloc]init];
        jsViewController.hidesBottomBarWhenPushed = YES;
        jsViewController.urlString = redirectURLString;
        [self.navigationController pushViewController:jsViewController animated:YES];
    }
    else {
        NSString *quoteText = attachment.data[kQuoteText];
        HyperDetailViewController *hyperDeatailVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"HyperDetailViewController"];
        hyperDeatailVC.hyperString = quoteText;
        [self.navigationController pushViewController:hyperDeatailVC animated:YES];
    }
}

- (void)deleteFavoriteWithIndex:(NSIndexPath *)indexPath {
    TBMessage *tapModel = [self.allFavoritesArray objectAtIndex:indexPath.row];
    [[TBHTTPSessionManager sharedManager] DELETE:[NSString stringWithFormat:@"%@/%@",kFavoritesURLString,tapModel.id] parameters:nil
                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 [self.allFavoritesArray removeObjectAtIndex:indexPath.row];
                                                 [self.tableView beginUpdates];
                                                 [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                 [self.tableView endUpdates];
                                                 
                                                 [self updateEditItem];
                                             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                 [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed,Please try later", @"Failed,Please try later")];
                                             }];
    
}

- (void)updateEditItem {
    if (self.allFavoritesArray.count == 0) {
        self.editItem.enabled  = NO;
        self.tableView.tableHeaderView = nil;
        self.loadingIndicatorView.hidden = YES;
        if (self.type == JLCategoryTypeFavourite) {
            self.noReultLabel.text = NSLocalizedString(@"No favorites", @"No favorites");
            self.notInLabel.text = NSLocalizedString(@"Add favorites", @"Add favorites");
            self.tableView.tableFooterView = self.footView;
        } else {
           self.tableView.tableFooterView = self.noTagsplaceHolder;
        }
        [self.tableView.footer setTitle:@"" forState:MJRefreshFooterStateNoMoreData];
    }
    else {
        if (!self.isSearching) {
            self.tableView.tableHeaderView = self.searchController.searchBar;
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AudioDetails"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        TBMessage *tapMessage = [self.allFavoritesArray objectAtIndex:selectedIndexPath.row];
        VoicePlayViewController *voicePlayController = segue.destinationViewController;
        voicePlayController.message =tapMessage;
    }
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return [self.previewItems count];
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.previewItems[index];
}

#pragma mark - AZAPreviewControllerDelegate

- (void)AZA_previewController:(AZAPreviewController *)controller failedToLoadRemotePreviewItem:(id<QLPreviewItem>)previewItem withError:(NSError *)error {
    NSString *alertTitle = NSLocalizedString(@"Failed to load", @"Failed to load");
    NSString *alertMessage = [error localizedDescription];
    [[[UIAlertView alloc] initWithTitle:alertTitle
                                message:alertMessage
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                      otherButtonTitles:nil] show];
    [UIColor colorWithRed:0.5 green:0.3 blue:0.8 alpha:1];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count)
        return [self.photos objectAtIndex:index];
    return nil;
}

- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
    return nil;
}

- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
    MWPhoto *photo =[_photos objectAtIndex:index];
    return photo.caption;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
    if (index == self.photos.count - 1 && self.photosTotal != self.photos.count) {
        [self loadMoreImage];
        self.browser.needToReload = YES;
    }
}

- (void)loadMoreImage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *teamID = [defaults valueForKey:kCurrentTeamID];
    unsigned long photosPage = self.photos.count/10 + 1;
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:kFavoritesSearchURLString parameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                              teamID,@"_teamId",
                                              @"file",@"type",
                                              @"image",@"fileCategory",
                                              [[NSString alloc] initWithFormat:@"%lul",photosPage],@"page",
                                              [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"desc",@"order", nil],@"favoritedAt", nil],@"sort",
                                              nil] success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogVerbose(@"response data: %@", responseObject);
        [self processImageData:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"error: %@", error.localizedRecoverySuggestion);
    }];
}

- (void)processImageData:(NSDictionary *)responseObject {
    self.photosTotal = [(NSNumber *)[responseObject objectForKey:@"total"] integerValue];
    NSArray *responseFileArray = (NSArray *)[responseObject objectForKey:@"favorites"];
    for (int i = self.photos.count%10; i < responseFileArray.count; i++) {
        TBMessage *fileMessage = [MTLJSONAdapter modelOfClass:[TBMessage class]
                                           fromJSONDictionary:responseFileArray[i]
                                                        error:NULL];
        for (TBAttachment *tempAttchment in fileMessage.attachments) {
            NSString *fileName = (NSString *)tempAttchment.data[kFileName];
            NSString *fileDownloadUrlString = (NSString *)tempAttchment.data[kFileDownloadUrl];
            NSURL *attachmentURL = [NSURL URLWithString:fileDownloadUrlString];
            MWPhoto *photo = [MWPhoto photoWithURL:attachmentURL];
            photo.messageID = fileMessage.id;
            photo.creatorID = fileMessage.creatorID;
            photo.caption = fileName;
            photo.tagsArray = fileMessage.tags;
            [self.photos addObject:photo];
        }
    }
    [self.browser setContenSizeWithNumber:self.photos.count];
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    self.isSearching = YES;
    [self.searchResults removeAllObjects];
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
- (void)didDismissSearchController:(UISearchController *)searchController {
    self.isSearching = NO;
    [self fetchPhotos];
    [self setMJRefresh];
}


#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.searchResults removeAllObjects];
    self.searchResultController.tableView.tableFooterView = [[UIView alloc]init];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.001);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (UIView * subview in self.searchResultController.tableView.subviews) {
            if ([subview isKindOfClass: [UILabel class]])
            {
                subview.hidden = YES;
            }
        }
    });
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.type == JLCategoryTypeTag) {
        [self searchTagsWithKey:searchBar.text];
    } else if (self.type == JLCategoryTypeAt) {
        [self searchAtWithKey:searchBar.text];
    } else {
        [self searchFavotiresWithKey:searchBar.text];
    }
}

- (void)searchFavotiresWithKey:(NSString *)key {
    [self startSearchLoadingWithisStart:YES];
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    [[TBHTTPSessionManager sharedManager] POST:[NSString stringWithFormat:@"%@/%@",kFavoritesURLString,@"search"] parameters:@{@"_teamId": currentTeamID,@"q": key}
                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                          NSArray *responseArray = (NSArray *)[responseObject objectForKey:@"favorites"];
                                          DDLogDebug(@"search favorite count: %lu",(unsigned long)responseArray.count);
                                          [self startSearchLoadingWithisStart:NO];
                                          [self dealResponseData:responseArray];
                 
                                          if (responseArray.count == 0) {
                                              self.noReultLabel.text = NSLocalizedString(@"No results", @"No results");
                                              self.searchResultController.tableView.tableFooterView = self.footView;
                                              self.notInLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Search no in favorites", @"Search no in favorites"),key];
                                          }
                                      } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                          [self startSearchLoadingWithisStart:NO];
                                          [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failed,Please try later", @"Failed,Please try later")];
                                      }];

}

-(void)searchTagsWithKey:(NSString *)key {
    [self startSearchLoadingWithisStart:YES];
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    NSDictionary *params = @{@"_teamId": currentTeamID,@"_tagId":self.tag.tagId, @"q": key};
    [[TBHTTPSessionManager sharedManager] GET:kSearchURLString parameters:params
                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                          NSArray *responseArray = (NSArray *)[responseObject valueForKey:@"messages"];
                                          DDLogDebug(@"search taged message count: %lu",(unsigned long)responseArray.count);
                                          [self startSearchLoadingWithisStart:NO];
                                          [self dealResponseData:responseArray];
                                          
                                          if (responseArray.count == 0) {
                                              self.noReultLabel.text = NSLocalizedString(@"No results", @"No results");
                                              self.searchResultController.tableView.tableFooterView = self.footView;
                                              self.notInLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Search no in tag", @"Search no in tag"),key];
                                          }
                                      } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                          [self startSearchLoadingWithisStart:NO];
                                          [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failed,Please try later", @"Failed,Please try later")];
                                      }];
}

-(void)searchAtWithKey:(NSString *)key {
    [self startSearchLoadingWithisStart:YES];
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    NSDictionary *params = @{@"_teamId": currentTeamID, @"q": key};
    [[TBHTTPSessionManager sharedManager] GET:kSearchURLString parameters:params
                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                          NSArray *responseArray = (NSArray *)[responseObject valueForKey:@"messages"];
                                          DDLogDebug(@"search at message count: %lu",(unsigned long)responseArray.count);
                                          [self startSearchLoadingWithisStart:NO];
                                          [self dealResponseData:responseArray];
                                          
                                          if (responseArray.count == 0) {
                                              self.noReultLabel.text = NSLocalizedString(@"No results", @"No results");
                                              self.searchResultController.tableView.tableFooterView = self.footView;
                                              self.notInLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Search no in @", @"Search no in @"),key];
                                          }
                                      } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                          [self startSearchLoadingWithisStart:NO];
                                          [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Failed,Please try later", @"Failed,Please try later")];
                                      }];
}

- (void)startSearchLoadingWithisStart:(BOOL)isStart {
    self.noInfoImageView.hidden = isStart;
    self.noReultLabel.hidden = isStart;
    self.notInLabel.hidden = isStart;
    self.loadingIndicatorView.hidden = !isStart;
    if (isStart) {
        self.searchResultController.tableView.tableFooterView = self.footView;
        [self.loadingIndicatorView startAnimating];
    } else {
        self.searchResultController.tableView.tableFooterView = [[UIView alloc]init];
        [self.loadingIndicatorView stopAnimating];
    }
}

@end
