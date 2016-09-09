//
//  TBQuote.m
//  Talk
//
//  Created by teambition-ios on 14/11/18.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "TBQuote.h"

@implementation TBQuote
#pragma mark - MTLJSONSerializing
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValuesForKeysWithDictionary:@{@"redirectURL": @"redirectUrl",
                                                 @"userAvatarURL": @"userAvatarUrl",
                                                 @"authorAvatarURL": @"authorAvatarUrl",
                                                 @"thumbnailPicURL": @"thumbnailPicUrl",
                                                 }];
    return dictionary;
}

+ (NSValueTransformer *)redirectURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)userAvatarURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)authorAvatarURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)thumbnailPicURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

#pragma mark - MTLManagedObjectSerializing

+ (NSString *)managedObjectEntityName {
    return @"Quote";
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    NSDictionary *dictionary = [NSDictionary dictionary];
    return dictionary; 
}

+ (NSValueTransformer *)redirectURLEntityAttributeTransformer {
    return [[NSValueTransformer valueTransformerForName:MTLURLValueTransformerName] mtl_invertedTransformer];
}

+ (NSValueTransformer *)userAvatarURLEntityAttributeTransformer {
    return [[NSValueTransformer valueTransformerForName:MTLURLValueTransformerName] mtl_invertedTransformer];
}

+ (NSValueTransformer *)authorAvatarURLEntityAttributeTransformer {
    return [[NSValueTransformer valueTransformerForName:MTLURLValueTransformerName] mtl_invertedTransformer];
}

+ (NSValueTransformer *)thumbnailPicURLEntityAttributeTransformer {
    return [[NSValueTransformer valueTransformerForName:MTLURLValueTransformerName] mtl_invertedTransformer];
}

@end
