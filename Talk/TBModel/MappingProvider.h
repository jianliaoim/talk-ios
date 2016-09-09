//
//  MappingProvider.h
//
//  Created by Suric on 14/10/11.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FastEasyMapping/FastEasyMapping.h>

@interface MappingProvider : NSObject
+ (FEMMapping *)roomMapping;
+ (FEMMapping *)userMapping;
+ (FEMMapping *)recentMessageMapping;
+ (FEMMapping *)quoteMapping;
+ (FEMMapping *)attachmentMapping;
@end
