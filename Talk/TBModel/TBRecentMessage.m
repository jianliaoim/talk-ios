//
// Created by Shire on 11/6/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import "CoreData+MagicalRecord.h"
#import "constants.h"
#import "ArrayToDataTransformer.h"

#import "TBRecentMessage.h"
#import "MORoom.h"
#import "MOUser.h"
#import "TBUser.h"
#import "TBQuote.h"
#import "TBUtility.h"
#import "TBAttachment.h"

@implementation TBRecentMessage

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    [dictionary setValuesForKeysWithDictionary:@{
            @"toID" : @"_toId",
            @"creatorID" : @"_creatorId",
            @"roomID" : @"_roomId",
            @"teamID" : @"_teamId",
            @"attachments" : @"attachments",
    }];

    return dictionary;
}

+ (NSValueTransformer *)quoteJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[TBQuote class]];
}

+ (NSValueTransformer *)creatorJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[TBUser class]];
}

+ (NSValueTransformer *)attachmentsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[TBAttachment class]];
}


#pragma mark - MTLManagedObjectSerializing

+ (NSString *)managedObjectEntityName {
    return @"RecentMessage";
}

+(NSDictionary *)relationshipModelClassesByPropertyKey{
    return @{
             @"quote" : [TBQuote class],
             @"creator" : [TBUser class],
             @"attachments" : [TBAttachment class],
            };
}

#pragma mark - Instance method

- (NSUInteger)getBadgeNumber {
    NSUInteger badgeNumber = 0;

    // The message from a topic
    if (self.roomID) {
        NSPredicate *predicate = [TBUtility roomPredicateForCurrentTeamWithRoomId:self.roomID];
        MORoom *room = [MORoom MR_findFirstWithPredicate:predicate];
        if (room.unread) {
            if (![room.unread isEqual:@0]) {
                badgeNumber = (NSUInteger) [room.unread integerValue];
                if (room.isMuteValue) {
                    badgeNumber = 0;
                }
            }
        }
    }

    // The message from a person
    if (self.toID) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *currentUserID = [defaults valueForKey:kCurrentUserKey];
        NSString *targetUserID = nil;

        if ([self.toID isEqualToString:currentUserID]) {
            targetUserID = self.creatorID;
        }
        else {
            targetUserID = self.toID;
        }
        MOUser*targetUser = [MOUser findFirstWithId:targetUserID];
        if (targetUser.unread) {
            if (![targetUser.unread isEqual:@0]) {
                badgeNumber = (NSUInteger) [targetUser.unread integerValue];

            }
        }

    }

    return badgeNumber;
}

@end