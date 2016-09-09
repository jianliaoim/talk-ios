//
//  TBTeamActivity.m
//  Talk
//
//  Created by Suric on 16/2/15.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "TBTeamActivity.h"
#import "TBUtility.h"
#import "TeamActivityCell.h"
#import "TBImageTableViewCell.h"

@implementation TBTeamActivity

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    
    NSString *createName = [TBUtility getFinalUserNameWithTBUser:self.creator];
    NSString *noSystemInfoText = [TBUtility getStringWithoutRegexFromString:self.text];
    if (!createName) {
        createName = NSLocalizedString(@"someone",@"someone");
    }
    
    if (self.targetId) {
        NSString *imageName = @"";
        NSString *activityTitle;
        NSString *activityDetail;
        if ([self.type isEqualToString:kNotificationTypeRoom]) {
            imageName = @"TopicLogo";
            activityTitle = self.target[@"topic"];
            activityDetail = self.target[@"purpose"];
        }
        if ([self.type isEqualToString:kNotificationTypeStory]) {
            NSDictionary *storyDic = self.target[@"data"];
            NSString *storyCategory = self.target[@"category"];
            if ([storyCategory isEqualToString:kStoryCategoryFile]) {
                noSystemInfoText = NSLocalizedString(@"info-create-file-story", nil);
                imageName = @"ImageStoryLogo";
                activityTitle = self.target[@"title"];
                if ([storyDic[@"fileCategory"] isEqualToString:kFileCategoryImage]) {
                    CGFloat imageHeight = [storyDic[kImageHeight] floatValue];
                    CGFloat imageWidth = [storyDic[kImageWidth] floatValue];
                    CGFloat imageMaxHeight = [[UIScreen mainScreen] bounds].size.width - ActivityDetailMargin;
                    CGSize imageSize = [TBImageTableViewCell imageSizeWithImageWidth:imageWidth imageHeight:imageHeight imageMaxHeight:imageMaxHeight];
                    self.imageSize = imageSize;
                    self.thumbnailURLString = storyDic[kFileThumbnailUrl];
                }
            } else if ([storyCategory isEqualToString:kStoryCategoryTopic]) {
                noSystemInfoText = NSLocalizedString(@"info-create-topic-story", nil);
                imageName = @"TopicStoryLogo";
                activityTitle = storyDic[@"title"];
                activityDetail = storyDic[@"text"];
            } else if ([storyCategory isEqualToString:kStoryCategoryLink]) {
                noSystemInfoText = NSLocalizedString(@"info-create-link-story", nil);
                imageName = @"LinkStoryLogo";
                activityTitle = storyDic[@"title"];
                activityDetail = storyDic[@"url"];
            }
        }
        self.imageName = imageName;
        self.activityTitle = activityTitle ? activityTitle : @"";
        self.activityDetail = activityDetail ? activityDetail : @"";
    }
    self.text = [createName stringByAppendingFormat:@" %@",noSystemInfoText];
    self.cellHeight = [TeamActivityCell calculateCellHeightWithTeamActivity:self];
    return self;
}


#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    [dictionary setValuesForKeysWithDictionary:@{@"targetId": @"_targetId",
                                                 @"creatorId" : @"_creatorId",}];
    return dictionary;
}

+ (NSValueTransformer *)creatorJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *userDictionary) {
        if ([userDictionary isKindOfClass:[NSString class]]) {
            NSString *userId = (NSString *)userDictionary;
            MOUser *user = [MOUser findFirstWithId:userId];
            TBUser *newUSer = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:user error:NULL];
            return newUSer;
        } else {
            TBUser *newUSer = [MTLJSONAdapter modelOfClass:[TBUser class] fromJSONDictionary:userDictionary error:NULL];
            return newUSer;
        }
    }];
}

@end
