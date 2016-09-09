//
//  TopicColorTableViewController.h
//  Talk
//
//  Created by teambition-ios on 14/12/12.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TopicColorVCType) {
    TopicColorVCTypeCreateTopic,
    TopicColorVCTypeTopicEdit,
    TopicColorVCTypeCreateTeam,
    TopicColorVCTypeTeamEdit
};

@protocol TopicColorTableViewControllerDelegate <NSObject>

-(void)didChangedColor:(NSString *)color;

@end

@interface TopicColorTableViewController : UITableViewController

@property(nonatomic) TopicColorVCType type;
@property(nonatomic,strong) NSString *defaultColorStr;
@property(nonatomic,assign) id<TopicColorTableViewControllerDelegate> delegate;

@end
