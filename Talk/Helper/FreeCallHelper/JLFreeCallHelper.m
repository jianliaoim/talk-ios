//
//  JLFreeCallHelper.m
//  Talk
//
//  Created by 史丹青 on 9/22/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "JLFreeCallHelper.h"
#import "constants.h"
#import "TBHTTPSessionManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "XMLDictionary.h"
#import "ReactiveCocoa.h"
#import "JSONResponseSerializerWithData.h"

@interface JLFreeCallHelper () <NSXMLParserDelegate>

@property (nonatomic, copy) NSString *SubAccountSid;
@property (nonatomic, copy) NSString *SubAccountToken;
@property (nonatomic, copy) NSString *ConferenceId;

@end

@implementation JLFreeCallHelper

- (instancetype)init {
    return self;
}

#pragma mark - Getter

- (NSString *)SubAccountSid {
    return [[NSUserDefaults standardUserDefaults] stringForKey:KYTXSubAccountSid];
}

- (NSString *)SubAccountToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kYTXSubAccountToken];
}

#pragma mark - Public

- (RACSignal *)callFrom:(NSString *)fromPhone To:(NSString *)toPhone {
    NSDictionary *param = @{@"from":fromPhone,@"to":toPhone, @"customerSerNum": kYTXShowPhoneNumber, @"fromSerNum": kYTXShowPhoneNumber};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:[self getAuthorizationWithSid:self.SubAccountSid] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json;" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json;charset=utf-8;" forHTTPHeaderField:@"Content-Type"];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [manager POST:[NSString stringWithFormat:kYTXCallURLString, self.SubAccountSid, [self getSignatureWithSid:self.SubAccountSid withToken:self.SubAccountToken]] parameters:param success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
            DDLogDebug(responseObject[@"statusCode"]);
            if ([responseObject[@"statusCode"] isEqualToString:@"000000"]) {
                NSDictionary *callback = responseObject[@"CallBack"];
                [[NSUserDefaults standardUserDefaults] setValue:callback[@"callSid"] forKey:kYTXCallSid];
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            } 
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)cancelCall {
    NSDictionary *param = @{@"appId":kYTXAppId, @"callSid": [[NSUserDefaults standardUserDefaults] stringForKey:kYTXCallSid]};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:[self getAuthorizationWithSid:self.SubAccountSid] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/json;" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json;charset=utf-8;" forHTTPHeaderField:@"Content-Type"];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [manager POST:[NSString stringWithFormat:kYTXCancelCallURLString, self.SubAccountSid, [self getSignatureWithSid:self.SubAccountSid withToken:self.SubAccountToken]]  parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
    
}

- (RACSignal *)creatConference {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kYTXCreateConferenceURLString, kYTXAccountSid, [self getSignatureWithSid:kYTXAccountSid withToken:kYTXAccountToken]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/xml;charset=utf-8;" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/xml;" forHTTPHeaderField:@"Accept"];
    [request setValue:[self getAuthorizationWithSid:kYTXAccountSid] forHTTPHeaderField:@"Authorization"];
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF-8'?>"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"<Request>"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"<Appid>%@</Appid>", kYTXAppId] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"<CreateConf action=\"createconfresult.jsp\" maxmember=\"20\"/>"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"</Request>"] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:request
                                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                               NSLog(@"Response:%@ %@\n", response, error);
                                                               if(error == nil)
                                                               {
                                                                   NSString * xmlString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                                   NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLString:xmlString];
                                                                   self.ConferenceId = xmlDic[@"confid"];
                                                                   if ([xmlDic[@"statusCode"] isEqualToString:@"000000"]) {
                                                                       [subscriber sendNext:nil];
                                                                       [subscriber sendCompleted];
                                                                   } else {
                                                                       //failure
                                                                       [subscriber sendError:nil];
                                                                   }
                                                               } else {
                                                                   [subscriber sendError:error];
                                                               }
                                                           }];
        [dataTask resume];
        return nil;
    }];
    
}

