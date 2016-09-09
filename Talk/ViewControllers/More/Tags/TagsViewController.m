//
//  TagsViewController.m
//  Talk
//
//  Created by 史丹青 on 7/13/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "TagsViewController.h"
#import "ReactiveCocoa.h"
#import "PlaceHolderView.h"
#import "TBTag.h"
#import "FavoritesTableViewController.h"
#import "UIActionSheet+SHActionSheetBlocks.h"
#import "MSCMoreOptionTableViewCell.h"
#import "ChangeNameViewController.h"
#import "constants.h"
#import "SVProgressHUD.h"
#import "TBUtility.h"

@interface TagsViewController () <MSCMoreOptionTableViewCellDelegate>

@property (strong, nonatomic) PlaceHolderView *noTagsplaceHolder;

@end

@implementation TagsViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindViewModel];
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private

- (void)bindViewModel {
    self.viewModel = [[TagsViewModel alloc] init];
    self.title = self.viewModel.title;
    [RACObserve(self.viewModel, tags) subscribeNext:^(NSArray *newTags) {
        if (newTags.count == 0) {
            self.tableView.tableFooterView = self.noTagsplaceHolder;
        } else {
            [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        }
        [self.tableView reloadData];
    }];
    
}

- (void)commonInit {
    self.noTagsplaceHolder = (PlaceHolderView *)[[[NSBundle mainBundle]loadNibNamed:@"PlaceHolderView" owner:self options:nil] objectAtIndex:0];
    [self.noTagsplaceHolder setPlaceHolderWithImage:[UIImage imageNamed:@"icon-no-tag"] andTitle:NSLocalizedString(@"No tags", @"No tags") andReminder:NSLocalizedString(@"Long press on message to add tag", @"Long press on message to add tag")];
    
    [self fetchAllTags];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTags:) name:kEditTagSuccessNotification object:Nil];
}

- (void)refreshTags:(NSNotification *)notification {
    [self fetchAllTags];
}

- (void) fetchAllTags {
    //[SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
    [[self.viewModel fetchAllTags] subscribeNext:^(id x) {
        //[SVProgressHUD dismiss];
    } error:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.viewModel.tags.count == 0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return self.viewModel.tags.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 1.0f;
    return 32.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSCMoreOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tagCell" forIndexPath:indexPath];
    cell.delegate = self;
    [cell setConfigurationBlock:^(UIButton *deleteButton, UIButton *moreOptionButton, CGFloat *deleteButtonWitdh, CGFloat *moreOptionButtonWidth) {
        
        moreOptionButton.backgroundColor = [UIColor lightGrayColor];
        [moreOptionButton setTitle:NSLocalizedString(@"Edit", @"Edit") forState:UIControlStateNormal];
        
        deleteButton.backgroundColor = [UIColor orangeColor];
        [deleteButton setTitle:NSLocalizedString(@"Delete", @"Delete") forState:UIControlStateNormal];
    }];
    TBTag *tag;
    tag = self.viewModel.tags[indexPath.row];
    cell.textLabel.text = tag.tagName;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIActionSheet *deleteActionSheet = [UIActionSheet SH_actionSheetWithTitle:NSLocalizedString(@"Sure to delete tag?", @"Sure to delete tag?")];
    [deleteActionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Sure", @"Sure") withBlock:^(NSInteger theButtonIndex) {
        //delete tag
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
        [[self.viewModel deleteTag:self.viewModel.tags[indexPath.row]] subscribeNext:^(id x) {
            [self fetchAllTags];
        } error:^(NSError *error) {
            NSString *errorCode = [TBUtility getApiErrorCodeWithError:error];
            if ([errorCode isEqualToString:@"403219"]) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"You have no permission to delete this tag", @"You have no permission to delete this tag")];
            } else {
                [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
            }
        }];
    }];
    [deleteActionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:^(NSInteger theButtonIndex) {
        [self.tableView setEditing:NO animated:YES];
    }];
    [deleteActionSheet showInView:self.view];
}


#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Delete", @"Delete");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoritesTableViewController *tagListVC = [[UIStoryboard storyboardWithName:@"Favorites" bundle:nil] instantiateViewControllerWithIdentifier:@"FavoritesTableViewController"];
    tagListVC.type = JLCategoryTypeTag;
    tagListVC.tag = self.viewModel.tags[indexPath.row];
    [self.navigationController pushViewController:tagListVC animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MSCMoreOptionTableViewCellDelegate

- (void)tableView:(UITableView *)tableView moreOptionButtonPressedInRowAtIndexPath:(NSIndexPath *)indexPath {
    // Called when 'more' button is pushed.
    DDLogDebug(@"MORE button pressed in row at: %@", indexPath.description);
    //[self moreActionsForMessageWithIndex:indexPath];
    TBTag *tag = self.viewModel.tags[indexPath.row];
    ChangeNameViewController *editTagViewController = [[UIStoryboard storyboardWithName:kMeInfoStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"ChangeNameViewController"];
    editTagViewController.name = tag.tagName;
    editTagViewController.tagId = tag.tagId;
    editTagViewController.isEditTag = YES;
    editTagViewController.title = NSLocalizedString(@"Edit tag", @"Edit tag");
    [self.navigationController pushViewController:editTagViewController animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForMoreOptionButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"More", @"More");
}

@end
