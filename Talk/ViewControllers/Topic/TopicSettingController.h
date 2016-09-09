//
//  TopicSettingController.h
//  Talk
//
//  Created by teambition-ios on 14/10/15.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+TBColor.h"
#import "TBRoom.h"

typedef enum : NSUInteger {
    AddTopicMemberTypeUpdateStory,
    AddTopicMemberTypeUpdateTopic,
} AddTopicMemberType;

@interface TopicSettingController : UITableViewController
@property(nonatomic,strong) UIColor *topicTintColor;
@property(nonatomic,assign) BOOL isStorySetting;
@end
