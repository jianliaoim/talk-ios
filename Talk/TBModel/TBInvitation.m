//
//  TBInvitation.m
//  Talk
//
//  Created by 史丹青 on 9/16/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "TBInvitation.h"

@implementation TBInvitation

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValuesForKeysWithDictionary:@{
                                                 @"id": @"_id",
                                                 @"teamId" : @"_teamId"
                                                 }];
    
    return dictionary;
}

#pragma mark - MTLManagedObjectSerializing

+ (NSString *)managedObjectEntityName {
    return @"Invitation";
}

+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return [NSSet setWithObject:@"key"];
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    NSDictionary *dictionary = [NSDictionary dictionary];
    return dictionary;
}

@end
