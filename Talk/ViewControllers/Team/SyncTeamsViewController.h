//
//  SyncTeamsViewController.h
//  Talk
//
//  Created by 史丹青 on 9/17/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SyncTeamsDelegate <NSObject>
@optional
- (void)finishSyncTeamsWithTeamArray:(NSArray *)teamArray;
- (void)chooseTeamWithSourceId:(NSString *)sourceId;
@end

@interface SyncTeamsViewController : UITableViewController
@property (nonatomic, weak) id<SyncTeamsDelegate> delegate;
@end
