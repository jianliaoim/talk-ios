//
// Created by Shire on 9/23/14.
// Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBModelObject.h"

@interface TBUser : TBModelObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pinyin;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString* mobile;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString* phoneForLogin;
@property (nonatomic, copy) NSURL *avatarURL;
@property (nonatomic, copy) NSString* sourceId;
@property (nonatomic) BOOL isRobot;
@property (nonatomic, copy) NSString* service;
@property (nonatomic, copy) NSString *role;
@property (nonatomic, copy) NSNumber *unread;
@property (nonatomic, copy) NSString *alias;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic) BOOL isMute;
@property (nonatomic) BOOL hideMobile;
@property (nonatomic) BOOL isQuit;

@end