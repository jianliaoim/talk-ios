//
//  MessageSendEngine.m
//  Talk
//
//  Created by Suric on 15/7/7.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "MessageSendEngine.h"
#import "TBHTTPSessionManager.h"
#import "constants.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "TBUtility.h"
#import "DDLog.h"
#import "TBImageTableViewCell.h"
#import "TbChatTableViewCell.h"
#import "TBVoiceCell.h"
#import "TBFileSessionManager.h"

#import "MOMessage.h"
#import "TBRecentMessage.h"
#import "MOUser.h"
#import "TBUser.h"
#import "TBMessage.h"
#import "TBFile.h"

@implementation MessageSendEngine

#pragma mark - MOFailMessage database operation

//save generated message to database,text message or image message
+ (void)saveGeneratedMessageToDBWith:(TBMessage *)generatedMessage
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MOMessage *message = [MTLManagedObjectAdapter managedObjectFromModel:generatedMessage insertingIntoContext:localContext error:nil];
        message.id = message.uuid;
        DDLogDebug(message.uuid);
    } completion:^(BOOL success, NSError *error) {
        DDLogDebug(@"save sending Generated Message Succeed");
    }];
}

//update fail message sendStatus with Bool
+ (void)updateFailedMessage:(TBMessage *)sendMessage withIsSending:(BOOL)isSending
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MOMessage *failedMessage = [MOMessage MR_findFirstByAttribute:@"uuid" withValue:sendMessage.uuid inContext:localContext];
        if (failedMessage) {
            if (isSending) {
                failedMessage.sendStatus = [NSNumber numberWithInteger:sendStatusSending];
            } else {
                failedMessage.sendStatus = [NSNumber numberWithInteger:sendStatusFailed];
            }
        }
    } completion:^(BOOL success, NSError *error) {
        DDLogDebug(@"update message sendStatus succeed");
    }];
}

//remove generated message from database
 + (void)removeGeneratedMessageFromDBWith:(TBMessage *)sendSucceedMessage
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        MOMessage *failedMessage = [MOMessage MR_findFirstByAttribute:@"uuid" withValue:sendSucceedMessage.uuid inContext:localContext];
        [failedMessage MR_deleteInContext:localContext];
    } completion:^(BOOL success, NSError *error) {
        DDLogDebug(@"remove generated message succeed");
    }];
}

#pragma mark - Message Transform

//get TBRecentMessage for MOFialMessage
+ (TBRecentMessage *)getTBRecentMessageFormMOMessage:(MOMessage *)failedMessage
{
    TBRecentMessage *newMessage  =[[TBRecentMessage alloc]init];
    newMessage.createdAt = failedMessage.createdAt;
    newMessage.body = failedMessage.messageStr;
    newMessage.creatorID = failedMessage.creatorID;
    newMessage.teamID = failedMessage.teamID;
    newMessage.roomID = failedMessage.roomID;
    newMessage.toID = failedMessage.toID;
    newMessage.sendStatus = [NSNumber numberWithInteger:sendStatusFailed];
//    if ([failedMessage.duration intValue] > 0) {
//        TBAttachment *imageAttachment = [[TBAttachment alloc]init];
//        imageAttachment.category = kDisplayModeSpeech;
//        newMessage.attachments = [NSArray arrayWithObject:imageAttachment];
//    }
//    if (failedMessage.sendImage) {
//        TBAttachment *imageAttachment = [[TBAttachment alloc]init];
//        imageAttachment.category = kDisplayModeFile;
//        imageAttachment.data = [NSDictionary dictionaryWithObjectsAndKeys:kFileCategoryImage,kFileCategory,nil];
//        newMessage.attachments = [NSArray arrayWithObject:imageAttachment];
//    }

    MOUser *failedMessageCreator = [MOUser findFirstWithId:failedMessage.creatorID];
    newMessage.creator = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:failedMessageCreator error:NULL];
    
    return newMessage;
}

//get TBRecentMessage for TBMessage
+ (TBRecentMessage *)getTBRecentMessageFromMessage:(TBMessage *)message {
    TBRecentMessage *newMessage  =[[TBRecentMessage alloc]init];
    newMessage.createdAt = message.createdAt;
    newMessage.body = message.messageStr;
    newMessage.creatorID = message.creatorID;
    newMessage.teamID = message.teamID;
    newMessage.roomID = message.roomID;
    newMessage.toID = message.toID;
    newMessage.sendStatus = [NSNumber numberWithInteger:message.sendStatus];
    newMessage.attachments = message.attachments;
    MOUser *failedMessageCreator = [MOUser findFirstWithId:message.creatorID];
    newMessage.creator = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:failedMessageCreator error:NULL];
    
    return newMessage;
}

