//
// Created by Suic on 28/2/15.
// Copyright (c) 2014 Zhang Zeqing. All rights reserved.
//

#import "TBModelObject.h"

NSString * const kDefaultDateFormatString = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

@implementation TBModelObject

-(void)setNilValueForKey:(NSString *)key
{
    [self setValue:@0 forKey:key];
}

+ (id)objectFromJSONObject:(id)object {
    id returnObject = nil;

    if ([object isKindOfClass:[NSDictionary class]]) {
        // the json object is a dict -- create a new dict with the objects we can map from its contents
        returnObject = [MTLJSONAdapter modelOfClass:[self class]
                                 fromJSONDictionary:object
                                              error:nil];

    } else if ([object isKindOfClass:[NSArray class]]) {
        // the json object is an array -- create a new array with the objects we can map from its contents
        NSMutableArray *array = [NSMutableArray array];
        for (id dict in (NSArray *)object) {
            NSParameterAssert([dict isKindOfClass:[NSDictionary class]]);
            id newObj = [MTLJSONAdapter modelOfClass:[self class]
                                  fromJSONDictionary:dict
                                               error:nil];

            [array addObject:newObj];
        }
        returnObject = [NSArray arrayWithArray:array];
    }

    return returnObject;
}

+ (NSDateFormatter *)dateFormatter {
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary] ;
    NSDateFormatter *formatter = [threadDictionary objectForKey: @"DDMyDateFormatter"] ;
    if (formatter == nil)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formatter setDateFormat:kDefaultDateFormatString];
        [threadDictionary setObject:formatter forKey: @"DDMyDateFormatter"] ;
    }
    return formatter;
}

#pragma mark - JSON Serializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValuesForKeysWithDictionary:@{@"id" : @"_id"}];
    return dictionary;
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)updatedAtJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

#pragma mark - MTLManagedObjectSerializing

+ (NSString *)managedObjectEntityName {
    return nil;
}

+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return [NSSet setWithObject:@"id"];
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    NSDictionary *dictionary = [NSDictionary dictionary];
    return dictionary;
}

@end