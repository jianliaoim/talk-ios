//
// Created by Shire on 9/23/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBTeam.h"
#import "TBUser.h"
#import "TBRoom.h"


@implementation TBTeam

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    [dictionary setValuesForKeysWithDictionary:@{
            @"creatorID" : @"_creatorId",
            @"inviteURL" : @"inviteUrl"
    }];

    return dictionary;
}

+ (NSValueTransformer *)usersJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[TBUser class]];
}

+ (NSValueTransformer *)roomsJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[TBRoom class]];
}


+ (NSValueTransformer *)inviteURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

#pragma mark - MTLManagedObjectSerializing

+ (NSString *)managedObjectEntityName {
    return @"Team";
}

+(NSDictionary *)relationshipModelClassesByPropertyKey{
    return @{
            @"rooms"    : [TBRoom class],
            @"users"    : [TBUser class]
    };
}

+ (NSValueTransformer *)inviteURLEntityAttributeTransformer {
    return [[NSValueTransformer valueTransformerForName:MTLURLValueTransformerName] mtl_invertedTransformer];
}

@end