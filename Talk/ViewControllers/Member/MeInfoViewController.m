//
//  MeInfoViewController.m
//  Talk
//
//  Created by Shire on 9/29/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import "SVProgressHUD.h"
#import "MeInfoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ChangeNameViewController.h"
#import "constants.h"
#import "TBHTTPSessionManager.h"
#import "UIActionSheet+SHActionSheetBlocks.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "UIColor+TBColor.h"
#import <MessageUI/MessageUI.h>
#import "TBUtility.h"

#import "TBUser.h"
#import "MOUser.h"
#import "UIAlertView+Blocks.h"
#import "TBSocketManager.h"
#import "MOTeam.h"
#import "TBPersonInfoCell.h"
#import "AppSettingViewController.h"
#import "JLTeamHeaderView.h"

@interface MeInfoViewController () <UIActionSheetDelegate,MFMailComposeViewControllerDelegate>
{
    UIWebView *phoneCallWebView;          //use for call
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *managingActionView;
@property (weak, nonatomic) IBOutlet UIButton *enterConversationBtn;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;

@property (strong, nonatomic) JLTeamHeaderView *header;
@property (strong, nonatomic) UIView *fakeNavigationBar;
@property (strong, nonatomic) MOTeam *currentTeam;

@end

static NSString *const cellIdentifier = @"TBPersonInfoCell";
static CGFloat const TableViewHeaderHeight = 200;
static CGFloat const DefaultSectionHeaderHeight = 20;

@implementation MeInfoViewController

#pragma mark - viewLifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.header = [[JLTeamHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), TableViewHeaderHeight)];
    self.header.backgroudImageView.image = [UIImage imageNamed:@"drawer-header"];
    [self.tableView setTableHeaderView:self.header];
    [self.tableView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    [self.editProfileButton setTitle:NSLocalizedString(@"Edit profile", @"Edit profile") forState:UIControlStateNormal];
    self.editProfileButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.editProfileButton];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.editProfileButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.editProfileButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.editProfileButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-20]];
    
    self.title = NSLocalizedString(@"Profile", @"Profile");
    [self commonInit];
    [self setupNavbarButtons];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.tableView && [keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
        CGPoint offsetOld = [change[NSKeyValueChangeOldKey] CGPointValue];
        if (CGPointEqualToPoint(offset, offsetOld)) {
            return;
        }
        self.header.currentHeight = TableViewHeaderHeight - offset.y;
        if (offset.y > 0) {
            CGPoint titleCenter = [self.navigationController.view convertPoint:self.header.titleLabel.center fromView:self.header];
            if (titleCenter.y <= 42) {
                self.navigationItem.title = self.header.titleLabel.text;
                self.header.titleLabel.hidden = YES;
            } else {
                self.navigationItem.title = nil;
                self.header.titleLabel.hidden = NO;
            }
            CGRect backgroud = [self.navigationController.view convertRect:self.header.backgroudImageView.frame fromView:self.header];
            if (CGRectGetMaxY(backgroud) <= 64) {
                if (self.navigationController.navigationBarHidden) {
                    [self.navigationController setNavigationBarHidden:NO animated:NO];
                }
            } else {
                [self.navigationController setNavigationBarHidden:YES animated:NO];
            }
        }
    }
}

- (UIImage *)captureBackgroudImage {
    if (!self.header.backgroudImageView.image) {
        return nil;
    }
    CGRect rect = [self.header.backgroudImageView bounds];
    CGRect interestRect = CGRectMake(0, rect.size.height -64, rect.size.width, 64);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.header.backgroudImageView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageToSplitCG = image.CGImage;
    CGImageRef partOfImageCG = CGImageCreateWithImageInRect(imageToSplitCG, interestRect);
    UIImage *partOfImage = [UIImage imageWithCGImage:partOfImageCG];
    
    return partOfImage;
}

