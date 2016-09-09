//
//  TagsViewModel.m
//  Talk
//
//  Created by 史丹青 on 7/14/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "TagsViewModel.h"
#import "constants.h"
#import "TBHTTPSessionManager.h"
#import "Mantle.h"
#import "TBTag.h"
#import "SVProgressHUD.h"

@implementation TagsViewModel

- (instancetype)init {
    self = [super init];
    [self initialize];
    return self;
}

- (void)initialize {
    self.title = NSLocalizedString(@"Tags", @"Tags");
    
    self.tags = [[NSArray alloc] init];
}

#pragma mark - Public

- (void)searchTag:(NSString *)text {
    NSMutableArray *searchTagTemp = [[NSMutableArray alloc] init];
    
    self.searchTags = searchTagTemp;
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
            NSMutableArray *tagMutableArray = [[NSMutableArray alloc] init];
            for (NSDictionary *tagDic in responseObject) {
                TBTag *tag = [MTLJSONAdapter modelOfClass:[TBTag class] fromJSONDictionary:tagDic error:Nil];
                [tagMutableArray addObject:tag];
            }
            self.tags = tagMutableArray;
            [subscriber sendNext:Nil];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        return Nil;
    }];
}

- (RACSignal *)deleteTag:(TBTag *)tag {
    TBHTTPSessionManager *manager = [TBHTTPSessionManager sharedManager];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [manager DELETE:[NSString stringWithFormat:@"%@/%@",kTagsURLString,tag.tagId]  parameters:Nil success:^(NSURLSessionDataTask *task, NSArray *responseObject) {
            [subscriber sendNext:Nil];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        return Nil;
    }];
}

@end
