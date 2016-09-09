//
// Created by Shire on 9/19/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBSocketManager.h"
#import "TBHTTPSessionManager.h"
#import "constants.h"
#import "TBMessage.h"
#import "MOMessage.h"
#import <AudioToolbox/AudioToolbox.h>
#import "TBUtility.h"
#import "TBPushSessionManager.h"

#import "TBRoom.h"
#import "MORoom.h"
#import "MOTeam.h"
#import "TBUser.h"
#import "TBInvitation.h"
#import "MOInvitation.h"
#import "MOUser.h"
#import "MappingProvider.h"
#import "TBTeam.h"
#import "MONotification.h"
#import "TBGroup.h"
#import "MOGroup.h"
#import "TBNotification.h"
#import "TBTeamActivity.h"

@interface TBSocketManager () <SRWebSocketDelegate>
@property (strong, nonatomic) NSTimer *pollTimer;
@property (nonatomic) BOOL isReStart;
@end

#define pollInterval   25
@implementation TBSocketManager

+ (TBSocketManager *)sharedManager {
    static TBSocketManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TBSocketManager alloc]init];
        sharedManager.isReStart = NO;
    });

    return sharedManager;
}

- (void)openSocket {
    NSString *UUIDString = [[UIDevice currentDevice]identifierForVendor].UUIDString;
    NSDictionary *tpsUserRegisterParams = @{@"appKey": kTPSAppKey, @"deviceToken": UUIDString};
    [[TBPushSessionManager sharedManager] POST:kTPSUserRegisterPath parameters:tpsUserRegisterParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        DDLogDebug(@"%@",responseObject);
        NSString *tpsUserId = responseObject[@"userId"];
        [[NSUserDefaults standardUserDefaults] setObject:tpsUserId forKey:KTPSUSerId];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self connectToSocket];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        DDLogDebug(error.localizedRecoverySuggestion);
    }];
}

- (void)connectToSocket {
    DDLogDebug(@"connect socket");
    [self restartSocket];
    
    if (!self.pollTimer) {
        self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:pollInterval target:self selector:@selector(sendHeartBeatData) userInfo:nil repeats:YES];
    } else {
        [self.pollTimer invalidate];
        self.pollTimer = nil;
        self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:pollInterval target:self selector:@selector(sendHeartBeatData) userInfo:nil repeats:YES];
    }
}

- (void)restartSocket {
    _webSocket.delegate = nil;
    [_webSocket close];
    _webSocket = nil;
    
    NSString *tpsUserId = [[NSUserDefaults standardUserDefaults] objectForKey:KTPSUSerId];
    NSString *deviceUUIDString = [[UIDevice currentDevice]identifierForVendor].UUIDString;
    NSURL *tpsSocketURL = [NSURL URLWithString:[NSString stringWithFormat:kTPSSocketURLString,tpsUserId,deviceUUIDString]];
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:tpsSocketURL]];
    _webSocket.delegate = self;
    [_webSocket open];
}

-(void)closeSocket {
    //invalidate pollTimer
    if (self.pollTimer) {
        [self.pollTimer invalidate];
    }
    
    _webSocket.delegate = nil;
    [_webSocket close];
    //_webSocket = nil;
}


-(void)sendHeartBeatData {
//    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
//    NSString *pingString = [NSString stringWithFormat:@"4\"primus::ping::%f\"",interval];

    if (_webSocket.readyState == SR_OPEN) {
        [_webSocket send:@"2"];
        //[_webSocket send:pingString];
        DDLogDebug(@"send heartBeat Data");
    } else {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            DDLogDebug(@"restart socket");
            [self restartSocket];
            self.isReStart = YES;
        }
    }
}

#pragma mark - WebSocket delegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    DDLogInfo(@"SocketMessage: %@", message);
    NSString *messageString;
    if ([message isKindOfClass:[NSString class]]) {
        messageString = message;
        messageString = [messageString substringFromIndex:1];
        if ([messageString containsString:@"\\\""]) {
            NSString *sub = [messageString substringWithRange:(NSRange){ 1, messageString.length - 2 }];
            messageString = [sub stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        }
        if ([messageString containsString:@"\\n"]) {
            messageString = [messageString stringByReplacingOccurrencesOfString:@"\\n" withString:@"n"];
        }
    }
    NSData *data = [messageString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *serializeError = nil;
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&serializeError];
    if (serializeError) {
        return;
    }
    if ([JSONObject valueForKey:@"sid"]) {
        NSString *tpsUserId = [[NSUserDefaults standardUserDefaults] objectForKey:KTPSUSerId];
        [self subscribeSocketServiceWithTpsUserId:tpsUserId];
    } else {
        NSDictionary *broadcastDic = (NSDictionary *)JSONObject;
        NSString *cid = broadcastDic[@"id"];
        if (cid) {
            [self confirmSocketRecieveWithCid:cid];
        }
        NSArray *argsArray = broadcastDic[@"args"];
        for (NSDictionary *argsDic in argsArray) {
            NSDictionary *tempMessageDic = argsDic[@"payload"];
            NSDictionary *payloadDataDictionary = tempMessageDic[@"d"];
            NSString *teamId =  [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
            NSString *updateTimeStr = payloadDataDictionary[@"updatedAt"];
             if (teamId && updateTimeStr) {
                 BOOL fetchHistorySuccess = [[NSUserDefaults standardUserDefaults] boolForKey:[kFetchBroadcastHistorySuccess stringByAppendingString:teamId]];
                 if (![TBUtility currentAppDelegate].isFetchingBroadcastHistory && fetchHistorySuccess) {
                     NSDate *newMinDate = [[TBUtility dateFormatter] dateFromString:updateTimeStr];
                     DDLogDebug(@"updateDate:%@",newMinDate);
                     [[TBPushSessionManager sharedManager] updateMinDate:newMinDate forTeam:teamId];
                 }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self socketActionWithMessageDic:tempMessageDic context:nil];
            });
        }
    }
}

- (BOOL)validSocketMessage:(NSDictionary *)socketMessage {
    if (socketMessage == nil) {
        return NO;
    } else {
        NSString *socektVersion = socketMessage[@"v"];
        if (socektVersion) {
            NSString *versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            NSString *firstVersion = [versionStr substringToIndex:1];
            if (socektVersion.intValue > firstVersion.intValue) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)confirmSocketRecieveWithCid:(NSString *)cid {
    if (_webSocket.readyState == SR_OPEN) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"cid":cid} options:NSJSONWritingPrettyPrinted error:&error];
        NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (json) {
            [_webSocket send:[@"4" stringByAppendingString:json]];
        }
    }
}

