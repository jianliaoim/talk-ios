//
//  NewTopicViewController.h
//  Talk
//
//  Created by Shire on 10/20/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MOGroup, MORoom;

@protocol NewTopicViewControllerDelegate <NSObject>

@optional

-(void)successCreateRoom:(MORoom *)room;
- (void)didCreateMemberGroup:(MOGroup *)group;

@end

@interface NewTopicViewController : UITableViewController

@property(nonatomic,assign) id <NewTopicViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL isMemberGroup;

@end
