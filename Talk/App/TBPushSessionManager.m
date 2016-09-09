//
//  TBPushSessionManager.m
//  Talk
//
//  Created by Suric on 15/12/14.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "TBPushSessionManager.h"
#import "TBHTTPSessionManager.h"
#import "MOTeam.h"
#import "TBUtility.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "TBSocketManager.h"
#import "RootViewController.h"

@implementation TBPushSessionManager

+ (TBPushSessionManager *)sharedManager {
    static TBPushSessionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TBPushSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kTPSBaseURLString]];
    });
    return sharedManager;
}

- (id)initWithBaseURL:(NSURL *)url {
    DDLogVerbose(@"URL_ROOT: %@", url);
    self = [super initWithBaseURL:url];
    if (self) {
    }
    return self;
}

- (void)fetchBroadcastHistoryMessage {
    NSString *teamId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[kFetchBroadcastHistorySuccess stringByAppendingString:teamId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [TBUtility currentAppDelegate].isFetchingBroadcastHistory = YES;
    
    NSString *tpsUserId = [[NSUserDefaults standardUserDefaults] objectForKey:KTPSUSerId];
    NSString *userChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:KTPSUserChannelId];
    MOTeam *team = [MOTeam MR_findFirstByAttribute:@"id" withValue:teamId];
    NSString *minDateString = [[TBUtility dateFormatter] stringFromDate:team.minDate];
    if (!minDateString || !tpsUserId || !userChannelId) {
        return;
    }
    DDLogDebug(@"minDateString:%@",minDateString);
    NSDictionary *userChannelparas = @{@"userId":tpsUserId, @"channelId":userChannelId, @"minDate":minDateString};
    NSString *teamChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:KTPSCurrentTeamChannelId];
    NSDictionary *teamChannelparas = @{@"userId":tpsUserId, @"channelId":teamChannelId, @"minDate":minDateString};
    
    NSDate *updateDate = [NSDate date];
    __block NSMutableArray *historyMessageArray = [[NSMutableArray alloc]init];
    __block NSError *historyError;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^{
        dispatch_group_enter(group);
        [[TBPushSessionManager sharedManager] GET:KTPSMessageBroadcastHistoryPath parameters:userChannelparas success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSArray *userHistoryMessageArray = responseObject;
            DDLogDebug(@"*** userHistoryMessageArray : %@",userHistoryMessageArray);
            [historyMessageArray addObjectsFromArray:userHistoryMessageArray];
            dispatch_group_leave(group);
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            historyError = error;
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_async(group, queue, ^{
        dispatch_group_enter(group);
        [[TBPushSessionManager sharedManager] GET:KTPSMessageBroadcastHistoryPath parameters:teamChannelparas success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSArray *teamHistoryMessageArray = responseObject;
            DDLogDebug(@"*** teamHistoryMessageArray : %@",teamHistoryMessageArray);
            [historyMessageArray addObjectsFromArray:teamHistoryMessageArray];
            dispatch_group_leave(group);
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            historyError = error;
            dispatch_group_leave(group);
        }];
    });
    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!historyError) {
                [self updateMinDate:updateDate forTeam:teamId];
                if (historyMessageArray) {
                    [self dealBroadcastHistoryMessages:historyMessageArray];
                }
                [TBUtility currentAppDelegate].isFetchingBroadcastHistory = NO;
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[kFetchBroadcastHistorySuccess stringByAppendingString:teamId]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                [TBUtility currentAppDelegate].isFetchingBroadcastHistory = NO;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[kFetchBroadcastHistorySuccess stringByAppendingString:teamId]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [TBUtility showMessageInError:historyError];
                [[NSNotificationCenter defaultCenter] postNotificationName:kFailedFetchTeamData object:nil];
            }
        });
    });
}

#pragma mark - Private Methods

- (void)updateMinDate:(NSDate *)newMinDate forTeam:(NSString *)teamId {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MOTeam *currentteam = [MOTeam MR_findFirstByAttribute:@"id" withValue:teamId inContext:localContext];
        currentteam.minDate = newMinDate;
    } completion:^(BOOL success, NSError *error) {
        DDLogDebug(@"Update Team minDate Success!");
    }];
}

- (void)dealBroadcastHistoryMessages:(NSArray *)historyMessageArray {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        for (NSDictionary *payloadDictionary in historyMessageArray) {
            NSDictionary *eventDictionary = payloadDictionary[@"payload"];
            [[TBSocketManager sharedManager] socketActionWithMessageDic:eventDictionary context:localContext];
        }
    } completion:^(BOOL success, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTeamDataStored object:nil];
        if ([TBUtility currentAppDelegate].remoteNotificationObject) {
            RootViewController *rootVC = (RootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            [rootVC enterChatForMessageInfo:[TBUtility currentAppDelegate].remoteNotificationObject];
        }
    }];
}


@end
