//
//  TBNotification.h
//  Talk
//
//  Created by 史丹青 on 10/14/15.
//  Copyright © 2015 Teambition. All rights reserved.
//

#import "TBModelObject.h"
#import "TBStory.h"

@class TBUser;

@interface TBNotification : TBModelObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) TBStory *story;
@property (nonatomic, strong) NSDictionary *target;
@property (nonatomic, copy) NSNumber *unreadNum;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *teamID;
@property (nonatomic, copy) NSString *targetID;
@property (nonatomic, copy) NSString *creatorID;
@property (nonatomic, copy) NSString *creatorName;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSNumber *sendStatus;
@property (nonatomic) BOOL isPinned;
@property (nonatomic) BOOL isMute;
@property (nonatomic) BOOL isHidden;
@property (nonatomic, copy) NSString *emitterID;
@property (nonatomic, copy) NSString *latestReadMessageID;

@end
