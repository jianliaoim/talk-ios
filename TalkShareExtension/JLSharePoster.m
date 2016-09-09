//
//  JLSharePoster.m
//  Talk
//
//  Created by 王卫 on 15/11/27.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "JLSharePoster.h"
#import "JLShareSessionManager.h"
#import "ShareConstants.h"

static NSString * const kTextIdentyfier = @"com.jianliao.TalK.BackgroudMessageTextSession";
static NSString * const kImageIdentyfier = @"com.jianliao.TalK.BackgroudMessageImageSession";
static NSString * const kFileIdentyfier = @"com.jianliao.TalK.BackgroudMessageFileSession";
static NSString * const kUploadImageIdentyfier = @"com.jianliao.TalK.BackgroudUploadImageSession";
static NSString * const kUploadFileIdentyfier = @"com.jianliao.TalK.BackgroudUploadFileSession";

@interface JLSharePoster () <NSURLSessionTaskDelegate>

@end

@implementation JLSharePoster

+ (instancetype)sharedPoster {
    static JLSharePoster *sharedPoster = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPoster = [[JLSharePoster alloc] init];
    });
    return sharedPoster;
}

- (void)createStoryWithLink:(NSString *)link title:(NSString *)title {
    NSMutableDictionary *storyData = [NSMutableDictionary new];
    NSString *category = kStoryCategoryTopic;
    if (link) {
        category = kStoryCategoryLink;
        [storyData setObject:link forKey:@"url"];
    }
    if (title) {
        [storyData setObject:title forKey:@"title"];
    }
    NSDictionary *param = @{@"_teamId":self.selectedTeamId,
                            @"category":category,
                            @"data":storyData.copy,
                            @"_memberIds":self.memberIds};
    NSData *paramsData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];;
    NSMutableURLRequest *request = [JLShareSessionManager requestWithURLString:kStoryCreateURLString];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:paramsData];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@%@",kTextIdentyfier,[NSUUID UUID].UUIDString]];
    configuration.sharedContainerIdentifier = kTalkGroupID;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *sendTask = [session dataTaskWithRequest:request];
    [sendTask resume];
}

- (void)createStoryWithIdea:(NSString *)idea {
    NSMutableDictionary *storyData = [NSMutableDictionary new];
    if (idea) {
        [storyData setObject:idea forKey:@"title"];
    }
    NSDictionary *param = @{@"_teamId":self.selectedTeamId,
                            @"category":kStoryCategoryTopic,
                            @"data":storyData.copy,
                            @"_memberIds":self.memberIds};
    NSData *paramsData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];;
    NSMutableURLRequest *request = [JLShareSessionManager requestWithURLString:kStoryCreateURLString];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:paramsData];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@%@",kTextIdentyfier,[NSUUID UUID].UUIDString]];
    configuration.sharedContainerIdentifier = kTalkGroupID;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *sendTask = [session dataTaskWithRequest:request];
    [sendTask resume];

}

-(void)sendTextMessageToServer:(NSString *)messageText
{
    NSMutableArray *contentArray  = [NSMutableArray arrayWithObject:messageText];
    NSDictionary *tempParamsDic;
    NSString *contentKey = @"body";
    if (self.selectedRoomId) {
        tempParamsDic = [NSDictionary dictionaryWithObjectsAndKeys:self.selectedRoomId,@"_roomId",
                         contentArray,contentKey,nil];
    }
    else
    {
        tempParamsDic = [NSDictionary dictionaryWithObjectsAndKeys:self.selectedMemberId,@"_toId",
                         self.selectedMemberId,@"_teamId",
                         contentArray,contentKey,nil];
    }
    
    NSData *paramsData = [NSJSONSerialization dataWithJSONObject:tempParamsDic options:NSJSONWritingPrettyPrinted error:nil];;
    NSMutableURLRequest *request = [JLShareSessionManager requestWithURLString:kSendMessageURLString];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:paramsData];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@%@",kTextIdentyfier,[NSUUID UUID].UUIDString]];
    configuration.sharedContainerIdentifier = kTalkGroupID;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *sendTask = [session dataTaskWithRequest:request];
    [sendTask resume];
}

