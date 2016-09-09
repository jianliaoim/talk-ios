//
//  JLShareTeamController.h
//  Talk
//
//  Created by teambition-ios on 15/4/14.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLShareViewController.h"

@protocol JLShareTeamControllerDelegate <NSObject>

- (void)didSelectTeamWith:(NSDictionary *)teamInfo;

@end

@interface JLShareTeamController : UITableViewController

@property (strong, nonatomic) NSArray *allTeamArray;
@property (assign, nonatomic) id<JLShareTeamControllerDelegate> delegate;
@property (weak, nonatomic) id<JLShareExtensionDelegate> uiDelegate;

@end
