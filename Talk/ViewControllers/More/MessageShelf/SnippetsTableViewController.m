//
//  SnippetsTableViewController.m
//  Talk
//
//  Created by 史丹青 on 8/11/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "SnippetsTableViewController.h"
#import "constants.h"
#import "TBHTTPSessionManager.h"
#import "TBMessage.h"
#import "MORoom.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "TBUtility.h"
#import "NSDate+TBUtilities.h"
#import "TBUser.h"
#import "Talk-Swift.h"
#import "TBAttachment.h"

@interface SnippetsTableViewController ()

@end

@implementation SnippetsTableViewController

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
                                            @"snippet",@"type",
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
    CodeViewController *codeVC = [[CodeViewController alloc] init];
    NSString *codeString = attachment.data[kQuoteText];
    codeVC.snippet = codeString;
    NSString *codeType = attachment.data[kCodeType];
    codeVC.language = codeType;
    [self.navigationController pushViewController:codeVC animated:YES];
}

@end