- (void)subscribeSocketServiceWithTpsUserId:(NSString *)tpsUserId {
    if (tpsUserId) {
        TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
        [manager.requestSerializer setValue:tpsUserId forHTTPHeaderField:@"X-Socket-Id"];
        //subscribe for accepting message about me
        [manager POST:kUserSubscribeString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            DDLogVerbose(@"subscribe me Succeed: %@", responseObject);
            NSString *userChannelId = responseObject[@"channelId"];
            if (userChannelId) {
                [[NSUserDefaults standardUserDefaults] setObject:userChannelId forKey:KTPSUserChannelId];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //subscribe for accepting message about team
                [[TBHTTPSessionManager sharedManager] subscribeForAcceptTeamMessageWithIsSubscribe:YES];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DDLogError(@"Error: %@", [error localizedRecoverySuggestion]);
        }];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSError *error;
    NSString *pong = [NSJSONSerialization JSONObjectWithData:pongPayload options:0 error:&error];
    DDLogDebug(@"pong:%@",pong);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    DDLogInfo(@"Socket Open");
    if (self.isReStart) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshRecentData object:nil];
        self.isReStart = NO;
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    DDLogError(@"Socket Error: %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    DDLogInfo(@"Socket Close");
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self openSocket];
    }
}

#pragma mark - Socket Action

- (void)socketActionWithMessageDic:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)context {
    BOOL isValidSocketMessage = [self validSocketMessage:tempMessageDic];
    if (!isValidSocketMessage) {
        return;
    }
    
    NSString *eventName = tempMessageDic[@"a"];
    DDLogDebug(@"*********** EventString:%@ ********",eventName);
    
    //message:create
    if ([eventName isEqualToString:@"message:create"]) {
        [self messageCreateWith:tempMessageDic[@"d"] context:context];
    }
    //message:update
    else if ([eventName isEqualToString:@"message:update"]) {
        [self messageUpdateWith:tempMessageDic[@"d"] context:context];
    }
    //message:remove
    else if ([eventName isEqualToString:@"message:remove"]) {
        [self messageRemoveWith:tempMessageDic[@"d"] context:context];
    }
    //message:unread
    else if ([eventName isEqualToString:@"message:unread"]) {
        [self messageUnreadWith:tempMessageDic[@"d"] context:context];
    }
    //story:update
    else if ([eventName isEqualToString:@"story:update"]) {
        [self storyUpdateWith:tempMessageDic[@"d"] context:context];
    }
    //story:remove
    else if ([eventName isEqualToString:@"story:remove"]) {
        
    }
    //notification:update
    else if ([eventName isEqualToString:@"notification:update"]) {
        [self notificationUpdateWith:tempMessageDic[@"d"] context:context];
    }
    //notification:remove
    else if ([eventName isEqualToString:@"notification:remove"]) {
        [self notificationDeleteWith:tempMessageDic[@"d"] context:context];
    }
    //room:create
    else if ([eventName isEqualToString:@"room:create"]) {
        [self roomCreateWith:tempMessageDic[@"d"] context:context];
    }
    //room:join
    else if ([eventName isEqualToString:@"room:join"]) {
        [self roomJoinWith:[NSArray arrayWithObject:tempMessageDic[@"d"]] context:context];
    }
    //room:update
    else if ([eventName isEqualToString:@"room:update"]) {
        [self roomUpdateWith:tempMessageDic[@"d"] context:context];
    }
    //room.prefs:update
    else if ([eventName isEqualToString:@"room.prefs:update"]) {
        [self roomPrefsUpdateWith:tempMessageDic[@"d"] context:context];
    }
    //room:leave
    else if ([eventName isEqualToString:@"room:leave"]) {
        [self roomLeaveWith:tempMessageDic[@"d"] context:context];
    }
    //room:archive
    else if ([eventName isEqualToString:@"room:archive"]) {
        [self roomArchiveWith:tempMessageDic[@"d"] context:context];
    }
    //room:remove
    else if ([eventName isEqualToString:@"room:remove"]) {
        [self roomRemoveWith:tempMessageDic[@"d"] context:context];
    }
    //user:update
    else if ([eventName isEqualToString:@"user:update"]) {
        [self userUpdateWith:tempMessageDic[@"d"] context:context];
    }
    //member:update
    else if ([eventName isEqualToString:@"member:update"]) {
        [self memberUpdateWith:tempMessageDic[@"d"] context:context];
    }
    //invitation:create
    else if ([eventName isEqualToString:@"invitation:create"]) {
        [self invitationCreatWith:tempMessageDic[@"d"] context:context];
    }
    //invitation:remove
    else if ([eventName isEqualToString:@"invitation:remove"]) {
        [self invitationRemoveWith:tempMessageDic[@"d"] context:context];
    }
    //team:join
    else if ([eventName isEqualToString:@"team:join"]) {
        [self teamJoinWith:tempMessageDic[@"d"] context:context];
    }
    //team:leave
    else if ([eventName isEqualToString:@"team:leave"]) {
        [self teamLeaveWith:tempMessageDic[@"d"] context:context];
    }
    //team:update
    else if ([eventName isEqualToString:@"team:update"]) {
        [self teamUpdateWith:tempMessageDic[@"d"] context:context];
    }
    //team:pin
    else if ([eventName isEqualToString:@"team:pin"]) {
        [self teamPinWith:tempMessageDic[@"d"] context:context];
    }
    //team:unpin
    else if ([eventName isEqualToString:@"team:unpin"]) {
        [self teamUnpinWith:tempMessageDic[@"d"] context:context];
    }
    //team.prefs:update
    else if ([eventName isEqualToString:@"team.prefs:update"]) {
        [self teamPrefsUpdate:tempMessageDic[@"d"] context:context];
    }
    //team.members.prefs:update
    else if ([eventName isEqualToString:@"team.members.prefs:update"]) {
        [self teamPrefsUpdate:tempMessageDic[@"d"] context:context];
    }
    //group.create
    else if ([eventName isEqualToString:@"group:create"]) {
        [self groupCreateWith:tempMessageDic[@"d"] context:context];
    }
    //group.update
    else if ([eventName isEqualToString:@"group:update"]) {
        [self groupUpdateWith:tempMessageDic[@"d"] context:context];
    }
    //group.remove
    else if ([eventName isEqualToString:@"group:remove"]) {
        [self groupRemoveWith:tempMessageDic[@"d"] context:context];
    }
    //activity.create
    else if ([tempMessageDic[@"a"] isEqualToString:@"activity:create"]) {
        [self activityCreateWith:tempMessageDic[@"d"] context:context];
    }
    //activity.update
    else if ([tempMessageDic[@"a"] isEqualToString:@"activity:update"]) {
        [self activityUpdateWith:tempMessageDic[@"d"] context:context];
    }
    //activity.remove
    else if ([tempMessageDic[@"a"] isEqualToString:@"activity:remove"]) {
        [self activityRemoveWith:tempMessageDic[@"d"] context:context];
    }
}

