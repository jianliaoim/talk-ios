//
//  LinksTableViewController.m
//  Talk
//
//  Created by 史丹青 on 15/5/4.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "LinksTableViewController.h"
#import "NSDate+TBUtilities.h"
#import "MORoom.h"
#import "CoreData+MagicalRecord.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TBMessage.h"
#import "MTLJSONAdapter.h"
#import "TBUtility.h"
#import "UIColor+TBColor.h"
#import "TBUser.h"
#import "TBFile.h"
#import "TBHTTPSessionManager.h"
#import "MJRefresh.h"
#import "TBMenuItem.h"
#import "UIActionSheet+SHActionSheetBlocks.h"
#import "SVProgressHUD.h"
#import "MOMessage.h"
#import "PlaceHolderView.h"
#import "MOUser.h"
#import "AddTagViewController.h"
#import "TBTag.h"
#import "TBAttachment.h"
#import "JLWebViewController.h"

@interface LinksTableViewController ()

@end

@implementation LinksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SyncData

- (void)syncData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *teamID = [defaults valueForKey:kCurrentTeamID];
    
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    //[SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...")];
    NSMutableDictionary *parasDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:teamID,@"_teamId",
                                            @"url",@"type",
                                            [[NSString alloc] initWithFormat:@"%d",self.pageNumber],@"page",
                                            [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"desc",@"order", nil],@"createdAt", nil],@"sort",
                                            nil];
    [parasDictionary addEntriesFromDictionary:self.filterDictionary];
    [manager GET:kSearchURLString parameters:parasDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogVerbose(@"response data: %@", responseObject);
        [self processResponseData:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"error: %@", error.localizedRecoverySuggestion);
    }];
}

#pragma mark - Table view data source

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    TBMessage *model = self.messagesArray[indexPath.row];
    TBAttachment *attachment = model.attachments.firstObject;
    NSURL *redirectURL = [NSURL URLWithString:attachment.data[kQuoteRedirectUrl]];
    
    JLWebViewController *jsViewController = [[JLWebViewController alloc]init];
    jsViewController.hidesBottomBarWhenPushed = YES;
    jsViewController.urlString = redirectURL.absoluteString;
    [self.navigationController pushViewController:jsViewController animated:YES];
}

@end
