//
//  TBTag.m
//  Talk
//
//  Created by 史丹青 on 7/15/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "TBTag.h"

@implementation TBTag

#pragma mark - JSON

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    [dictionary setValuesForKeysWithDictionary:@{
                                                 @"tagId" : @"id",
                                                 @"tagName" : @"name"
                                                 }];
    
    return dictionary;
}

@end