#pragma mark - Socket for notification

- (void)notificationUpdateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    if (messageSyncContext) {
        NSString *notificationId = tempMessageDic[@"id"];
        MONotification *notification = [MONotification MR_findFirstByAttribute:@"id" withValue:notificationId];
        if (notification && notification.unreadNumValue == [tempMessageDic[@"unreadNum"] intValue]) {
            DDLogDebug(@"Has update");
        } else {
            [self saveChangeTeamUnreadWith:tempMessageDic forContext:messageSyncContext];
        }
    } else {
        int change = [tempMessageDic[@"unreadNum"] intValue] - [tempMessageDic[@"oldUnreadNum"] intValue];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveChangeTeamUnreadWith:tempMessageDic forContext:localContext];
        } completion:^(BOOL success, NSError *error) {
            NSString *teamId = tempMessageDic[@"_teamId"];
            NSString *currentTeamId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
            if (![teamId isEqualToString:currentTeamId]) {
                [TBUtility currentAppDelegate].otherTeamUnreadNo += change;
                if ([TBUtility currentAppDelegate].otherTeamUnreadNo < 0) {
                    [TBUtility currentAppDelegate].otherTeamUnreadNo = 0;
                }
            }
        }];
    }
    
    BOOL isDelete = [tempMessageDic[@"isHidden"] boolValue];
    if (isDelete) {
        if (messageSyncContext) {
            [self saveDeleteNotificationWith:tempMessageDic forContext:messageSyncContext];
        } else {
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                [self saveDeleteNotificationWith:tempMessageDic forContext:localContext];
            } completion:^(BOOL success, NSError *error) {
                if (success) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSocketNotificationDelete object:tempMessageDic];
                }
            }];
        }
    } else {
        TBNotification *newNotification = [TBNotification objectFromJSONObject:tempMessageDic];
        if (messageSyncContext) {
            [MTLManagedObjectAdapter managedObjectFromModel:newNotification insertingIntoContext:messageSyncContext error:NULL];
        } else {
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                [MTLManagedObjectAdapter managedObjectFromModel:newNotification insertingIntoContext:localContext error:NULL];
            } completion:^(BOOL success, NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kSocketNotificationUpdate object:newNotification];
            }];
        }
    }
}

- (void)saveChangeTeamUnreadWith:(NSDictionary *)tempMessageDic forContext:(NSManagedObjectContext *)context {
    int change = [tempMessageDic[@"unreadNum"] intValue] - [tempMessageDic[@"oldUnreadNum"] intValue];
    MOTeam *team = [MOTeam MR_findFirstByAttribute:@"id" withValue:tempMessageDic[@"_teamId"] inContext:context];
    int oldTeamUnread = [team.unread intValue];
    int newTeamUnread = oldTeamUnread + change;
    if (newTeamUnread <= 0) {
        team.hasUnreadValue = NO;
        newTeamUnread = 0;
    }
    team.unread = [NSNumber numberWithInt:newTeamUnread];
}

- (void)notificationDeleteWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    NSString *notificationId = tempMessageDic[@"_id"];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MONotification *notification = [MONotification MR_findFirstByAttribute:@"id" withValue:notificationId inContext:localContext];
        [notification MR_deleteInContext:localContext];
    } completion:^(BOOL success, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSocketNotificationDelete object:tempMessageDic];
    }];
}

- (void)saveDeleteNotificationWith:(NSDictionary *)tempMessageDic forContext:(NSManagedObjectContext *)context {
    MONotification *notification = [MONotification MR_findFirstByAttribute:@"id" withValue:tempMessageDic[@"id"] inContext:context];
    [notification MR_deleteInContext:context];
}

#pragma mark - Socket for story

- (void)storyUpdateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    if (messageSyncContext) {
        [self saveStoryUpdateWith:tempMessageDic context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveStoryUpdateWith:tempMessageDic context:localContext];
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kEditStoryNotification object:tempMessageDic];
            }
        }];
    }
}

- (void)saveStoryUpdateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)context {
    MOStory *currentStory = [MOStory MR_findFirstByAttribute:@"id" withValue:tempMessageDic[@"_id"] inContext:context];
    if (currentStory) {
        currentStory.data = [tempMessageDic objectForKey:@"data"];
        currentStory.members = [tempMessageDic objectForKey:@"_memberIds"];
    }
}

#pragma mark - Socket for message

- (void)messageCreateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    TBMessage *message = [MTLJSONAdapter modelOfClass:[TBMessage class] fromJSONDictionary:tempMessageDic error:NULL];
    message.isUnread = YES;
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    BOOL isCurrentTeamMessage = [currentTeamID isEqualToString:message.teamID];
    if (isCurrentTeamMessage) {
        if (messageSyncContext) {
            [self saveMessage:message intoContext:messageSyncContext];
        } else {
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                MOMessage *moMessage = [self saveMessage:message intoContext:localContext];
                if (moMessage) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSocketMessageCreate object:tempMessageDic];
                }
            }];
        }
    } else {
        MOUser *user= [MOUser findFirstWithId:message.creatorID teamId:message.teamID];
        if (user) {
            TBUser *tbUser = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:user error:NULL];
            message.creator = tbUser;
            if (messageSyncContext) {
                [self saveMessage:message intoContext:messageSyncContext];
            } else {
                [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                    [self saveMessage:message intoContext:localContext];
                }];
            }
        }
    }
}

- (MOMessage *)saveMessage:(TBMessage *)message intoContext:(NSManagedObjectContext *)context {
    NSError *error;
    MOMessage *moMessage = [MTLManagedObjectAdapter managedObjectFromModel:message insertingIntoContext:context error:&error];
    if (moMessage == nil) {
        DDLogDebug(@"acceptSocketMessageSave Error:%@",error);
        return nil;
    } else {
        return moMessage;
    }
}

- (void)messageUpdateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    TBMessage *updateMessage = [MTLJSONAdapter modelOfClass:[TBMessage class]
                                    fromJSONDictionary:tempMessageDic
                                                 error:NULL];
    if (messageSyncContext) {
        [self saveMessageUpdateWith:tempMessageDic updateMessage:updateMessage intoContext:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            [self saveMessageUpdateWith:tempMessageDic updateMessage:updateMessage intoContext:localContext];
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSocketMessageUpdate object:updateMessage];
    }
    
}

- (void)saveMessageUpdateWith:(NSDictionary *)tempMessageDic updateMessage:(TBMessage *)updateMessage intoContext:(NSManagedObjectContext *)contenxt {
    MOMessage *moMessage = [MOMessage MR_findFirstByAttribute:@"id" withValue:[tempMessageDic objectForKey:@"_id"] inContext:contenxt];
    if (moMessage) {
        NSError *error;
        MOMessage *moMessage = [MTLManagedObjectAdapter
                                managedObjectFromModel:updateMessage
                                insertingIntoContext:contenxt
                                error:&error];
        if (moMessage==nil) {
            DDLogDebug(@"[NSManagedObject] Error:%@",error);
        }
    }
}