- (RACSignal *)invitePhoneNumbers:(NSArray *)phoneNumberArray {
    NSMutableString *phoneString = [[NSMutableString alloc] init];
    for (NSString *phoneNumber in phoneNumberArray) {
        [phoneString appendString:[NSString stringWithFormat:@"%@#",phoneNumber]];
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kYTXInviteMemberURLString, kYTXAccountSid, [self getSignatureWithSid:kYTXAccountSid withToken:kYTXAccountToken], self.ConferenceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/xml;charset=utf-8;" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/xml;" forHTTPHeaderField:@"Accept"];
    [request setValue:[self getAuthorizationWithSid:kYTXAccountSid] forHTTPHeaderField:@"Authorization"];
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF-8'?>"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"<Request>"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"<Appid>%@</Appid>", kYTXAppId] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"<InviteJoinConf confid=\"%@\" number=\"%@\"/>", self.ConferenceId, phoneString] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"</Request>"] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:request
                                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                               NSLog(@"Response:%@ %@\n", response, error);
                                                               if(error == nil)
                                                               {
                                                                   NSString * xmlString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                                   NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLString:xmlString];
                                                                   if ([xmlDic[@"statusCode"] isEqualToString:@"000000"]) {
                                                                       [subscriber sendNext:nil];
                                                                       [subscriber sendCompleted];
                                                                   } else {
                                                                       [subscriber sendError:nil];
                                                                   }
                                                               } else {
                                                                   [subscriber sendError:error];
                                                               }
                                                               
                                                           }];
        [dataTask resume];
        return nil;
    }];
}

- (RACSignal *)cancelConference {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kYTXInviteMemberURLString, kYTXAccountSid, [self getSignatureWithSid:kYTXAccountSid withToken:kYTXAccountToken], self.ConferenceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/xml;charset=utf-8;" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/xml;" forHTTPHeaderField:@"Accept"];
    [request setValue:[self getAuthorizationWithSid:kYTXAccountSid] forHTTPHeaderField:@"Authorization"];
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"<?xml version='1.0' encoding='UTF-8'?>"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"<Request>"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"<Appid>%@</Appid>", kYTXAppId] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"<DismissConf confid=\"%@\"/>", self.ConferenceId] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"</Request>"] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:request
                                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                               NSLog(@"Response:%@ %@\n", response, error);
                                                               if(error == nil)
                                                               {
                                                                   NSString * xmlString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                                   NSDictionary *xmlDic = [NSDictionary dictionaryWithXMLString:xmlString];
                                                                   if ([xmlDic[@"statusCode"] isEqualToString:@"000000"]) {
                                                                       [subscriber sendNext:nil];
                                                                       [subscriber sendCompleted];
                                                                   } else {
                                                                       [subscriber sendError:nil];
                                                                   }
                                                               } else {
                                                                   [subscriber sendError:error];
                                                               }
                                                               
                                                           }];
        [dataTask resume];
        return nil;
    }];
    
}

#pragma mark - Private

- (NSString *)getSignatureWithSid:(NSString *)accountSid withToken:(NSString *)token {
    NSString *timestamp = [self getTimeStamp];
    NSString *signatureString = [NSString stringWithFormat:@"%@%@%@",accountSid,token,timestamp];
    return [self md5:signatureString];
}

- (NSString *)getAuthorizationWithSid:(NSString *)accountSid {
    NSString *timestamp = [self getTimeStamp];
    NSString *authorizationString = [NSString stringWithFormat:@"%@:%@",accountSid,timestamp];
    return [self encodeBase64:authorizationString];
}

- (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}

- (NSString *)encodeBase64:(NSString *)str {
    NSData *plainData = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [plainData base64EncodedStringWithOptions:0];
}

- (NSString *)getTimeStamp {
    NSDate* now = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMddHHmmss"];
    return [dateFormat stringFromDate:now];
}

@end
