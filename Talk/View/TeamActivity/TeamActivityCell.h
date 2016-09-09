//
//  TeamActivityCell.h
//  Talk
//
//  Created by Suric on 16/2/16.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTeamActivity.h"

static CGFloat const ActivityDetailMargin = 190;

@interface TeamActivityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *systemMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

+ (CGFloat)calculateCellHeightWithTeamActivity:(TBTeamActivity *)activity;
@end