- (void)messageRemoveWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    if (messageSyncContext) {
        [self saveMessageRemoveWith:tempMessageDic context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            [self saveMessageRemoveWith:tempMessageDic context:localContext];
        }];
    }
}

- (void)saveMessageRemoveWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)context {
    MOMessage *moMessage = [MOMessage MR_findFirstByAttribute:@"id" withValue:[tempMessageDic objectForKey:@"_id"] inContext:context];
    if (moMessage) {
        [moMessage MR_deleteInContext:context];
        [[NSNotificationCenter defaultCenter]postNotificationName:kSocketMessageRemove object:[tempMessageDic objectForKey:@"_id"]];
    } else{
        DDLogDebug(@"haven't find message");
    }
}

- (void)messageUnreadWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    if (![tempMessageDic[@"_teamId"] isEqualToString:currentTeamID]) {
        return;
    }
    NSArray *unreadTargetIDArray = [tempMessageDic[@"unread"] allKeys];
    if (unreadTargetIDArray.count > 0) {
        [unreadTargetIDArray enumerateObjectsUsingBlock:^(NSString *targetID, NSUInteger idx, BOOL *stop) {
            if (messageSyncContext) {
                [self saveMessageUnreadWithTargetId:targetID context:messageSyncContext];
            } else {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                    [self saveMessageUnreadWithTargetId:targetID context:localContext];
                } completion:^(BOOL success, NSError *error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSocketMessageUnread object:targetID];
                }];
            }
        }];
    }
}

- (void)saveMessageUnreadWithTargetId:(NSString *)targetID context:(NSManagedObjectContext *)context {
    NSPredicate *roomPredacate = [TBUtility roomPredicateForCurrentTeamWithRoomId:targetID];
    MORoom *currentRoom  =[MORoom MR_findFirstWithPredicate:roomPredacate inContext:context];
    if (currentRoom) {
        currentRoom.unread = [NSNumber numberWithInt:0];
    }
    MOUser *currentMember =[MOUser findFirstWithId:targetID inContext:context];
    if (currentMember) {
        currentMember.unread = [NSNumber numberWithInt:0];
    }
}

#pragma mark - Socket for Room

- (void)roomCreateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    NSArray *memberIds = tempMessageDic[@"_memberIds"];
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
    TBRoom *newTBRoom  =[MTLJSONAdapter modelOfClass:[TBRoom class] fromJSONDictionary:tempMessageDic error:NULL];
    
    if (messageSyncContext) {
        [self saveRoomCreateWithNewRoom:newTBRoom memberIds:memberIds currentUserId:currentUserId context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveRoomCreateWithNewRoom:newTBRoom memberIds:memberIds currentUserId:currentUserId context:localContext];
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                DDLogDebug(@"successfully saved socket new room");
                [[NSNotificationCenter defaultCenter]postNotificationName:kSocketRoomCreate object:nil];
            } else if (error) {
                DDLogDebug(@"Error saved socket new room: %@", error.description);
            }
        }];
    }
}

- (void)saveRoomCreateWithNewRoom:(TBRoom *)newTBRoom memberIds:(NSArray *)memberIds currentUserId:(NSString *)currentUserId context:(NSManagedObjectContext *)context {
    // Get current team data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *teamID = [defaults valueForKey:kCurrentTeamID];
    MOTeam *moTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:teamID inContext:context];
    NSError *error;
    MORoom *newMORoom = [MTLManagedObjectAdapter managedObjectFromModel:newTBRoom insertingIntoContext:context error:&error];
    newMORoom.isQuitValue = YES;
    if ([memberIds containsObject:currentUserId]) {
        newMORoom.isQuitValue = NO;
    }
    [moTeam addRoomsObject:newMORoom];
}

- (void)roomJoinWith:(NSArray *)userDictinaryArray context:(NSManagedObjectContext *)messageSyncContext {
    __block NSError *error;
    __block BOOL findMemberInTeam = YES;
    __block BOOL isNewTeam = NO;
    
    if (messageSyncContext) {
        [userDictinaryArray enumerateObjectsUsingBlock:^(id tempMessageDic, NSUInteger idx, BOOL *stop) {
            [self saveRoomJoinWith:tempMessageDic error:error findMemberInTeam:findMemberInTeam isNewTeam:isNewTeam context:messageSyncContext];
        }];
    } else {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            [userDictinaryArray enumerateObjectsUsingBlock:^(id tempMessageDic, NSUInteger idx, BOOL *stop) {
                [self saveRoomJoinWith:tempMessageDic error:error findMemberInTeam:findMemberInTeam isNewTeam:isNewTeam context:localContext];
            }];
        }];
        
        DDLogDebug(@"successfully saved socket room:join");
        if (!findMemberInTeam) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kSocketTeamJoin object:nil];
        }
        if (isNewTeam) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kNewTeamSavedNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateOtherTeamUnread object:nil];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:kSocketRoomJoin object:nil];
    }
}

- (void)saveRoomJoinWith:(NSDictionary *)tempMessageDic error:(NSError *)error findMemberInTeam:(BOOL)findMemberInTeam isNewTeam:(BOOL)isNewTeam context:(NSManagedObjectContext*)context {
    TBUser *newTBUser  =[MTLJSONAdapter modelOfClass:[TBUser class] fromJSONDictionary:tempMessageDic error:NULL];
    NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:tempMessageDic[@"_roomId"]];
    MORoom *moRoom = [MORoom MR_findFirstWithPredicate:predicate inContext:context];
    MOTeam *moTeam;
    if (!moRoom) {
        if (tempMessageDic[@"room"]) {
            NSDictionary *roomDictionary = tempMessageDic[@"room"];
            if (roomDictionary[@"team"]) {
                moTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:[roomDictionary[@"team"] objectForKey:@"_id"] inContext:context];
                if (!moTeam) {
                    TBTeam *newTBTeam  =[MTLJSONAdapter modelOfClass:[TBTeam class] fromJSONDictionary:roomDictionary[@"team"] error:NULL];
                    moTeam= [MTLManagedObjectAdapter managedObjectFromModel:newTBTeam insertingIntoContext:context error:&error];
                    isNewTeam = YES;
                    if (![[TBUtility currentAppDelegate].allNewTeamIdArray containsObject:moTeam.id]) {
                        [[TBUtility currentAppDelegate].allNewTeamIdArray addObject:moTeam.id];
                    }
                }
                TBRoom *newTBRoom  =[MTLJSONAdapter modelOfClass:[TBRoom class] fromJSONDictionary:roomDictionary error:NULL];
                moRoom= [MTLManagedObjectAdapter managedObjectFromModel:newTBRoom insertingIntoContext:context error:&error];
                [moTeam addRoomsObject:moRoom];
            }
        }
    }
    if (moRoom) {
        MOUser *newMOUser = [MTLManagedObjectAdapter managedObjectFromModel:newTBUser insertingIntoContext:context error:&error];
        [moRoom addMembersObject:newMOUser];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([[defaults valueForKey:kCurrentUserKey] isEqualToString:newTBUser.id]) {
            moRoom.isQuit = [NSNumber numberWithBool:NO];
        }
        
        if (moTeam) {
            MOUser *tempUser = [MOUser findFirstWithId:newTBUser.id teamId:moTeam.id inContext:context];
            if (!tempUser) {
                [moTeam addUsersObject:newMOUser];
                findMemberInTeam = NO;
            }
        }
    }
}

