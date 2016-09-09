//
//  TBNotification.m
//  Talk
//
//  Created by 史丹青 on 10/14/15.
//  Copyright © 2015 Teambition. All rights reserved.
//

#import "TBNotification.h"
#import "TBUser.h"
#import "NSString+Emoji.h"
#import "constants.h"
#import "MOUser.h"
#import "TBUtility.h"

@implementation TBNotification

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    if ([self.type isEqualToString:kNotificationTypeDMS]) {
        MOUser *creator = [MOUser findFirstWithId:self.target[@"_id"]];
        self.creatorName = [TBUtility getFinalUserNameWithMOUser:creator];
        self.text = [self.text stringByReplacingEmojiCheatCodesWithUnicode];
    } else {
        MOUser *creator;
        if (self.creatorID) {
            creator = [MOUser findFirstWithId:self.creatorID];
        }
        if (creator) {
            if (self.authorName) {
                self.text = [NSString stringWithFormat:@"%@: %@",self.authorName,[self.text stringByReplacingEmojiCheatCodesWithUnicode]];
            } else {
                self.text = [NSString stringWithFormat:@"%@: %@", [TBUtility getFinalUserNameWithMOUser:creator], [self.text stringByReplacingEmojiCheatCodesWithUnicode]];
            }
        } else {
            if (self.authorName) {
                self.text = [NSString stringWithFormat:@"%@: %@",self.authorName,[self.text stringByReplacingEmojiCheatCodesWithUnicode]];
            } else {
                if (self.creatorName) {
                    self.text = [NSString stringWithFormat:@"%@: %@",self.creatorName,[self.text stringByReplacingEmojiCheatCodesWithUnicode]];
                } else {
                    self.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"someone",@"someone"),[self.text stringByReplacingEmojiCheatCodesWithUnicode]];
                }
            }
        }
    }
    if ([self.type isEqualToString:kNotificationTypeStory]) {
        self.story = [MTLJSONAdapter modelOfClass:[TBStory class] fromJSONDictionary:self.target error:NULL];
    }
    return self;
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    [dictionary setValuesForKeysWithDictionary:@{
                                                 @"teamID" : @"_teamId",
                                                 @"targetID" : @"_targetId",
                                                 @"creatorID": @"_creatorId",
                                                 @"creatorName": @"creator.name",
                                                 @"latestReadMessageID": @"_latestReadMessageId",
                                                 @"emitterID": @"_emitterId"
                                                 }];
    return dictionary;
}

+ (NSValueTransformer *)creatorJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[TBUser class]];
}

#pragma mark - MTLManagedObjectSerializing

+ (NSString *)managedObjectEntityName {
    return @"Notification";
}

+(NSDictionary *)relationshipModelClassesByPropertyKey{
    return @{
             @"story" : [TBStory class],
             };
}


@end
