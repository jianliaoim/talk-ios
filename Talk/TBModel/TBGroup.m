//
//  TBGroup.m
//  Talk
//
//  Created by 王卫 on 15/12/22.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "TBGroup.h"
#import "TBUser.h"
#import "DictionaryToDataTransformer.h"

@implementation TBGroup

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    [dictionary setValuesForKeysWithDictionary:@{
                                                 @"creatorId" : @"_creatorId",
                                                 @"teamId" : @"_teamId",
                                                 }];
    
    return dictionary;
}

#pragma mark - MTLManagedObjectSerializing

+ (NSString *)managedObjectEntityName {
    return @"Group";
}

@end
