//
//  JLSharingTableViewController.m
//  Talk
//
//  Created by 王卫 on 15/11/25.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "JLSharingTableViewController.h"
#import "JLShareTeamController.h"
#import "JLShareSessionManager.h"
#import "JLShareSendController.h"
#import "ShareConstants.h"
#import "JLSharePoster.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface JLSharingTableViewController ()<JLShareTeamControllerDelegate, JLShareSendControllerDelgate, NSURLSessionTaskDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *URLLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fileImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) NSDictionary *selectedTeamInfo;
@property (strong, nonatomic) NSArray *teamArray;
@property (strong, nonatomic) NSDictionary *teamDictionary;
@property (nonatomic) CGSize contentSize;
@property (nonatomic) BOOL isUISet;
@property (nonatomic) BOOL isDataPrepared;

@end

static NSString * const CellIdentifier = @"JLShareBasicCell";
static const CGFloat JLShareImageViewDefaultHeight = 200;
static const CGFloat JLShareItemCellHeight = 44;

@implementation JLSharingTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    self.tableView.scrollEnabled = NO;
    self.title = NSLocalizedString(@"Talk", @"Talk");
    self.teamNameLabel.text = NSLocalizedString(@"Team", @"Team");
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator startAnimating];
    NSUserDefaults *groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:kTalkGroupID];
    BOOL hasLogin = [groupDefaults boolForKey:kUserHaveLogin];
    if (!hasLogin) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Please login first", @"Please login first") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self cancel:nil];
        }];
        [alertController addAction:OKAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    NSString *currentTeamIDString = [groupDefaults objectForKey:kCurrentTeamID];
    [self getAllTeamDataWithCurrentTeamId:currentTeamIDString];
    [self getTeamDataWithId:currentTeamIDString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.isUISet) {
        [self setupUI];
    }
    if ([self.delegate respondsToSelector:@selector(updateContainerHeight:)]) {
        [self.delegate updateContainerHeight:self.contentSize.height];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Getters

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), JLShareImageViewDefaultHeight);
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

#pragma mark - Private methods

- (void)cancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(hideExtensionAfterCancel)]) {
        [self.delegate hideExtensionAfterCancel];
    }
}

