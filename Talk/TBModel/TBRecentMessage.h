//
// Created by Shire on 11/6/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBModelObject.h"
@class TBQuote;
@class TBUser;

@interface TBRecentMessage : TBModelObject

@property (nonatomic, copy) NSString * body;
@property (nonatomic, copy) NSString * creatorID;
@property (nonatomic, copy) NSString * roomID;
@property (nonatomic, copy) NSString * teamID;
@property (nonatomic, copy) NSString * toID;
@property (nonatomic, copy) NSString * text;
@property (nonatomic, copy) NSString * displayMode;
@property (nonatomic) BOOL isSystem;
@property (nonatomic, copy) NSNumber *sendStatus;
@property (nonatomic, strong) TBUser * creator;
@property (nonatomic, strong) NSArray * attachments;

- (NSUInteger)getBadgeNumber;

@end