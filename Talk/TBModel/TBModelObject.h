//
// Created by Suic on 28/2/15.
// Copyright (c) 2014 Zhang Zeqing. All rights reserved.
//

#import <Mantle/Mantle.h>

extern NSString * const kDefaultDateFormatString;

@interface TBModelObject : MTLModel <MTLJSONSerializing, MTLManagedObjectSerializing>

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSDate *createdAt;
@property (nonatomic, copy) NSDate *updatedAt;

+ (id)objectFromJSONObject:(id)object;
+ (NSDateFormatter *)dateFormatter;

@end