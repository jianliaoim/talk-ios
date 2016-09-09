//
// Created by Shire on 10/27/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBFile.h"


@implementation TBFile

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    [dictionary setValuesForKeysWithDictionary:@{
            @"thumbnailURL" : @"thumbnailUrl",
            @"downloadURL" : @"downloadUrl",
            @"messageID" : @"_messageID",
            @"creatorID" : @"_creatorId",
            @"teamID" : @"_teamId",
            @"roomID" : @"_roomId"
    }];

    return dictionary;
}

+ (NSValueTransformer *)thumbnailURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)downloadURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

#pragma mark - MTLManagedObjectSerializing

+ (NSString *)managedObjectEntityName {
    return @"File";
}

+ (NSValueTransformer *)thumbnailURLEntityAttributeTransformer {
    return [[NSValueTransformer valueTransformerForName:MTLURLValueTransformerName] mtl_invertedTransformer];
}

+ (NSValueTransformer *)downloadURLEntityAttributeTransformer {
    return [[NSValueTransformer valueTransformerForName:MTLURLValueTransformerName] mtl_invertedTransformer];
}

@end