- (void)setupUI {
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat navigationBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    
    NSExtensionItem *inputItem = self.extensionContext.inputItems.firstObject;
    NSLog(@"inputItem :%@",inputItem.attributedContentText);

    NSItemProvider *itemProvider = inputItem.attachments.firstObject;
    NSLog(@"registeredTypeIdentifiers:%@",itemProvider.registeredTypeIdentifiers);
    NSItemProvider *secondItemProvider = nil;
    if (inputItem.attachments.count > 1) {
        secondItemProvider = [inputItem.attachments objectAtIndex:1];
        NSLog(@"secondItemProvider :%@",secondItemProvider);
        for (NSItemProvider *tempitemProvider in inputItem.attachments) {
            if ([tempitemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText]) {
                itemProvider = tempitemProvider;
            }
            if ([tempitemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                secondItemProvider = tempitemProvider;
            }
        }
    }

    
    if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
        self.contentSize = CGSizeMake(viewWidth, navigationBarHeight + JLShareImageViewDefaultHeight + JLShareItemCellHeight*3);
        [self.headerView addSubview:self.imageView];
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(id _Nullable item, NSError * _Null_unspecified error) {
            NSLog(@"itemProvider item:kUTTypeImage");
            NSLog(@"image item :%@",item);
            
            if ([item isKindOfClass:[NSURL class]]) {
                NSData *imageData = [NSData dataWithContentsOfFile:item];
                UIImage *image = [UIImage imageWithData:imageData];
                [JLSharePoster sharedPoster].fileData = UIImageJPEGRepresentation(image, 0.5);
                [JLSharePoster sharedPoster].fileName = [NSString stringWithFormat:@"ShareImage%u.jpg", arc4random()%10000+1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = image;
                });
            }
        }];
    } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeFileURL]) {
        CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(viewWidth, MAXFLOAT)];
        CGSize urlSize = [self.URLLabel sizeThatFits:CGSizeMake(viewWidth, MAXFLOAT)];
        CGFloat heightOfHeaderView = titleSize.height + urlSize.height + 3*8;
        self.headerView.frame = CGRectMake(0, 0, viewWidth, heightOfHeaderView);
        self.tableView.tableHeaderView = self.headerView;
        self.contentSize = CGSizeMake(viewWidth, navigationBarHeight + heightOfHeaderView + JLShareItemCellHeight *3);
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeFileURL options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
            NSLog(@"itemProvider kUTTypeFileURL");

            NSURL *fileURL = (NSURL *)item;
            NSString *fileName = [fileURL lastPathComponent];
            [JLSharePoster sharedPoster].fileData = [NSData dataWithContentsOfURL:fileURL];
            [JLSharePoster sharedPoster].fileName = fileName;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.titleLabel.text = fileName;
                self.URLLabel.text = fileURL.absoluteString;
                self.fileImageView.image = [UIImage imageNamed:@"icon-file-default"];
            });
        }];
    } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText]) {
        CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(viewWidth, MAXFLOAT)];
        CGFloat heightOfHeaderView = titleSize.height + 3*8;
        if (secondItemProvider && [secondItemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
            CGSize urlSize = [self.URLLabel sizeThatFits:CGSizeMake(viewWidth, MAXFLOAT)];
            heightOfHeaderView = heightOfHeaderView + urlSize.height;
        }
        self.headerView.frame = CGRectMake(0, 0, viewWidth, heightOfHeaderView);
        self.tableView.tableHeaderView = self.headerView;
        self.contentSize = CGSizeMake(viewWidth, navigationBarHeight + heightOfHeaderView + JLShareItemCellHeight *3);
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeText options:nil completionHandler:^(id _Nullable item, NSError * _Null_unspecified error) {
            NSLog(@"itemProvider kUTTypeText");
            NSLog(@"text item item: %@",item);
            
            NSString *text = (NSString *)item;
            [JLSharePoster sharedPoster].messageText = text;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.titleLabel.text = text;
            });
            if (secondItemProvider && [secondItemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
                [secondItemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(id _Nullable item, NSError * _Null_unspecified error) {
                    NSURL *url = (NSURL *)item;
                    [JLSharePoster sharedPoster].link = url.absoluteString;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.URLLabel.text = url.absoluteString;
                    });
                }];
            }
        }];
    } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList]) {
        CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(viewWidth, MAXFLOAT)];
        CGSize urlSize = [self.URLLabel sizeThatFits:CGSizeMake(viewWidth, MAXFLOAT)];
        CGFloat heightOfHeaderView = titleSize.height + urlSize.height + 3*8;
        self.headerView.frame = CGRectMake(0, 0, viewWidth, heightOfHeaderView);
        self.tableView.tableHeaderView = self.headerView;
        self.contentSize = CGSizeMake(viewWidth, navigationBarHeight + heightOfHeaderView + JLShareItemCellHeight *3);
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePropertyList options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
            NSDictionary *results = [(NSDictionary *)item objectForKey:NSExtensionJavaScriptPreprocessingResultsKey];
            [JLSharePoster sharedPoster].link = results[@"URL"];
            [JLSharePoster sharedPoster].messageText = results[@"title"];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.titleLabel.text = results[@"title"];
                self.URLLabel.text = results[@"URL"];
            });
        }];
    } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(viewWidth, MAXFLOAT)];
        CGSize urlSize = [self.URLLabel sizeThatFits:CGSizeMake(viewWidth, MAXFLOAT)];
        CGFloat heightOfHeaderView = titleSize.height + urlSize.height + 3*8;
        self.headerView.frame = CGRectMake(0, 0, viewWidth, heightOfHeaderView);
        self.tableView.tableHeaderView = self.headerView;
        self.contentSize = CGSizeMake(viewWidth, navigationBarHeight + heightOfHeaderView + JLShareItemCellHeight *3);
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
            NSLog(@"itemProvider kUTTypeURL");

            NSURL *url = (NSURL *)item;
            [JLSharePoster sharedPoster].link = url.absoluteString;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.titleLabel.text = url.absoluteString;
            });
        }];
    }
    self.isUISet = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"itemProvider  end");
    });
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.isDataPrepared) {
        return;
    }
    switch (indexPath.row) {
        case 0:{
            JLShareTeamController *selectTeamContoller = [[UIStoryboard storyboardWithName:@"MainInterface" bundle:nil] instantiateViewControllerWithIdentifier:@"JLShareTeamController"];
            selectTeamContoller.allTeamArray = self.teamArray;
            selectTeamContoller.delegate = self;
            selectTeamContoller.uiDelegate = self.delegate;
            [self.navigationController pushViewController:selectTeamContoller animated:YES];
            break;
        }
        case 1:{
            JLShareSendController *sendController = [[UIStoryboard storyboardWithName:@"MainInterface" bundle:nil] instantiateViewControllerWithIdentifier:@"JLShareSendController"];
            sendController.teamDic = self.teamDictionary;
            sendController.delegate = self;
            sendController.uiDelegate = self.delegate;
            sendController.isStory = NO;
            [self.navigationController pushViewController:sendController animated:YES];
            break;
        }
        case 2:{
            JLShareSendController *sendController = [[UIStoryboard storyboardWithName:@"MainInterface" bundle:nil] instantiateViewControllerWithIdentifier:@"JLShareSendController"];
            sendController.teamDic = self.teamDictionary;
            sendController.delegate = self;
            sendController.uiDelegate = self.delegate;
            sendController.isStory = YES;
            [self.navigationController pushViewController:sendController animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - JLShareTeamControllerDelegate

- (void)didSelectTeamWith:(NSDictionary *)teamInfo {
    self.teamNameLabel.text = teamInfo[@"name"];
    self.selectedTeamInfo = teamInfo;
    [JLSharePoster sharedPoster].selectedTeamId = teamInfo[@"_id"];
    self.isDataPrepared = NO;
    [self.activityIndicator startAnimating];
    [self getTeamDataWithId:teamInfo[@"_id"]];
}

- (void)getAllTeamDataWithCurrentTeamId:(NSString *)currentTeamId {
    NSMutableURLRequest *request = [JLShareSessionManager requestWithURLString:kTeamURLString];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSArray *teamDicArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.teamArray = teamDicArray;
            for (NSDictionary *teaminfoDic in teamDicArray) {
                if ([currentTeamId isEqualToString:teaminfoDic[@"_id"]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.teamNameLabel.text = teaminfoDic[@"name"];
                    });
                    self.selectedTeamInfo = teaminfoDic;
                    [JLSharePoster sharedPoster].selectedTeamId = teaminfoDic[@"_id"];
                    break;
                }
            }
            NSLog(@"all team end");
        }
    }];
    [task resume];
}

- (void)getTeamDataWithId: (NSString *)teamID {
    NSMutableURLRequest *request = [JLShareSessionManager requestWithURLString:[NSString stringWithFormat:@"%@/%@",kTeamURLString,teamID]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.teamDictionary = responseObject;
            self.isDataPrepared = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
            });
            NSLog(@"team data end");
        }
    }];
    [task resume];
}

@end