- (void)setupNavbarButtons {
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back") style:UIBarButtonItemStylePlain target:nil action:nil];
    
    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.navigationController.navigationBar.frame) + 20);
    UIView *fakeNavigationBar = [[UIView alloc] initWithFrame:rect];
    fakeNavigationBar.alpha = 0;
    
    CGRect leftButtonFrame = CGRectMake(6, 21, 40, 40);
    CGRect rightButtonFrame = CGRectMake(CGRectGetWidth(self.navigationController.navigationBar.frame) - 6- 40, 21, 40, 40);
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = leftButtonFrame;
    [leftButton setImage:[UIImage imageNamed:@"icon-arrow-back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    [fakeNavigationBar addSubview:leftButton];
    
    BOOL enableManage = !([self.user.service isEqualToString:@"talkai"] && self.user.isRobot.boolValue) && [TBUtility isManagerForCurrentAccount] && !self.currentTeam.nonJoinableValue && !self.user.isQuitValue;
    
    if (enableManage) {
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = rightButtonFrame;
        [rightButton setImage:[UIImage imageNamed:@"topic-setting"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(managingAction:) forControlEvents:UIControlEventTouchUpInside];
        [fakeNavigationBar addSubview:rightButton];
    }
    
    
    self.fakeNavigationBar = fakeNavigationBar;
    [self.navigationController.view addSubview:fakeNavigationBar];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-arrow-back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    
    if (enableManage) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"topic-setting"] style:UIBarButtonItemStylePlain target:self action:@selector(managingAction:)];
    }
    
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushSettingViewController {
    AppSettingViewController *viewController = [[UIStoryboard storyboardWithName:@"AppSetting" bundle:nil] instantiateViewControllerWithIdentifier:@"AppSettingViewController"];
    viewController.hasTeamInfo = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [super viewWillAppear:animated];
    if (self.transitionCoordinator) {
        [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.fakeNavigationBar.alpha = 1;
        }];
    }
    [self renderView];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.navigationController.viewControllers.count == 1) {
        //Back to home page
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    if (self.transitionCoordinator) {
        [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.fakeNavigationBar.alpha = 0;
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.fakeNavigationBar.alpha = 0;
        }];
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.fakeNavigationBar removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tableView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
}

#pragma mark - IBActions

