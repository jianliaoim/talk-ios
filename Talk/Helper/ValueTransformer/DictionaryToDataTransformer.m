//
//  DictionaryToDataTransformer.m
//  Talk
//
//  Created by teambition-ios on 15/4/2.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "DictionaryToDataTransformer.h"

@implementation DictionaryToDataTransformer
+ (BOOL)allowsReverseTransformation {
    return YES;
}

+ (Class)transformedValueClass {
    return [NSData class];
}

- (id)transformedValue:(id)value {
    //Take an NSArray archive to NSData
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    return data;
}

- (id)reverseTransformedValue:(id)value {
    //Take NSData unarchive to NSArray
    NSDictionary *dictionary = (NSDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:value];
    return dictionary;
}

@end