#pragma mark - Send text to server

+ (void)sendTextMessageToServerWithParameters:(NSDictionary *)tempParamsDic andMessage:(TBMessage *)resendMessage {
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    [manager POST:kSendMessageURLString parameters:tempParamsDic success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"responseObject%@",responseObject);
        TBMessage *message = [MTLJSONAdapter modelOfClass:[TBMessage class]
                                       fromJSONDictionary:responseObject
                                                    error:NULL];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSError *error;
            MOMessage *moMessage = [MTLManagedObjectAdapter
                                    managedObjectFromModel:message
                                    insertingIntoContext:localContext
                                    error:&error];
            if (moMessage==nil) {
                DDLogDebug(@"acceptSocketMessageSave Error:%@",error);
            }
        } completion:^(BOOL success, NSError *error) {
            [MessageSendEngine removeGeneratedMessageFromDBWith:resendMessage];
            //tell recentMessageView have send a message
            NSArray *objectArray = [NSArray arrayWithObjects:responseObject,resendMessage,message, nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:kSendMessageSucceedNotification object:objectArray];
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"error%@",error);
        //tell recentMessageView fail to send a message
        resendMessage.sendStatus = sendStatusFailed;
        [MessageSendEngine updateFailedMessage:resendMessage withIsSending:NO];
        NSArray *objectArray = [NSArray arrayWithObjects:resendMessage,error, nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kSendMessageFailedNotification object:objectArray];
    }];
}

#pragma mark - Send image to server

+ (void)sendImageWithImageModel:(TBChatImageModel *)imageModel andMessage:(TBMessage *)message andPatameters:(NSMutableDictionary *)params
{
    [[TBFileSessionManager sharedManager] POST:kUploadURLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *imageData = UIImageJPEGRepresentation(message.sendImage, 0.5);
        [formData appendPartWithFileData:imageData name:@"file" fileName:imageModel.imageName mimeType:[NSString stringWithFormat:@"image/%@",@"jpg"]];
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"JSON: %@", responseObject);
        TBFile *imageFile  = [MTLJSONAdapter modelOfClass:[TBFile class]
                                       fromJSONDictionary:responseObject
                                                    error:NULL];
        //message.fileKey = imageFile.fileKey;
        NSDictionary *fileDictionary = [NSDictionary dictionaryWithObjectsAndKeys:imageFile.fileKey,@"fileKey",
                                        imageFile.fileName,@"fileName",
                                        imageFile.fileType,@"fileType",
                                        imageFile.fileSize,@"fileSize",
                                        imageFile.fileCategory,@"fileCategory",
                                        imageFile.imageWidth,@"imageWidth",
                                        imageFile.imageHeight,@"imageHeight", nil];
        NSDictionary *attachmentDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"file",@"category",
                                              fileDictionary,@"data",nil];
        NSArray *attachmentArray = [NSArray arrayWithObject:attachmentDictionary];
        [params setValue:attachmentArray forKey:@"attachments"];
        [self sendImageToServerWithFile:imageFile andMessage:message andPatameters:params];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Error: %@", error);
        //tell recentMessageView fail to send a message
        message.sendStatus = sendStatusFailed;
        [MessageSendEngine updateFailedMessage:message withIsSending:NO];
        NSArray *objectArray = [NSArray arrayWithObjects:message,error, nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kSendMessageFailedNotification object:objectArray];
    }];
}

