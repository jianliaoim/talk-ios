//
// Created by Shire on 9/23/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBUser.h"
#import "TBUtility.h"

@implementation TBUser

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    NSString *currentTeamID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamID];
    if (currentTeamID) {
        self.userID = [currentTeamID stringByAppendingString:self.id];
    }
    
    TBUser *originUSer = [MTLManagedObjectAdapter modelOfClass:[TBUser class] fromManagedObject:[MOUser findFirstWithId:self.id] error:NULL];
    if (originUSer) {
        if (!self.phoneForLogin) {
        self.phoneForLogin = originUSer.phoneForLogin;
        self.mobile = originUSer.mobile;
        }
        [originUSer mergeValuesForKeysFromModel:self];
    } else {
        return self;
    }
    return originUSer;
}

- (void)mergeValueForKey:(NSString *)key fromModel:(MTLModel *)model
{
    if(![model valueForKey:key]) {
        return;
    }
    [super mergeValueForKey:key fromModel:model];
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

+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return [NSSet setWithObject:@"userID"];
}

+ (NSString *)managedObjectEntityName {
    return @"User";
}

+ (NSValueTransformer *)avatarURLEntityAttributeTransformer {
    return [[NSValueTransformer valueTransformerForName:MTLURLValueTransformerName] mtl_invertedTransformer];
}

@end