- (void)roomUpdateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    __block  BOOL isSelfRemoved = NO;
    NSDictionary *responseDic = (NSDictionary *)tempMessageDic;
    if (messageSyncContext) {
        [self saveRoomUpdateWith:responseDic isSelfRemoved:isSelfRemoved context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveRoomUpdateWith:responseDic isSelfRemoved:isSelfRemoved context:localContext];
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kEditTopicInfoNotification object:nil];
                if (isSelfRemoved) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:kLeftPrivateRoomNotification object:nil];
                }
            }
        }];
    }
}

- (void)saveRoomUpdateWith:(NSDictionary *)responseDic isSelfRemoved:(BOOL)isSelfRemoved context:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:responseDic[@"_id"]];
    MORoom *currentRoom  = [MORoom MR_findFirstWithPredicate:predicate inContext:context];
    if (currentRoom) {
        currentRoom.topic = [responseDic objectForKey:@"topic"];
        currentRoom.purpose = [responseDic objectForKey:@"purpose"];
        currentRoom.color = [responseDic objectForKey:@"color"];
        currentRoom.isPrivate = [responseDic objectForKey:@"isPrivate"];
        
        NSArray *memberIds = [responseDic objectForKey:@"_memberIds"];
        if (memberIds) {
            NSString *currentUserID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
            if ([memberIds containsObject:currentUserID]) {
                currentRoom.isQuitValue = NO;
            } else {
                if (!currentRoom.isQuitValue) {
                    isSelfRemoved = YES;
                }
                currentRoom.isQuitValue = YES;
            }
            NSArray *previousMemberArray = [MOUser findAllInTopicWithTopicId:currentRoom.id containRobot:NO inContext:context];
            for (MOUser *previousMember in previousMemberArray) {
                [currentRoom removeMembersObject:previousMember];
            }
            for (NSString *newUserId in memberIds) {
                MOUser *user = [MOUser findFirstWithId:newUserId inContext:context];
                if (user) {
                    [currentRoom addMembersObject:user];
                }
    }
            }
        }
}

- (void)roomPrefsUpdateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    NSDictionary *responseDic = (NSDictionary *)tempMessageDic;
    
    if (messageSyncContext) {
        [self saveRoomPrefsUpdateWith:responseDic context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveRoomPrefsUpdateWith:responseDic context:localContext];
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateRoomMuteNotification object:responseDic[@"_roomId"]];
            }
        }];
    }
}

- (void)saveRoomPrefsUpdateWith:(NSDictionary *)responseDic context:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:responseDic[@"_roomId"]];
    MORoom *currentRoom  = [MORoom MR_findFirstWithPredicate:predicate inContext:context];
    if (currentRoom) {
        NSString *currentUserID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
        if ([currentUserID isEqualToString:responseDic[@"_userId"]]) {
            currentRoom.isMuteValue = [responseDic[@"isMute"] boolValue];
        }
    }
}


- (void)roomLeaveWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    __block BOOL isSelf = NO;
    
    if (messageSyncContext) {
        [self saveRoomLeaveWith:tempMessageDic isSelf:isSelf context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveRoomLeaveWith:tempMessageDic isSelf:isSelf context:localContext];
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                DDLogDebug(@"successfully saved socket room:leave");
                [[NSNotificationCenter defaultCenter]postNotificationName:kSocketRoomLeave object:nil];
                if (isSelf) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:kLeaveRoomSucceedNotification object:tempMessageDic[@"_roomId"]];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kLeftPrivateRoomNotification object:nil];
                }
            } else if (error) {
                DDLogDebug(@"Error saved socket room:leave: %@", error.description);
            }
        }];
    }
}

- (void)saveRoomLeaveWith:(NSDictionary *)tempMessageDic  isSelf:(BOOL)isSelf context:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:tempMessageDic[@"_roomId"]];
    MORoom *moRoom = [MORoom MR_findFirstWithPredicate:predicate inContext:context];
    MOUser *leaveMOUser = [MOUser findFirstWithId:tempMessageDic[@"_userId"] inContext:context];
    if (leaveMOUser) {
        [moRoom removeMembersObject:leaveMOUser];
    }
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentUserKey];
    if ([currentUserID isEqualToString:leaveMOUser.id]) {
        moRoom.isQuit = [NSNumber numberWithBool:YES];
        isSelf = YES;
    }
}

- (void)roomArchiveWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    if (messageSyncContext) {
        [self saveRoomArchiveWith:tempMessageDic context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveRoomArchiveWith:tempMessageDic context:localContext];
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                DDLogDebug(@"successfully saved socket room:Archive");
                [[NSNotificationCenter defaultCenter]postNotificationName:kSocketRoomArchive object:tempMessageDic[@"_id"]];
            } else if (error) {
                DDLogDebug(@"Error saved socket room:Archive: %@", error.description);
            }
        }];

    }}

- (void)saveRoomArchiveWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:tempMessageDic[@"_id"]];
    MORoom *moRoom = [MORoom MR_findFirstWithPredicate:predicate inContext:context];
    if (moRoom) {
        moRoom.isArchived = tempMessageDic[@"isArchived"];
    }
}

- (void)roomRemoveWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    if (messageSyncContext) {
        [self saveRoomRemoveWith:tempMessageDic context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveRoomRemoveWith:tempMessageDic context:localContext];
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                DDLogDebug(@"successfully saved socket room:Archive");
                [[NSNotificationCenter defaultCenter]postNotificationName:kSocketRoomRemove object:tempMessageDic[@"_id"]];
            } else if (error) {
                DDLogDebug(@"Error saved socket room:Archive: %@", error.description);
            }
        }];
    }
}

- (void)saveRoomRemoveWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:tempMessageDic[@"_id"]];
    MORoom *moRoom = [MORoom MR_findFirstWithPredicate:predicate inContext:context];
    if (moRoom) {
        [moRoom MR_deleteInContext:context];
    }
}

#pragma mark - Socket for User or Member

