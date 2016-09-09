//
// Created by Shire on 9/23/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBRoom.h"
#import "TBUser.h"
#import "DictionaryToDataTransformer.h"


@implementation TBRoom

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    [dictionary setValuesForKeysWithDictionary:@{
            @"creatorID" : @"_creatorId",
            @"teamID" : @"_teamId",
            @"isMute" : @"prefs.isMute"
    }];

    return dictionary;
}

+ (NSValueTransformer *)membersJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[TBUser class]];
}

+ (NSValueTransformer *)pinnedAtJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}


#pragma mark - MTLManagedObjectSerializing

+ (NSString *)managedObjectEntityName {
    return @"Room";
}

+(NSDictionary *)relationshipModelClassesByPropertyKey{
    return @{
             @"members"  : [TBUser class]
             };
}

@end