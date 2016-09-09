//
//  SelectSyncTeamCell.h
//  Talk
//
//  Created by Suric on 15/11/27.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBButton.h"

@interface SelectSyncTeamCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet TBButton *syncButton;
@property (weak, nonatomic) IBOutlet TBButton *enterTeamButton;

@end
