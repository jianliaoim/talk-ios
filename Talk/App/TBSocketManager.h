//
// Created by Shire on 9/19/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketRocket/SRWebSocket.h"
#import <CoreData+MagicalRecord.h>

@interface TBSocketManager : NSObject

@property(nonatomic,strong) SRWebSocket *webSocket;
+ (TBSocketManager *)sharedManager;
//for only open once
-(void)openSocket;
-(void)closeSocket;

#pragma mark - Socket Action

- (void)socketActionWithMessageDic:(NSDictionary *)tempMessageDic context:(NSManagedObjectContext *)context;

#pragma mark - socket method use for not sync message

/**
 *  socket room:create event
 *
 *  @param tempMessageDic  new room Dictinary
 */
-(void)roomCreateWith:(NSDictionary *)tempMessageDic;

/**
 *  socket room:update event
 *
 *  @param tempMessageDic  new room Dictinary
 */
- (void)roomUpdateWith:(NSDictionary *)tempMessageDic;

/**
 *  room:join
 *
 *  @param tempMessageDic new room Dictinary
 */
-(void)roomJoinWith:(NSArray *)userDictinaryArray;
/**
 *  room Prefs Update
 *
 *  @param tempMessageDic accept Dictionary
 */
- (void)roomPrefsUpdateWith:(NSDictionary *)tempMessageDic;

/**
 *  socket user:update event
 *
 *  @param tempMessageDic user Dictionary
 */
- (void)userUpdateWith:(NSDictionary *)tempMessageDic;

/**
 *  socket user:update event
 *
 *  @param tempMessageDic user Dictionary
 *  @param completion MRSaveCompletionHandler
 */
- (void)userUpdateWith:(NSDictionary *)tempMessageDic completion:(MRSaveCompletionHandler)completion;

/**
 *  socket member:update event
 *
 *  @param tempMessageDic role Dictionary
 */
- (void)memberUpdateWith:(NSDictionary *)tempMessageDic;

/**
 * socket invitation:create
 *
 *  @param tempMessageDic invitation dictionary
 */
-(void)invitationCreatWith:(NSDictionary *)tempMessageDic;

/**
 * socket invitation:remove
 *
 *  @param tempMessageDic invitation dictionary
 */
-(void)invitationRemoveWith:(NSDictionary *)tempMessageDic;

/**
 * socket team:join
 *
 *  @param tempMessageDic member dictionary
 */
-(void)teamJoinWith:(NSDictionary *)tempMessageDic;

/**
 *  socket team:leave event
 *
 *  @param tempMessageDic accept Dictionary
 */
-(void)teamLeaveWith:(NSDictionary *)tempMessageDic;

/**
 *  @param tempMessageDic accept Dictionary
 */
- (void)teamPinWith:(NSDictionary *)tempMessageDic;

/**
 *  @param tempMessageDic accept Dictionary
 */
- (void)teamUnpinWith:(NSDictionary *)tempMessageDic;

/**
 *  @param tempMessageDic accept Dictionary
 */
- (void)teamMuteWith:(NSDictionary *)tempMessageDic;

/**
 *  @param tempMessageDic accept Dictionary
 */
- (void)teamUnmuteWith:(NSDictionary *)tempMessageDic;

/**
 *  socket story:update event
 *
 *  @param tempMessageDic accept Dictionary
 */
-(void)storyUpdateWith:(NSDictionary *)tempMessageDic;

@end
