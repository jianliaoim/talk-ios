//
//  SwitchTeamTableViewController.h
//  Talk
//
//  Created by 王卫 on 16/1/14.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MOTeam;

@interface SwitchTeamTableViewController : UITableViewController

@property (nonatomic, copy) NSString *currentTeamID;
@property (nonatomic, strong) MOTeam *currentTeam;
@property (nonatomic, weak) id delegate;

@end
