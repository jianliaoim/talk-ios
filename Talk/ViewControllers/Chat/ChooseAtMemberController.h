//
//  ChooseAtMenberController.h
//  Talk
//
//  Created by teambition-ios on 14/10/13.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+TBColor.h"
@class MOUser;

typedef enum : NSUInteger {
    ChooseAtMemberForRoom,
    ChooseAtMemberForStory,
    ChooseAtMemberForDMS,
} ChooseAtCategory;

@interface ChooseAtMemberController : UITableViewController
@property(nonatomic,strong) NSMutableArray *currentRoomMembersArray;  //current members for current room
@property(nonatomic,strong) UIColor *tintColor;
@property(nonatomic,assign) ChooseAtCategory chooseAtCategory;
@property(nonatomic,strong) MOUser *chatUser;
@end
