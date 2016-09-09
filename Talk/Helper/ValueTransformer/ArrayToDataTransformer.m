//
// Created by Shire on 9/23/14.
// Copyright (c) 2014 jiaoliao. All rights reserved.
//

#import "ArrayToDataTransformer.h"


@implementation ArrayToDataTransformer

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
    NSArray *array = (NSArray *) [NSKeyedUnarchiver unarchiveObjectWithData:value];
    return array;
}

@end