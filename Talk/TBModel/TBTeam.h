//
// Created by Shire on 9/23/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//



#import "TBModelObject.h"

@interface TBTeam : TBModelObject

@property (nonatomic, copy) NSDate *minDate;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *creatorID;
@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *signCode;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *sourceId;
@property (nonatomic, copy) NSString *inviteCode;
@property (nonatomic, copy) NSURL *inviteURL;
@property (nonatomic) NSNumber *unread;
@property (nonatomic) BOOL nonJoinable;
@property (nonatomic) BOOL hasUnread;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *rooms;

@end