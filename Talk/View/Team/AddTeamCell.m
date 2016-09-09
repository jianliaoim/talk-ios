//
//  AddTeamCell.m
//  Talk
//
//  Created by 史丹青 on 8/27/15.
//  Copyright (c) 2015 jiaoliao. All rights reserved.
//

#import "AddTeamCell.h"

@implementation AddTeamCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithImageName:(NSString *)imageName andTitle:(NSString *)title andDescription:(NSString *)description {
    [self.addTeamImage setImage:[UIImage imageNamed:imageName]];
    [self.addTeamTitle setText:title];
    [self.addTeamDescription setText:description];
}

@end
