//
//  PostsTableViewController.m
//  Talk
//
//  Created by 史丹青 on 15/5/4.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "PostsTableViewController.h"
#import "TBMessage.h"
#import "MTLJSONAdapter.h"
#import "TBFile.h"
#import "TBUser.h"
#import "NSDate+TBUtilities.h"
#import "MORoom.h"
#import "CoreData+MagicalRecord.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TBUtility.h"
#import "UIColor+TBColor.h"
#import "HyperDetailViewController.h"
#import "TBHTTPSessionManager.h"
#import "MJRefresh.h"
#import "TBMenuItem.h"
#import "UIActionSheet+SHActionSheetBlocks.h"
#import "MOMessage.h"
#import "SVProgressHUD.h"
#import "TBAttachment.h"

@interface PostsTableViewController ()

@end

@implementation PostsTableViewController

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
    
    NSMutableDictionary *parasDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:teamID,@"_teamId",
                                            @"rtf",@"type",
                                            [[NSString alloc] initWithFormat:@"%d",self.pageNumber],@"page",
                                            [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"desc",@"order", nil],@"createdAt", nil],@"sort",
                                            nil];
    [parasDictionary addEntriesFromDictionary:self.filterDictionary];
    
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager GET:kSearchURLString parameters:parasDictionary success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogVerbose(@"response data: %@", responseObject);
        [self processResponseData:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"error: %@", error.localizedRecoverySuggestion);
    }];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    TBMessage *model = self.messagesArray[indexPath.row];
    TBAttachment *attachment = model.attachments.firstObject;
    NSString *rtfText = attachment.data[kQuoteText];
    [self jumpToHyperDetailWith:rtfText];
}


-(void)jumpToHyperDetailWith:(NSString *)hyperText
{
    HyperDetailViewController *hyperDeatailVC = [[UIStoryboard storyboardWithName:kChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:@"HyperDetailViewController"];
    hyperDeatailVC.hyperString = hyperText;
    [self.navigationController pushViewController:hyperDeatailVC animated:YES];
}


@end
