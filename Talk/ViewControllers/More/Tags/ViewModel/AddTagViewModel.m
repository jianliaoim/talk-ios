//
//  AddTagViewModel.m
//  Talk
//
//  Created by 史丹青 on 7/13/15.
//  Copyright (c) 2015 jiaoliao. All rights reserved.
//

#import "AddTagViewModel.h"
#import "TBHTTPSessionManager.h"
#import "constants.h"
#import "TBTag.h"
#import "Mantle.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "TBMessage.h"
#import "MOMessage.h"

@implementation AddTagViewModel

- (instancetype)init {
    self = [super init];
    [self initialize];
    return self;
}

- (void)initialize {
    self.title = NSLocalizedString(@"Add tag", @"Add tag");
    self.tags = [[NSMutableArray alloc] init];
    self.selectedTags = [[NSMutableArray alloc] init];
    [self fetchAllTags];
}

#pragma mark - Private

- (NSString *)getCurrentTeamId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:kCurrentTeamID];
}

#pragma mark - HTTP

- (RACSignal *)fetchAllTags {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:[self getCurrentTeamId], @"_teamId", nil];
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [manager GET:kTagsURLString parameters:param success:^(NSURLSessionDataTask *task, NSArray *responseObject) {
            DDLogDebug(@"%@", responseObject);
            for (NSDictionary *tagDic in responseObject) {
                TBTag *tag = [MTLJSONAdapter modelOfClass:[TBTag class] fromJSONDictionary:tagDic error:Nil];
                if ([self.selectedTags containsObject:tag]) {
                    [tag setIsSelected:YES];
                }
                [self.tags addObject:tag];
            }
            [subscriber sendNext:Nil];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DDLogDebug(@"%@", error.localizedDescription);
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)addNewTag:(NSString *)name {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:[self getCurrentTeamId], @"_teamId", name, @"name", nil];
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [manager POST:kTagsURLString parameters:param success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
            DDLogDebug(@"%@", responseObject);
            TBTag *tag = [MTLJSONAdapter modelOfClass:[TBTag class] fromJSONDictionary:responseObject error:Nil];
            [tag setIsSelected:YES];
            [self.tags addObject:tag];
            [self.selectedTags addObject:tag];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DDLogDebug(@"%@", error.localizedDescription);
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)addTagToMessage {
    NSMutableArray *tagIdArray = [NSMutableArray array];
    for (TBTag *tag in self.selectedTags) {
        [tagIdArray addObject:tag.tagId];
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:tagIdArray, @"_tagIds", nil];
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [manager PUT:[NSString stringWithFormat:@"%@/%@",kSendMessageURLString,self.messageId] parameters:param success:^(NSURLSessionDataTask *task, id responseObject) {
            TBMessage *newMessage = [MTLJSONAdapter modelOfClass:[TBMessage class] fromJSONDictionary:responseObject error:NULL];
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                MOMessage *moMessage = [MTLManagedObjectAdapter managedObjectFromModel:newMessage insertingIntoContext:localContext error:NULL];
                if (moMessage) {
                    DDLogDebug(@"add tag to message success");
                }
            } completion:^(BOOL success, NSError *error) {
                [subscriber sendNext:newMessage];
                [subscriber sendCompleted];
            }];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

@end