- (void)userUpdateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    NSDictionary *responseDic = (NSDictionary *)tempMessageDic;
    TBUser *newUser = [MTLJSONAdapter modelOfClass:[TBUser class]
                                fromJSONDictionary:responseDic
                                             error:NULL];
    if (messageSyncContext) {
        [self saveUserUpdateWith:responseDic user:newUser context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveUserUpdateWith:responseDic user:newUser context:localContext];
        } completion:^(BOOL success, NSError *error) {
            MOUser *user = [MOUser findFirstWithId:responseDic[@"_id"]];
            if (user) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kPersonalInfoChangeNotification object:nil];
            }
        }];
    }
}

- (void)saveUserUpdateWith:(NSDictionary *)responseDic user:(TBUser *)newUser context:(NSManagedObjectContext *)context {
    NSArray *allSameUserArray = [MOUser findAllUserWithId:responseDic[@"_id"] inContext:context];
    for (MOUser *user in allSameUserArray) {
        if (user) {
            user.name = newUser.name;
            user.avatarURL = newUser.avatarURL.absoluteString;
            user.mobile = newUser.mobile;
        }
    }
}

- (void)userUpdateWith:(NSDictionary *)tempMessageDic completion:(MRSaveCompletionHandler)completion context:(NSManagedObjectContext *)messageSyncContext {
    NSDictionary *responseDic = (NSDictionary *)tempMessageDic;
    TBUser *newUser = [MTLJSONAdapter modelOfClass:[TBUser class]
                                fromJSONDictionary:responseDic
                                             error:NULL];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *allSameUserArray = [MOUser findAllUserWithId:responseDic[@"_id"] inContext:localContext];
        for (MOUser *user in allSameUserArray) {
            if (user) {
                user.name = newUser.name;
                user.avatarURL = newUser.avatarURL.absoluteString;
                user.mobile = newUser.mobile;
            }
        }
    } completion:^(BOOL success, NSError *error) {
        completion(success, error);
    }];
}

- (void)memberUpdateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    NSDictionary *responseDic = (NSDictionary *)tempMessageDic;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentTeamID = [defaults valueForKey:kCurrentTeamID];
    
    if (messageSyncContext) {
        [self saveMemberUpdateWith:responseDic context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveMemberUpdateWith:responseDic context:localContext];
        } completion:^(BOOL success, NSError *error) {
            if ([currentTeamID isEqualToString:responseDic[@"_teamId"]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kMemberInfoChangeNotification object:nil];
            }
        }];
    }
}

- (void)saveMemberUpdateWith:(NSDictionary *)responseDic context:(NSManagedObjectContext *)context {
    MOUser *searchedMember = [MOUser findFirstWithId:responseDic[@"_userId"] teamId:responseDic[@"_teamId"] inContext:context];
    if (searchedMember) {
        searchedMember.role = responseDic[@"role"];
    }
}

#pragma mark - Socket for Invitation

-(void)invitationCreatWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    TBInvitation *newInvitation = [MTLJSONAdapter modelOfClass:[TBInvitation class] fromJSONDictionary:tempMessageDic error:NULL];
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    if (![newInvitation.teamId isEqualToString:currentTeamID]) {
        return;
    }
    
    if (messageSyncContext) {
        [MTLManagedObjectAdapter managedObjectFromModel:newInvitation insertingIntoContext:messageSyncContext error:NULL];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [MTLManagedObjectAdapter managedObjectFromModel:newInvitation insertingIntoContext:localContext error:NULL];
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                DDLogDebug(@"successfully saved socket invitation:create");
                [[NSNotificationCenter defaultCenter]postNotificationName:kSocketInvitationCreate object:nil];
            } else if (error) {
                DDLogDebug(@"Error saved socket invitation:create: %@", error.description);
            }
        }];
    }
}

- (void)invitationRemoveWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    TBInvitation *deleteInvitation = [MTLJSONAdapter modelOfClass:[TBInvitation class] fromJSONDictionary:tempMessageDic error:NULL];
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    if (![deleteInvitation.teamId isEqualToString:currentTeamID]) {
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key=%@",deleteInvitation.key];
    if (messageSyncContext) {
        [MOInvitation MR_deleteAllMatchingPredicate:predicate inContext:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [MOInvitation MR_deleteAllMatchingPredicate:predicate inContext:localContext];
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                DDLogDebug(@"successfully saved socket invitation:remove");
                [[NSNotificationCenter defaultCenter]postNotificationName:kSocketInvitationRemove object:nil];
            } else if (error) {
                DDLogDebug(@"Error saved socket invitation:remove: %@", error.description);
            }
        }];
    }
}

#pragma mark - Socket for Team

- (void)teamJoinWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    __block BOOL isNewTeam = NO;
    TBUser *newTBUser  =[MTLJSONAdapter modelOfClass:[TBUser class] fromJSONDictionary:tempMessageDic error:NULL];
    
    if (messageSyncContext) {
        [self saveTeamJoinWith:tempMessageDic newTBUser:newTBUser isNewTeam:isNewTeam context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            [self saveTeamJoinWith:tempMessageDic newTBUser:newTBUser isNewTeam:isNewTeam context:localContext];
        }];
        DDLogDebug(@"successfully saved socket team:join");
        [[NSNotificationCenter defaultCenter]postNotificationName:kSocketTeamJoin object:nil];
        if (isNewTeam) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kNewTeamSavedNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateOtherTeamUnread object:nil];
        }
    }
}

- (void)saveTeamJoinWith:(NSDictionary *)tempMessageDic newTBUser:(TBUser *)newTBUser isNewTeam:(BOOL)isNewTeam context:(NSManagedObjectContext *)context {
    MOTeam *moTeam = [MOTeam MR_findFirstByAttribute:@"id" withValue:tempMessageDic[@"_teamId"] inContext:context];
    if (!moTeam) {
        if (tempMessageDic[@"team"]) {
            TBTeam *newTeam = [MTLJSONAdapter modelOfClass:[TBTeam class] fromJSONDictionary:tempMessageDic[@"team"] error:NULL];
            moTeam =  [MTLManagedObjectAdapter managedObjectFromModel:newTeam insertingIntoContext:context error:NULL];
            isNewTeam = YES;
            if (![[TBUtility currentAppDelegate].allNewTeamIdArray containsObject:moTeam.id]) {
                [[TBUtility currentAppDelegate].allNewTeamIdArray addObject:moTeam.id];
            }
        }
    }
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] valueForKey:kCurrentTeamID];
    if ([moTeam.id isEqualToString:currentTeamID]) {
        MOUser *newMOUser = [MOUser findFirstWithId:newTBUser.id inContext:context];
        if (!newMOUser) {
            newMOUser = [MTLManagedObjectAdapter managedObjectFromModel:newTBUser insertingIntoContext:context error:NULL];
            newMOUser.isQuitValue = NO;
            [moTeam addUsersObject:newMOUser];
        } else {
            newMOUser.isQuitValue = NO;
        }
    }
}


