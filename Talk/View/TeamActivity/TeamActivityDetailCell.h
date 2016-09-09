//
//  TeamActivityDetailCell.h
//  Talk
//
//  Created by Suric on 16/3/10.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "TeamActivityCell.h"
#import "TBTeamActivity.h"

@interface TeamActivityDetailCell : TeamActivityCell
@property (weak, nonatomic) IBOutlet UILabel *activityTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityDetailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activityDetailImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidthContrainst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeightContrainst;
@property (strong, nonatomic) TBTeamActivity *activity;
@end
