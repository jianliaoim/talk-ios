//
//  SelectSyncTeamTableViewController.h
//  Talk
//
//  Created by Suric on 15/11/27.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectSyncTeamTableViewControllerDelegate <NSObject>
- (void)syncTeamSuccessWithInfo:(NSDictionary *)teamInfo;
- (void)enterTeamWithSourceId:(NSString *)sourceId;
@end

@interface SelectSyncTeamTableViewController : UITableViewController
@property (strong, nonatomic) NSString *referString;
@property (assign, nonatomic) id <SelectSyncTeamTableViewControllerDelegate> delegate;
@end