- (void)teamUpdateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    NSDictionary *responseDic = (NSDictionary *)tempMessageDic;
    if (messageSyncContext) {
        [self saveTeamUpdateWith:responseDic context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveTeamUpdateWith:responseDic context:localContext];
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
                if ([responseDic[@"_id"] isEqualToString:currentTeamID]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kEditTeamNameNotification object:[responseDic objectForKey:@"name"]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kEditTeamNonJoinableNotification object:[responseDic objectForKey:@"nonJoinable"]];
                }
            }
        }];
    }
}

- (void)saveTeamUpdateWith:(NSDictionary *)responseDic context:(NSManagedObjectContext *)context {
    MOTeam *currentTeam  = [MOTeam MR_findFirstByAttribute:@"id" withValue:responseDic[@"_id"] inContext:context];
    currentTeam.name = [responseDic objectForKey:@"name"];
    currentTeam.color = [responseDic objectForKey:@"color"];
    currentTeam.nonJoinableValue = [[responseDic objectForKey:@"nonJoinable"] boolValue];
}

- (void)teamLeaveWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    DDLogDebug(@"teamLeave:%@", tempMessageDic);
    if (messageSyncContext) {
        [self saveTeamLeaveWith:tempMessageDic context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            [self saveTeamLeaveWith:tempMessageDic context:localContext];
        }];
    }
    
    MOUser *leaveUser = [MOUser findFirstWithId:tempMessageDic[@"_userId"] teamId:tempMessageDic[@"_teamId"]];
    if (leaveUser.isQuitValue) {
        DDLogDebug(@"****leaveUser isQuit****");
    }
    DDLogDebug(@"successfully saved socket team:leave");
    if (!messageSyncContext) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kSocketTeamLeave object:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kSocketRoomLeave object:nil];
    }
    
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    NSString *currentUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
    if ([tempMessageDic[@"_userId"] isEqualToString:currentUserID] && [currentTeamID isEqualToString:tempMessageDic[@"_teamId"]]) {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kCurrentTeamID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSUserDefaults *groupDeafaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
        [groupDeafaults setValue:nil forKey:kCurrentTeamID];
        [groupDeafaults synchronize];
        
        if (!messageSyncContext) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotInCurrentTeamNotification object:nil];
        }
    }
}

- (void)saveTeamLeaveWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)context {
    MOUser *leaveUser = [MOUser findFirstWithId:tempMessageDic[@"_userId"] teamId:tempMessageDic[@"_teamId"] inContext:context];
    if (leaveUser) {
        leaveUser.isQuitValue = YES;
    }
}

- (void)teamPinWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    NSDictionary *responseDic = (NSDictionary *)tempMessageDic;
    if (messageSyncContext) {
        [self saveTeamPinWith:responseDic context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveTeamPinWith:tempMessageDic context:localContext];
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kPinTeamColorNotification object:responseDic[@"_id"]];
            }
        }];
    }}

- (void)saveTeamPinWith:(NSDictionary *)responseDic context:(NSManagedObjectContext *)context {
    MONotification *pinnedNotification = [MONotification MR_findFirstByAttribute:@"id" withValue:responseDic[@"_id"] inContext:context];
    pinnedNotification.isPinned = @YES;
    if ([pinnedNotification.type isEqualToString:kNotificationTypeRoom]) {
        MORoom *pinnedRoom = [MORoom MR_findFirstByAttribute:@"id" withValue:pinnedNotification.targetID inContext:context];
        pinnedRoom.pinnedAt = [NSDate date];
    }
}

- (void)teamUnpinWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    NSDictionary *responseDic = (NSDictionary *)tempMessageDic;
    if (messageSyncContext) {
        [self saveTeamUnpinWith:responseDic context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveTeamUnpinWith:responseDic context:localContext];
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kUnpinTeamColorNotification object:responseDic[@"_id"]];
            }
        }];

    }}

- (void)saveTeamUnpinWith:(NSDictionary *)responseDic context:(NSManagedObjectContext *)context {
    MONotification *pinnedNotification = [MONotification MR_findFirstByAttribute:@"id" withValue:responseDic[@"_id"] inContext:context];
    pinnedNotification.isPinned = @NO;
    if ([pinnedNotification.type isEqualToString:kNotificationTypeRoom]) {
        MORoom *pinnedRoom = [MORoom MR_findFirstByAttribute:@"id" withValue:pinnedNotification.targetID inContext:context];
        pinnedRoom.pinnedAt = nil;
    }
}

- (void)teamHideWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    NSString *targetID = tempMessageDic[@"_id"];
    MONotification *removeNotification = [MONotification MR_findFirstByAttribute:@"id" withValue:targetID];
    if (!removeNotification) {
        return;
    }
    
    if (messageSyncContext) {
        MONotification *localNotification = [removeNotification MR_inContext:messageSyncContext];
        [localNotification MR_deleteInContext:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            MONotification *localNotification = [removeNotification MR_inContext:localContext];
            [localNotification MR_deleteInContext:localContext];
        } completion:^(BOOL success, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideNotification object:tempMessageDic[@"_id"]];
        }];
    }
}

- (void)teamMuteWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    NSDictionary *responseDic = (NSDictionary *)tempMessageDic;
    
    if (messageSyncContext) {
        MONotification *pinnedNotification = [MONotification MR_findFirstByAttribute:@"id" withValue:responseDic[@"_id"] inContext:messageSyncContext];
        pinnedNotification.isMute = @YES;
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            MONotification *pinnedNotification = [MONotification MR_findFirstByAttribute:@"id" withValue:responseDic[@"_id"] inContext:localContext];
            pinnedNotification.isMute = @YES;
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kMuteNotification object:responseDic[@"_id"]];
            }
        }];
    }
}

- (void)teamUnmuteWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    NSDictionary *responseDic = (NSDictionary *)tempMessageDic;
    
    if (messageSyncContext) {
        MONotification *pinnedNotification = [MONotification MR_findFirstByAttribute:@"id" withValue:responseDic[@"_id"] inContext:messageSyncContext];
        pinnedNotification.isMute = @NO;
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            MONotification *pinnedNotification = [MONotification MR_findFirstByAttribute:@"id" withValue:responseDic[@"_id"] inContext:localContext];
            pinnedNotification.isMute = @NO;
        } completion:^(BOOL success, NSError *error) {
            if (success) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kMuteNotification object:responseDic[@"_id"]];
            }
        }];
    }
}

- (void)teamPrefsUpdate:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    if (messageSyncContext) {
        [self saveTeamPrefsUpdate:tempMessageDic context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveTeamPrefsUpdate:tempMessageDic context:localContext];
        } completion:^(BOOL success, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPersonalInfoChangeNotification object:nil];
        }];
    }
}