+ (void)sendImageToServerWithFile:(TBFile *)tbfile andMessage:(TBMessage *)sendMessage andPatameters:(NSDictionary *)params
{
    [[TBHTTPSessionManager sharedManager]POST:kSendMessageURLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"responseObject%@",responseObject);
        TBMessage *returnMessage = [MTLJSONAdapter modelOfClass:[TBMessage class]
                                       fromJSONDictionary:responseObject
                                                    error:NULL];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSError *error;
            MOMessage *moMessage = [MTLManagedObjectAdapter
                                    managedObjectFromModel:returnMessage
                                    insertingIntoContext:localContext
                                    error:&error];
            if (moMessage==nil) {
                DDLogDebug(@"acceptSocketMessageSave Error:%@",error);
            }
        } completion:^(BOOL success, NSError *error) {
            [MessageSendEngine removeGeneratedMessageFromDBWith:sendMessage];
            //tell recentMessageView have send a message
            NSArray *objectArray = [NSArray arrayWithObjects:responseObject,sendMessage,returnMessage, nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:kSendMessageSucceedNotification object:objectArray];
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"error%@",error);
        //tell recentMessageView fail to send a message
        sendMessage.sendStatus = sendStatusFailed;
        [MessageSendEngine updateFailedMessage:sendMessage withIsSending:NO];
        NSArray *objectArray = [NSArray arrayWithObjects:sendMessage,error, nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kSendMessageFailedNotification object:objectArray];

    }];
}

#pragma mark - Send voice to server
+ (void)sendVoiceWithData:(NSData *)data Name:(NSString *)name message:(TBMessage *)message andPatameters:(NSMutableDictionary *)params
{
    [[TBFileSessionManager sharedManager]POST:kUploadURLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:name mimeType:[NSString stringWithFormat:@"audio/%@",@"amr"]];
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"JSON: %@", responseObject);
        TBFile *voiceFile  = [MTLJSONAdapter modelOfClass:[TBFile class]
                                       fromJSONDictionary:responseObject
                                                    error:NULL];
        //message.fileKey = voiceFile.fileKey;
        [self sendVoiceToServerWithFile:voiceFile VoiceMessage:message andPatameters:params];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"Error: %@", error);
        //tell recentMessageView fail to send a message
        message.sendStatus = sendStatusFailed;
        [MessageSendEngine updateFailedMessage:message withIsSending:NO];
        NSArray *objectArray = [NSArray arrayWithObjects:message,error, nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kSendMessageFailedNotification object:objectArray];
    }];
}

+ (void)sendVoiceToServerWithFile:(TBFile *)tbfile VoiceMessage:(TBMessage *)sendMessage andPatameters:(NSMutableDictionary *)params
{
    NSInteger voiceDuration = sendMessage.duration;
    NSDictionary *fileDictionary = [NSDictionary dictionaryWithObjectsAndKeys:tbfile.fileKey,@"fileKey",
                                    tbfile.fileName,@"fileName",
                                    tbfile.fileType,@"fileType",
                                    tbfile.fileSize,@"fileSize",
                                    tbfile.fileCategory,@"fileCategory",
                                    @YES,@"isSpeech",
                                    [NSNumber numberWithInteger:voiceDuration],@"duration", nil];
    NSDictionary *attachmentDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"speech",@"category",
                                          fileDictionary,@"data",nil];
    NSArray *attachmentArray = [NSArray arrayWithObject:attachmentDictionary];
    [params setValue:attachmentArray forKey:@"attachments"];
    
    [[TBHTTPSessionManager sharedManager]POST:kSendMessageURLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogDebug(@"upload voice succeed responseObject%@",responseObject);
        TBMessage *returnMessage = [MTLJSONAdapter modelOfClass:[TBMessage class]
                                       fromJSONDictionary:responseObject
                                                    error:NULL];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            NSError *error;
            MOMessage *moMessage = [MTLManagedObjectAdapter
                                    managedObjectFromModel:returnMessage
                                    insertingIntoContext:localContext
                                    error:&error];
            if (moMessage==nil) {
                DDLogDebug(@"acceptSocketMessageSave Error:%@",error);
            }
        } completion:^(BOOL success, NSError *error) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:sendMessage.voiceLocalAMRPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:sendMessage.voiceLocalAMRPath error:NULL];
            }
            [MessageSendEngine removeGeneratedMessageFromDBWith:sendMessage];
            //tell recentMessageView have send a message
            NSArray *objectArray = [NSArray arrayWithObjects:responseObject,sendMessage,returnMessage, nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:kSendMessageSucceedNotification object:objectArray];
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogDebug(@"upload voice error%@",error);
        //tell recentMessageView and ChatViewController fail to send a message
        sendMessage.sendStatus = sendStatusFailed;
        [MessageSendEngine updateFailedMessage:sendMessage withIsSending:NO];
        NSArray *objectArray = [NSArray arrayWithObjects:sendMessage,error, nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:kSendMessageFailedNotification object:objectArray];
    }];
}

@end
