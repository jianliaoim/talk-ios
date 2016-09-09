//
//  AddMemberViewController.h
//  Talk
//
//  Created by jiaoliao-ios on 14/10/15.
//  Copyright (c) 2014年 jiaoliao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOUser.h"
#import "MORoom.h"
@class MOGroup;

@protocol AddTopicMemberViewControllerDelegate <NSObject>
-(void)addMemberForNewTopicWith:(NSMutableArray *)tbMemeberArray;
@end

@protocol MultiplePhoneCallDelegate <NSObject>
-(void)selectUserArray:(NSArray *)userArray;
@end

@interface AddTopicMemberViewController : UIViewController
@property (nonatomic,assign) id<AddTopicMemberViewControllerDelegate> delegate;
@property (nonatomic,weak) id<MultiplePhoneCallDelegate> phoneCallDelegate;
@property (nonatomic, strong) NSMutableArray *currentRoomMembersArray;  //current members for current room
@property (nonatomic, strong) NSMutableArray *addedTeamMemberArray;   //added member for current room ,use for create new room
@property (nonatomic) BOOL isCreatingRoom;
@property (nonatomic) BOOL isCreatingGroup;
@property (nonatomic) BOOL isCreatingStory;
@property (nonatomic) BOOL isUpdatingRoomMember;
@property (nonatomic) BOOL isUpdatingStoryMember;
@property (nonatomic) BOOL isUpdatingMemberGroup;
@property (nonatomic) BOOL isCalling;
@property (strong, nonatomic) MORoom *currentRoom;
@property (strong, nonatomic) MOGroup *currentMemberGroup;
@end