- (void)saveTeamPrefsUpdate:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)context {
    MOUser *member = [MOUser findFirstWithId:tempMessageDic[@"_userId"] teamId:tempMessageDic[@"_teamId"] inContext:context];
    if (member) {
        if (tempMessageDic[@"alias"]) {
            NSString *newAlias = tempMessageDic[@"alias"];
            member.alias = newAlias;
        }
        if (tempMessageDic[@"hideMobile"]) {
            member.hideMobileValue = [tempMessageDic[@"hideMobile"] boolValue];
        }
    }
}

#pragma mark - Socket for Group

- (void)groupCreateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    TBGroup *tbGroup = [MTLJSONAdapter modelOfClass:[TBGroup class] fromJSONDictionary:tempMessageDic error:NULL];
    if (messageSyncContext) {
        [MTLManagedObjectAdapter managedObjectFromModel:tbGroup insertingIntoContext:messageSyncContext error:NULL];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [MTLManagedObjectAdapter managedObjectFromModel:tbGroup insertingIntoContext:localContext error:NULL];
        }];
    }
}

- (void)groupUpdateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    TBGroup *tbGroup = [MTLJSONAdapter modelOfClass:[TBGroup class] fromJSONDictionary:tempMessageDic error:NULL];
    if (messageSyncContext) {
        [MTLManagedObjectAdapter managedObjectFromModel:tbGroup insertingIntoContext:messageSyncContext error:NULL];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [MTLManagedObjectAdapter managedObjectFromModel:tbGroup insertingIntoContext:localContext error:NULL];
        }];
    }
}

- (void)groupRemoveWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)messageSyncContext {
    if (messageSyncContext) {
        [self saveGroupRemoveWith:tempMessageDic context:messageSyncContext];
    } else {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [self saveGroupRemoveWith:tempMessageDic context:localContext];
        }];
    }
}

- (void)saveGroupRemoveWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", tempMessageDic[@"id"]];
    NSArray *groups = [MOGroup MR_findAllWithPredicate:predicate inContext:context];
    for (MOGroup *group in groups) {
        [group MR_deleteInContext:context];
    }
}

#pragma mark - Socket for Activity

- (void)activityCreateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)context {
    TBTeamActivity*activity = [MTLJSONAdapter modelOfClass:[TBTeamActivity class] fromJSONDictionary:tempMessageDic error:NULL];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSocketActivityCreate object:activity];
}

- (void)activityUpdateWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)context {
    TBTeamActivity*activity = [MTLJSONAdapter modelOfClass:[TBTeamActivity class] fromJSONDictionary:tempMessageDic error:NULL];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSocketActivityUpdate object:activity];
}

- (void)activityRemoveWith:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)context {
    TBTeamActivity*activity = [MTLJSONAdapter modelOfClass:[TBTeamActivity class] fromJSONDictionary:tempMessageDic error:NULL];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSocketActivityRemove object:activity];
}

#pragma mark - socket method use for not sync message
/**
 *  socket room:create event
 *
 *  @param tempMessageDic  new room Dictinary
 */
-(void)roomCreateWith:(NSDictionary *)tempMessageDic {
    [self roomCreateWith:tempMessageDic context:nil];
}

/**
 *  socket room:update event
 *
 *  @param tempMessageDic  new room Dictinary
 */
- (void)roomUpdateWith:(NSDictionary *)tempMessageDic {
    [self roomUpdateWith:tempMessageDic context:nil];
}

/**
 *  room:join
 *
 *  @param tempMessageDic new room Dictinary
 */
-(void)roomJoinWith:(NSArray *)userDictinaryArray {
    [self roomJoinWith:userDictinaryArray context:nil];
}
/**
 *  room Prefs Update
 *
 *  @param tempMessageDic accept Dictionary
 */
- (void)roomPrefsUpdateWith:(NSDictionary *)tempMessageDic {
    [self roomPrefsUpdateWith:tempMessageDic context:nil];
}

/**
 *  socket user:update event
 *
 *  @param tempMessageDic user Dictionary
 */
- (void)userUpdateWith:(NSDictionary *)tempMessageDic {
    [self userUpdateWith:tempMessageDic context:nil];
}

/**
 *  socket user:update event
 *
 *  @param tempMessageDic user Dictionary
 *  @param completion MRSaveCompletionHandler
 */
- (void)userUpdateWith:(NSDictionary *)tempMessageDic completion:(MRSaveCompletionHandler)completion {
    [self userUpdateWith:tempMessageDic completion:completion context:nil];
}

/**
 *  socket member:update event
 *
 *  @param tempMessageDic role Dictionary
 */
- (void)memberUpdateWith:(NSDictionary *)tempMessageDic {
    [self memberUpdateWith:tempMessageDic context:nil];
}

/**
 * socket invitation:create
 *
 *  @param tempMessageDic invitation dictionary
 */
-(void)invitationCreatWith:(NSDictionary *)tempMessageDic {
    [self invitationCreatWith:tempMessageDic context:nil];
}

/**
 * socket invitation:remove
 *
 *  @param tempMessageDic invitation dictionary
 */
-(void)invitationRemoveWith:(NSDictionary *)tempMessageDic {
    [self invitationRemoveWith:tempMessageDic context:nil];
}

/**
 * socket team:join
 *
 *  @param tempMessageDic member dictionary
 */
-(void)teamJoinWith:(NSDictionary *)tempMessageDic {
    [self teamJoinWith:tempMessageDic context:nil];
}

/**
 *  socket team:leave event
 *
 *  @param tempMessageDic accept Dictionary
 */
-(void)teamLeaveWith:(NSDictionary *)tempMessageDic {
    [self teamLeaveWith:tempMessageDic context:nil];
}

/**
 *  @param tempMessageDic accept Dictionary
 */
- (void)teamPinWith:(NSDictionary *)tempMessageDic {
    [self teamPinWith:tempMessageDic context:nil];
}

/**
 *  @param tempMessageDic accept Dictionary
 */
- (void)teamUnpinWith:(NSDictionary *)tempMessageDic {
    [self teamUnpinWith:tempMessageDic context:nil];
}

/**
 *  @param tempMessageDic accept Dictionary
 */
- (void)teamMuteWith:(NSDictionary *)tempMessageDic {
    [self teamMuteWith:tempMessageDic context:nil];
}

/**
 *  @param tempMessageDic accept Dictionary
 */
- (void)teamUnmuteWith:(NSDictionary *)tempMessageDic {
    [self teamUnmuteWith:tempMessageDic context:nil];
}

/**
 *  socket story:update event
 *
 *  @param tempMessageDic accept Dictionary
 */
-(void)storyUpdateWith:(NSDictionary *)tempMessageDic {
    [self storyUpdateWith:tempMessageDic context:nil];
}

@end
