//
//  TeamActivityDetailCell.m
//  Talk
//
//  Created by Suric on 16/3/10.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "TeamActivityDetailCell.h"
#import "constants.h"

@implementation TeamActivityDetailCell

- (void)awakeFromNib {
    self.activityDetailImageView.layer.cornerRadius = 2.0f;
    self.activityDetailImageView.layer.masksToBounds = YES;
}

- (void)setActivity:(TBTeamActivity *)activity {
    _activity = activity;
    self.imageWidthContrainst.constant = activity.imageSize.width;
    self.imageHeightContrainst.constant = activity.imageSize.height;
}

@end