- (IBAction)enterConversation:(id)sender {
    if ([TBUtility currentAppDelegate].currentRoom || [TBUtility currentAppDelegate].currentStory) {
        MOUser *tapUser = [MOUser findFirstWithId:self.user.id];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShareForMember object:tapUser];
    } else {
        if (self.isFromRecent) {
            MOUser *tapUser = [MOUser findFirstWithId:self.user.id];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShareForMember object:tapUser];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (IBAction)managingAction:(id)sender {
    UIActionSheet *actionSheet = [UIActionSheet SH_actionSheetWithTitle:nil];
    
    NSString *adminTitleString;
    NSString *roleString;
    if ([TBUtility isAdminForMemberWithMemberID:self.user.id]) {
        adminTitleString = NSLocalizedString(@"Cancel admin", @"Cancel admin");
        roleString = @"member";
    } else {
        adminTitleString = NSLocalizedString(@"Set as administrator", @"Set as administrator");
        roleString = @"admin";
    }
    
    [actionSheet SH_addButtonWithTitle:adminTitleString withBlock:^(NSInteger theButtonIndex) {
            [self setAsAdministrator:roleString];
        }];
    [actionSheet SH_addButtonDestructiveWithTitle:NSLocalizedString(@"Remove from team", @"Remove from team") withBlock:^(NSInteger theButtonIndex) {
        [self removeFromTeam];
    }];
    [actionSheet SH_addButtonCancelWithTitle:NSLocalizedString(@"Cancel", @"Cancel") withBlock:nil];
    
    [actionSheet showInView:self.view];
}

- (IBAction)enterAppSetting:(id)sender {
    AppSettingViewController *settingVC = [[UIStoryboard storyboardWithName:kAppSettingStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"AppSettingViewController"];
    [settingVC setHasTeamInfo:YES];
    [self.navigationController pushViewController:settingVC animated:YES];
}

#pragma mark - Pravite Methods

- (void)commonInit {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentTeamID = [defaults valueForKey:kCurrentTeamID];
    self.currentTeam  = [MOTeam MR_findFirstByAttribute:@"id" withValue:currentTeamID];
    self.tableView.backgroundColor = [UIColor whiteColor];

    if (self.isFromSetting) {
        self.renderColor = [UIColor jl_redColor];
        self.editProfileButton.hidden = NO;
        self.tableView.tableFooterView = [[UIView alloc]init];
    }
    else
    {
        self.editProfileButton.hidden = YES;
        NSString *currentUserID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
        //deal for self
        if ([currentUserID isEqualToString:self.user.id]) {
            self.editProfileButton.hidden = NO;
            self.tableView.tableFooterView = [[UIView alloc]init];
        }
    }
    
    self.enterConversationBtn.tintColor = self.renderColor;
    self.editProfileButton.tintColor = self.renderColor;
    CGFloat top = 22;
    UIEdgeInsets imageInsets  = UIEdgeInsetsMake(top, top, top, top);
    UIImage *backgoundImage  = [[UIImage imageNamed:@"icon-enter-conversation"] resizableImageWithCapInsets:imageInsets resizingMode:UIImageResizingModeStretch];
    UIImage *enterConversationImage = [backgoundImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.enterConversationBtn setBackgroundImage:enterConversationImage forState:UIControlStateNormal];
    [self.enterConversationBtn setTitle:NSLocalizedString(@"Enter Conversation", @"Enter Conversation") forState:UIControlStateNormal];
    [self.editProfileButton setBackgroundImage:enterConversationImage forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateName:) name:kPersonalInfoChangeNotification object:nil];
}

- (void)renderView {
    [self.header.imageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatarURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
    self.header.titleLabel.text = self.user.name;
    if (self.user.alias.length > 0) {
        self.header.titleLabel.text = self.user.alias;
    }
    
    TBPersonInfoCell *emailCell = (TBPersonInfoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    emailCell.nameLabel.text = self.user.email?:NSLocalizedString(@"No Info", nil);
    if ([self.tableView numberOfRowsInSection:0] == 2) {
        TBPersonInfoCell *phoneCell = (TBPersonInfoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        phoneCell.nameLabel.text = self.user.mobile;
    }
}

- (NSAttributedString *)aliasAttrString {
    NSMutableAttributedString *aliasAttrString = [[NSMutableAttributedString alloc] initWithString:[TBUtility dealForNilWithString:self.user.alias]
                                                                                        attributes:@{ NSForegroundColorAttributeName : [UIColor tb_otherFileColor],
                                                                                                      NSFontAttributeName : [UIFont systemFontOfSize:17]
                                                                                                      }];
    NSAttributedString *nameAttrString = [[NSAttributedString alloc]
                                          initWithString:[NSString stringWithFormat:@"(%@)",[TBUtility dealForNilWithString:self.user.name]]
                                          attributes:@{
                                                       NSForegroundColorAttributeName : [UIColor tb_textGray],
                                                       NSFontAttributeName : [UIFont systemFontOfSize:17]
                                                       }];
    NSAttributedString *originNameAttrString = [[NSAttributedString alloc]
                                          initWithString:[NSString stringWithFormat:@"%@",[TBUtility dealForNilWithString:self.user.name]]
                                          attributes:@{
                                                       NSForegroundColorAttributeName : [UIColor tb_otherFileColor],
                                                       NSFontAttributeName : [UIFont systemFontOfSize:17]
                                                       }];
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
    //deal for self
    if ([currentUserID isEqualToString:self.user.id]) {
        if (aliasAttrString.length > 0) {
            [aliasAttrString appendAttributedString:nameAttrString];
            return aliasAttrString;
        } else {
            return originNameAttrString;
        }
    } else {
        if (aliasAttrString.length > 0) {
            return aliasAttrString;
        } else {
            return originNameAttrString;
        }
    }
}

//call
-(void)callWithNumber:(NSString *)phoneNum
{
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNum]];
    
    if ( !phoneCallWebView ) {
        phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    
}

//send mail
-(void)sendEmail:(NSString *)emailAddress
{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.navigationBar.tintColor = [UIColor whiteColor];
    
    if (![MFMailComposeViewController canSendMail]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Can not send Email", @"Can not send Email")];
        return;
    }
    mc.mailComposeDelegate = self;
    [mc setToRecipients:[NSArray arrayWithObjects:emailAddress, nil]];
    [self presentViewController:mc animated:YES completion:nil];
}

/**
 *  set As Administrator
 */
- (void)setAsAdministrator:(NSString *)roleString {
    NSString *currentTeamID   = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentTeamID];
    [[TBHTTPSessionManager sharedManager]POST:[NSString stringWithFormat:kMemberUpdateURLString,currentTeamID] parameters:@{@"_userId": self.user.id,@"role":roleString} success:^(NSURLSessionDataTask *task, id responseObject) {
        [[TBSocketManager sharedManager] memberUpdateWith:@{@"_teamId": currentTeamID,@"_userId": self.user.id,@"role":roleString}];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Done")];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

- (void)removeFromTeam {
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentTeamID];
    [[TBHTTPSessionManager sharedManager]POST:[NSString stringWithFormat:kRemoveMemberURLString,currentTeamID] parameters:@{@"_userId": self.user.id} success:^(NSURLSessionDataTask *task, id responseObject) {
        [[TBSocketManager sharedManager] teamLeaveWith:@{@"_teamId": currentTeamID,@"_userId": self.user.id}];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Done", @"Done")];
        
        if ([TBUtility currentAppDelegate].currentRoom) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
            [self.navigationController popViewControllerAnimated:NO];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedRecoverySuggestion];
    }];
}

 #pragma mark-Notification Selector

- (void)updateName:(NSNotification *)notification {
    MOUser *user = [MOUser currentUser];
    self.user = user;
    [self renderView];
}

 #pragma mark - Table view Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *userID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
    BOOL hideMobile =  self.user.hideMobileValue && ![self.user.id isEqualToString:userID];
    if (!self.user.mobile || self.user.mobile.length == 0 || hideMobile) {
        return 1;
    } else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DefaultSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return DefaultSectionHeaderHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBPersonInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.nameImageView.tintColor = self.renderColor;
    switch (indexPath.row) {
        case 0: {
            UIImage *mailImage = [[UIImage imageNamed:@"icon-mail"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.nameImageView.image = mailImage;
            NSString *email = self.user.email?:NSLocalizedString(@"No Info", nil);
            cell.nameLabel.text = email;
            break;
        }
        case 1: {
            UIImage *phoneImage = [[UIImage imageNamed:@"icon-phone"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.nameImageView.image = phoneImage;
            cell.nameLabel.text = self.user.mobile;
            break;
        }
        default:
            break;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0)
    {
        TBPersonInfoCell *emailCell = (TBPersonInfoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if (!self.isFromSetting && emailCell.nameLabel.text.length > 0) {
            [self sendEmail:emailCell.nameLabel.text];
        }
    }
    else if (indexPath.row == 1)
    {
        TBPersonInfoCell *phoneCell = (TBPersonInfoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        if (!self.isFromSetting && phoneCell.nameLabel.text.length > 0) {
           BOOL canCall = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneCell.nameLabel.text]]];
            if (canCall) {
                [self callWithNumber:phoneCell.nameLabel.text];
            }
        }
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark-MFMailComposedelegate
//the delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            DDLogDebug(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved:
            DDLogDebug(@"Mail saved...");
            break;
        case MFMailComposeResultSent:
            DDLogDebug(@"Mail sent...");
            break;
        case MFMailComposeResultFailed:
            DDLogDebug(@"Mail send errored: %@...", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
