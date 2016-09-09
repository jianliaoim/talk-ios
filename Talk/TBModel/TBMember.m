//
//  TBMember.m
//  Talk
//
//  Created by teambition-ios on 14/12/3.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "TBMember.h"
#import "DictionaryToDataTransformer.h"
#import "constants.h"

@implementation TBMember

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    self.id = [currentTeamID stringByAppendingString:self.id];
    return self;
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    [dictionary setValuesForKeysWithDictionary:@{
                                                 @"avatarURL" : @"avatarUrl",
                                                 @"alias" : @"prefs.alias",
                                                 @"isMute" : @"prefs.isMute",
                                                 @"hideMobile": @"prefs.hideMobile",
                                                 @"userID": @"id",
                                                 }];
    return dictionary;
}

+ (NSValueTransformer *)avatarURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

#pragma mark - MTLManagedObjectSerializing

+ (NSString *)managedObjectEntityName {
    return @"Member";
}

+ (NSValueTransformer *)avatarURLEntityAttributeTransformer {
    return [[NSValueTransformer valueTransformerForName:MTLURLValueTransformerName] mtl_invertedTransformer];
}

@end
