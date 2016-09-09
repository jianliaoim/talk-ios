//
//  MessageSendEngine.h
//  Talk
//
//  Created by Suric on 15/7/7.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBRecentMessage.h"
#import "TBChatImageModel.h"
#import "TBMessage.h"
#import "MOMessage.h"

@interface MessageSendEngine : NSObject

#pragma mark - MOFailMessage database operation

//save generated message to database,text message or image message
+ (void)saveGeneratedMessageToDBWith:(TBMessage *)failedMessage;
//remove generated message from database
+ (void)removeGeneratedMessageFromDBWith:(TBMessage *)sendSucceedMessage;
//update fail message sendStatus with Bool
+ (void)updateFailedMessage:(TBMessage *)sendSucceedMessage withIsSending:(BOOL)isSending;

#pragma mark - Message Transform

//get TBRecentMessage for MOFialMessage
+ (TBRecentMessage *)getTBRecentMessageFormMOMessage:(MOMessage *)failedMessage;
//get TBRecentMessage for TBMessage
+ (TBRecentMessage *)getTBRecentMessageFromMessage:(TBMessage *)message;

#pragma mark - Send text to server

+ (void)sendTextMessageToServerWithParameters:(NSDictionary *)tempParamsDic andMessage:(TBMessage *)message;

#pragma mark - Send image to server

+ (void)sendImageWithImageModel:(TBChatImageModel *)imageModel andMessage:(TBMessage *)message andPatameters:(NSMutableDictionary *)params;

#pragma mark - Send voice to server

+ (void)sendVoiceWithData:(NSData *)data Name:(NSString *)name message:(TBMessage *)message andPatameters:(NSMutableDictionary *)params;

@end
