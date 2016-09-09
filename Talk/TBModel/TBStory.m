//
//  TBStory.m
//  Talk
//
//  Created by 史丹青 on 10/20/15.
//  Copyright © 2015 Teambition. All rights reserved.
//

#import "TBStory.h"

@implementation TBStory

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    [dictionary setValuesForKeysWithDictionary:@{
                                                 @"teamID" : @"_teamId",
                                                 @"creatorID" : @"_creatorId",
                                                 @"members" : @"_memberIds"
                                                 }];
    return dictionary;
}

#pragma mark - MTLManagedObjectSerializing

+ (NSString *)managedObjectEntityName {
    return @"Story";
}


@end
