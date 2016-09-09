//
//  MeTableViewController.m
//  Talk
//
//  Created by 王卫 on 15/10/27.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "MeTableViewController.h"
#import "MeTableViewCell.h"
#import "constants.h"
#import "MOUser.h"
#import "CoreData+MagicalRecord.h"
#import "FavoritesTableViewController.h"
#import "AppSettingViewController.h"
#import "ItemsViewController.h"
#import "TagsViewController.h"
#import "TBUtility.h"
#import "JLTeamHeaderView.h"
#import "UIView+TBSnapshotView.h"

@interface MeTableViewController ()

@property (nonatomic, strong) MOUser *user;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) JLTeamHeaderView *header;

@property (nonatomic, strong) UIView *fakeNavigationBar;
@end

static NSString *const kMeCellIdentifier = @"MeTableViewCell";

static NSString *const kUserInfoName = @"UserInfoName";
static NSString *const kUserInfoEmail = @"UserInfoEmail";
static NSString *const kUserInfoPhone = @"UserInfoPhone";

static CGFloat const TableViewHeaderHeight = 200;
static CGFloat const DefaultSectionHeaderHeight = 20;
static CGFloat const DefaultSectionFooterHeight = 20;

@implementation MeTableViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.header = [[JLTeamHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), TableViewHeaderHeight)];
    [self.tableView setTableHeaderView:self.header];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushSettingViewController)];
    [self.header.imageView addGestureRecognizer:tap];
    self.header.imageView.userInteractionEnabled = YES;
    
    [self.tableView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    [self.header.imageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatarURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
    self.header.titleLabel.text = self.userInfo[kUserInfoName];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(personInfoDidUpdate:) name:kPersonalInfoChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAvatar:) name:kAvatarChangeNotification object:nil];
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
    
    CGRect leftButtonFrame = CGRectMake(6, 21, 40, 40);
    CGRect rightButtonFrame = CGRectMake(CGRectGetWidth(self.navigationController.navigationBar.frame) - 6- 40, 21, 40, 40);
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = leftButtonFrame;
    [leftButton setImage:[UIImage imageNamed:@"icon-arrow-back"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
   
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = rightButtonFrame;
    [rightButton setImage:[UIImage imageNamed:@"topic-setting"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(pushSettingViewController) forControlEvents:UIControlEventTouchUpInside];
    fakeNavigationBar.alpha = 0;
    
    [fakeNavigationBar addSubview:leftButton];
    [fakeNavigationBar addSubview:rightButton];
    
    self.fakeNavigationBar = fakeNavigationBar;
    [self.navigationController.view addSubview:fakeNavigationBar];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-arrow-back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"topic-setting"] style:UIBarButtonItemStylePlain target:self action:@selector(pushSettingViewController)];
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushSettingViewController {
    AppSettingViewController *viewController = [[UIStoryboard storyboardWithName:@"AppSetting" bundle:nil] instantiateViewControllerWithIdentifier:@"AppSettingViewController"];
    viewController.hasTeamInfo = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [super viewWillAppear:animated];
    if (self.transitionCoordinator) {
        [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.fakeNavigationBar.alpha = 0.6;
        } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.fakeNavigationBar.alpha = 1;
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:[UIColor jl_redColor]];
    if (!self.header.imageForNavigationBar) {
        self.header.imageForNavigationBar = [self captureBackgroudImage];
    }
    [self.navigationController.navigationBar setBackgroundImage:self.header.imageForNavigationBar forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self.fakeNavigationBar removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tableView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
}

- (void)updateAvatar:(NSNotification *)notification {
    NSString *avatarString = [[NSUserDefaults standardUserDefaults]  objectForKey:kCurrentUserAvatar];
    [self.header.imageView sd_setImageWithURL:[NSURL URLWithString:avatarString] placeholderImage:[UIImage imageNamed:@"avatar"]];
}

#pragma mark - Getter

- (void)personInfoDidUpdate:(NSNotification *)aNotification {
    [self.header.imageView sd_setImageWithURL:[NSURL URLWithString:self.user.avatarURL] placeholderImage:[UIImage imageNamed:@"avatar"]];
    [self.tableView reloadData];
}

- (MOUser *)user {
    if (!_user) {
        _user = [MOUser currentUser];
    }
    return _user;
}

- (NSDictionary *)userInfo {
    if (!_userInfo) {
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        userInfo[kUserInfoName] = self.user.name ?:NSLocalizedString(@"No Info", @"No Info");
        userInfo[kUserInfoPhone] = self.user.mobile ?:NSLocalizedString(@"No Info", @"No Info");
        userInfo[kUserInfoEmail] = self.user.email ?:NSLocalizedString(@"No Info", @"No Info");
        _userInfo = [userInfo copy];
    }
    return _userInfo;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 4;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMeCellIdentifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        switch (indexPath.row) {
            case 0: {
                cell.cellNameLabel.text = self.userInfo[kUserInfoPhone];
                cell.cellImageView.image = [UIImage imageNamed:@"icon-phone"];
                break;
            }
            case 1: {
                cell.cellNameLabel.text = self.userInfo[kUserInfoEmail];
                cell.cellImageView.image = [UIImage imageNamed:@"icon-mail"];
                break;
            }
        }
    } else if (indexPath.section == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (indexPath.row) {
            case 0: {
                cell.cellNameLabel.text = NSLocalizedString(@"Favorites", @"Favorites");
                cell.cellImageView.image = [UIImage imageNamed:@"icon-star"];
                break;
            }
            case 1: {
                cell.cellNameLabel.text = NSLocalizedString(@"Items", @"Items");
                cell.cellImageView.image = [UIImage imageNamed:@"icon-shelf"];
                break;
            }
            case 2: {
                cell.cellNameLabel.text = NSLocalizedString(@"Tags", @"Tags");
                cell.cellImageView.image = [UIImage imageNamed:@"icon-tags"];
                break;
            }
            case 3: {
                cell.cellNameLabel.text = NSLocalizedString(@"@Messages", @"@Messages");
                cell.cellImageView.image = [UIImage imageNamed:@"icon-at"];
                break;
            }
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        return;
    } else {
        if (indexPath.row == 0) {
            FavoritesTableViewController *viewController = [[UIStoryboard storyboardWithName:@"Favorites" bundle:nil] instantiateViewControllerWithIdentifier:@"FavoritesTableViewController"];
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (indexPath.row == 1) {
            ItemsViewController *viewController = [[UIStoryboard storyboardWithName:@"Items" bundle:nil] instantiateViewControllerWithIdentifier:@"ItemsViewController"];
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (indexPath.row == 2) {
            TagsViewController *viewController = [[UIStoryboard storyboardWithName:@"Tags" bundle:nil] instantiateViewControllerWithIdentifier:@"TagsViewController"];
            [self.navigationController pushViewController:viewController animated:YES];
        } else if (indexPath.row == 3) {
            FavoritesTableViewController *viewController = [[UIStoryboard storyboardWithName:@"Favorites" bundle:nil] instantiateViewControllerWithIdentifier:@"FavoritesTableViewController"];
            viewController.type = JLCategoryTypeAt;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return DefaultSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return DefaultSectionFooterHeight;
    }
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), DefaultSectionHeaderHeight)];
    header.backgroundColor = [UIColor clearColor];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 1/[UIScreen mainScreen].scale)];
    line.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    [header addSubview:line];
    return header;
}


@end
