//
//  EditTopicNameController.h
//  Talk
//
//  Created by teambition-ios on 14/10/15.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MOGroup;

@interface EditTopicNameController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveItem;
@property(strong,nonatomic) NSString *nameStr; //textFiled deafault Stting
@property(nonatomic,assign) BOOL isEditingTopicName; // is edit topicName or not
@property (nonatomic, assign) BOOL isEditingGroupName; //is edit member group name or not
@property (strong, nonatomic) MOGroup *group;
@end
