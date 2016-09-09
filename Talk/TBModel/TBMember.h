//
//  TBMember.h
//  Talk
//
//  Created by teambition-ios on 14/12/3.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "TBModelObject.h"

@interface TBMember : TBModelObject
@property (nonatomic, copy) NSString *role;
@property (nonatomic, copy) NSNumber *unread;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *alias;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic) BOOL isMute;
@property (nonatomic) BOOL hideMobile;
@property (nonatomic) BOOL isQuit;
@property (nonatomic, copy) NSURL *avatarURL;
@end
