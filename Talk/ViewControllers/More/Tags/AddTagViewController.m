//
//  AddTagViewController.m
//  Talk
//
//  Created by 史丹青 on 7/13/15.
//  Copyright (c) 2015 jiaoliao. All rights reserved.
//

#import "AddTagViewController.h"
#import "ReactiveCocoa.h"
#import "TBTag.h"
#import "TBAddTagCell.h"
#import "UIColor+TBColor.h"
#import "SVProgressHUD.h"
#import "TBMessage.h"
#import "constants.h"

#define TokenFieldMaxHeight    150.0
#define CommonMargin            14.0

@interface AddTagViewController ()

@property (strong, nonatomic) NSMutableArray *allTVENokenArray;

@end

@implementation AddTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindViewModel];
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)addTagToMessage:(id)sender {
    [[self.viewModel addTagToMessage] subscribeNext:^(TBMessage *tagMessage) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Succeed", @"Succeed")];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddTagSucceedNotification object:tagMessage];
        [self.navigationController  popViewControllerAnimated:YES];
    } error:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

#pragma mark - Private

- (void)bindViewModel {
    self.title = self.viewModel.title;
    
    [[self.viewModel fetchAllTags] subscribeNext:^(id x) {
        [self.tagTableView reloadData];
        for (int i = 0; i < self.viewModel.tags.count; i++) {
            TBTag *tag = self.viewModel.tags[i];
            if (tag.isSelected) {
                VENToken *tempToken = [[VENToken alloc] initWithIsTag:YES];
                tempToken.tokenText = tag.tagName;
                tempToken.indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.allTVENokenArray addObject:tempToken];
            }
        }
        [self reloadTokenField];
    } error:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)commonInit {
    self.tagTableView.dataSource = self;
    self.tagTableView.delegate = self;
    [self.tagTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    self.tagField.isTag = YES;
    self.tagField.delegate = self;
    self.tagField.dataSource = self;
    self.tagField.placeholderText = NSLocalizedString(@"Add tag", @"Add tag");
    self.tagField.toLabelText = @"";
    [self.tagField setColorScheme:[UIColor jl_redColor]];
    self.allTVENokenArray = [NSMutableArray array];
    
    UIBarButtonItem *DoneItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"Save") style:UIBarButtonItemStylePlain target:self action:@selector(addTagToMessage:)];
    self.navigationItem.rightBarButtonItem = DoneItem;
}

#pragma mark - UITableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBAddTagCell *cell = [self.tagTableView dequeueReusableCellWithIdentifier:@"tagCell"];
    TBTag *tag = self.viewModel.tags[indexPath.row];
    [cell setupCellWithTagName:tag.tagName isSelected:tag.isSelected];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TBTag *tag = self.viewModel.tags[indexPath.row];
    if (tag.isSelected) {
        ((TBTag *)self.viewModel.tags[indexPath.row]).isSelected = NO;
        if ([self.viewModel.selectedTags containsObject:tag]) {
            [self.viewModel.selectedTags removeObject:tag];
        }
        NSInteger indexForCell = 0;
        for (VENToken *tempToken in self.allTVENokenArray) {
            if (tempToken.indexPath.section == indexPath.section && tempToken.indexPath.row == indexPath.row) {
                indexForCell =[self.allTVENokenArray indexOfObject:tempToken];
                break;
            }
        }
        [self tokenField:self.tagField didDeleteTokenAtIndex:indexForCell];
        
    } else {
        ((TBTag *)self.viewModel.tags[indexPath.row]).isSelected = YES;
        [self.viewModel.selectedTags addObject:self.viewModel.tags[indexPath.row]];
        VENToken *tempToken = [[VENToken alloc]init];
        tempToken.tokenText = tag.tagName;
        tempToken.indexPath = indexPath;
        tempToken.isTag = YES;
        [self.allTVENokenArray addObject:tempToken];
    }
    [self reloadTokenField];
    [self.tagTableView reloadData];
}

#pragma mark - VENTokenFieldDelegate

- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text
{
    [[self.viewModel addNewTag:text] subscribeNext:^(id x) {
        VENToken *tempToken = [[VENToken alloc]init];
        tempToken.tokenText = text;
        tempToken.indexPath = [NSIndexPath indexPathForRow:self.viewModel.tags.count-1 inSection:0];
        [self.allTVENokenArray addObject:tempToken];
        [self reloadTokenField];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.tagTableView reloadData];
    } error:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

//reload tokenField for data updating
-(void)reloadTokenField
{
    [self.tagField reloadData];
    
    CGFloat tempScrollViewHeight = self.tagField.scrollView.contentSize.height>=TokenFieldMaxHeight ?TokenFieldMaxHeight:self.tagField.scrollView.contentSize.height;
    self.tokenFieldHeightConstraint.constant = tempScrollViewHeight + CommonMargin;
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.7
                        options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:NULL];
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index
{
    VENToken *deleteToken = [self.allTVENokenArray objectAtIndex:index];
    if (deleteToken.indexPath) {
        TBTag *tag = self.viewModel.tags[deleteToken.indexPath.row];
        for (TBTag *selectedTag in self.viewModel.selectedTags) {
            if ([selectedTag.id isEqualToString:tag.id]) {
                [self.viewModel.selectedTags removeObject:selectedTag];
                break;
            }
        }
        ((TBTag *)self.viewModel.tags[deleteToken.indexPath.row]).isSelected = NO;
        [self.tagTableView reloadData];
    }
    [self.allTVENokenArray removeObjectAtIndex:index];
    [self reloadTokenField];
}

#pragma mark - VENTokenFieldDataSource

- (VENToken *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index
{
    return self.allTVENokenArray[index];
}

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField
{
    return [self.allTVENokenArray count];
}

- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField
{
    return [NSString stringWithFormat:@"%tu people", [self.allTVENokenArray count]];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
