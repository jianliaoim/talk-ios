//
// Created by Shire on 9/23/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBModelObject.h"

@interface TBRoom : TBModelObject

@property (nonatomic, copy) NSString * creatorID;
@property (nonatomic, copy) NSString * purpose;
@property (nonatomic, copy) NSString * teamID;
@property (nonatomic, copy) NSString * topic;
@property (nonatomic, copy) NSDate *pinnedAt;
@property (nonatomic, copy) NSNumber *unread;
@property (nonatomic, copy) NSString *color;
@property (nonatomic) BOOL isQuit;
@property (nonatomic) BOOL isArchived;
@property (nonatomic) BOOL isGeneral;
@property (nonatomic) BOOL isPrivate;
@property (nonatomic) BOOL isMute;
@property (nonatomic, strong) NSArray *members;

@end