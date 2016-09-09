//
//  ShareTeamTableViewController.h
//  
//
//  Created by Suric on 15/8/19.
//
//

#import <UIKit/UIKit.h>
#import "MOTeam.h"

@protocol ShareTeamTableViewControllerDelegate <NSObject>

- (void)selecteTeam:(MOTeam *)team;

@end

@interface ShareTeamTableViewController : UITableViewController
@property (strong, nonatomic) NSString *selectedTeamID;
@property (assign, nonatomic) id<ShareTeamTableViewControllerDelegate> delegate;
@end