- (void)sendImageDataToStriker: (NSData *)imageData andName: (NSString *)imageName  isImage:(BOOL)isImage {
    NSUserDefaults *groupDefaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
    [groupDefaults setObject:self.selectedTeamId forKey:kSelectedTeamInfo];
    [groupDefaults setObject:self.selectedRoomId forKey:kSelectedRoomInfo];
    [groupDefaults setObject:self.selectedMemberId forKey:kSelectedMemberInfo];
    [groupDefaults synchronize];
    
    NSURL *url = [NSURL URLWithString:kUploadURLString];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    NSString *filename = [NSString stringWithFormat:@"%@",imageName];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\" filename=\"%@\"\r\n",filename]] dataUsingEncoding:NSUTF8StringEncoding]];
    if (isImage) {
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    } else {
        [body appendData:[@"Content-Type: application/json\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSURLSessionConfiguration *configuration;
    if (isImage) {
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@%@",kUploadImageIdentyfier,[NSUUID UUID].UUIDString]];
    } else {
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@%@",kUploadFileIdentyfier,[NSUUID UUID].UUIDString]];
    }
    configuration.sharedContainerIdentifier = kTalkGroupID;
    NSURLSession *uploadSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSessionUploadTask *upLoadTask = [uploadSession uploadTaskWithStreamedRequest:request];
    [upLoadTask resume];
}

- (void)createStoryWithFileInfo:(NSDictionary *)fileInfo isImage:(BOOL)isImage {
    NSDictionary *param = @{@"_teamId":self.selectedTeamId,
                            @"category":kStoryCategoryFile,
                            @"data":fileInfo.copy,
                            @"_memberIds":self.memberIds};
    NSData *paramsData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    NSMutableURLRequest *request = [JLShareSessionManager requestWithURLString:kStoryCreateURLString];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:paramsData];
    NSURLSessionConfiguration *configuration;
    if (isImage) {
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@%@",kImageIdentyfier,[NSUUID UUID].UUIDString]];
    } else {
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@%@",kFileIdentyfier,[NSUUID UUID].UUIDString]];
    }
    configuration.sharedContainerIdentifier = kTalkGroupID;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *sendTask = [session dataTaskWithRequest:request];
    [sendTask resume];
}

- (void)sendImageInfoToServerWith:(NSDictionary *)imageDic andIsImage:(BOOL)isImage {
    NSUserDefaults *groupDefaults = [[NSUserDefaults alloc]initWithSuiteName:kTalkGroupID];
    NSString *teamId = [groupDefaults objectForKey:kSelectedTeamInfo];
    NSString *roomId = [groupDefaults objectForKey:kSelectedRoomInfo];
    NSString *memberId = [groupDefaults objectForKey:kSelectedMemberInfo];
    
    NSMutableDictionary *tempParamsDic;
    if (roomId) {
        tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         teamId,@"_teamId",
                         roomId,@"_roomId",nil];
    }
    else
    {
        tempParamsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         memberId,@"_toId",
                         teamId,@"_teamId",nil];
    }
    NSDictionary *fileDictionary;
    if (isImage) {
        fileDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                          imageDic[@"fileKey"],@"fileKey",
                          imageDic[@"fileName"],@"fileName",
                          imageDic[@"fileType"],@"fileType",
                          imageDic[@"fileSize"],@"fileSize",
                          imageDic[@"fileCategory"],@"fileCategory",
                          imageDic[@"imageWidth"],@"imageWidth",
                          imageDic[@"imageHeight"],@"imageHeight", nil];
    } else {
        fileDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                          imageDic[@"fileKey"],@"fileKey",
                          imageDic[@"fileName"],@"fileName",
                          imageDic[@"fileType"],@"fileType",
                          imageDic[@"fileSize"],@"fileSize",
                          imageDic[@"fileCategory"],@"fileCategory", nil];
    }
    
    NSDictionary *attachmentDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"file",@"category",
                                          fileDictionary,@"data",nil];
    NSArray *attachmentArray = [NSArray arrayWithObject:attachmentDictionary];
    [tempParamsDic setValue:attachmentArray forKey:@"attachments"];
    NSData *paramsData = [NSJSONSerialization dataWithJSONObject:tempParamsDic options:NSJSONWritingPrettyPrinted error:nil];;
    NSMutableURLRequest *request = [JLShareSessionManager requestWithURLString:kSendMessageURLString];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:paramsData];
    
    NSURLSessionConfiguration *configuration;
    if (isImage) {
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@%@",kImageIdentyfier,[NSUUID UUID].UUIDString]];
    } else {
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%@%@",kFileIdentyfier,[NSUUID UUID].UUIDString]];
    }
    configuration.sharedContainerIdentifier = kTalkGroupID;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *sendTask = [session dataTaskWithRequest:request];
    [sendTask resume];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    NSLog(@"upload percent: %f",(float)totalBytesSent/totalBytesExpectedToSend);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    if (!error) {
        NSLog(@"Session:%@ success",session.configuration.identifier);
    } else {
        NSLog(@"Session:%@ failed",session.configuration.identifier);
    }
    if ([self.delegate respondsToSelector:@selector(hideExtensionAfterPost)]) {
        [self.delegate hideExtensionAfterPost];
    }
}

- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [session finishTasksAndInvalidate];
    // upload file success
    if ([session.configuration.identifier containsString:kUploadFileIdentyfier]) {
        NSError *error = nil;
        NSDictionary *fileDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (self.isCreateStory) {
            [self createStoryWithFileInfo:fileDic isImage:NO];
        } else {
            [self sendImageInfoToServerWith:fileDic andIsImage:NO];
        }
    }
    //upload image success
    else if ([session.configuration.identifier containsString:kUploadImageIdentyfier]) {
        [session finishTasksAndInvalidate];
        NSDictionary *imageDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (self.isCreateStory) {
            [self createStoryWithFileInfo:imageDic isImage:YES];
        } else {
            [self sendImageInfoToServerWith:imageDic andIsImage:YES];
        }
    }
    //send image message success
    else if ([session.configuration.identifier containsString:kTextIdentyfier]) {
        NSLog(@"*** Text send success ***");
    }
    //send image message success
    else if ([session.configuration.identifier containsString:kImageIdentyfier]) {
        NSLog(@"*** image send success ***");
        if ([self.delegate respondsToSelector:@selector(hideExtensionAfterPost)]) {
            [self.delegate hideExtensionAfterPost];
        }
    }
    //send file message success
    else if ([session.configuration.identifier containsString:kFileIdentyfier]) {
        NSLog(@"*** file send success***");
        if ([self.delegate respondsToSelector:@selector(hideExtensionAfterPost)]) {
            [self.delegate hideExtensionAfterPost];
        }
    }
}


@end
