//
//  TBTeamCell.m
//  Talk
//
//  Created by Shire on 10/9/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBTeamCell.h"
#import "UIColor+TBColor.h"

static const CGFloat DefaultBadgeButtonHeight = 20.0f;

@implementation TBTeamCell

- (void)awakeFromNib {
    // Initialization code
    self.cellImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.badgeButton.backgroundColor = [UIColor jl_redColor];
    [self.badgeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.badgeButton.layer.cornerRadius = DefaultBadgeButtonHeight/2;
    self.badgeButton.clipsToBounds = YES;
    self.dotView.backgroundColor = [UIColor jl_redColor];
    self.dotView.layer.cornerRadius = DefaultBadgeButtonHeight/4;
    self.dotView.clipsToBounds = YES;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    UIColor *backgroundColor = self.InitialNameLabel.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    self.InitialNameLabel.backgroundColor = backgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    UIColor *backgroundColor = self.InitialNameLabel.backgroundColor;
    [super setSelected:selected animated:animated];
    self.InitialNameLabel.backgroundColor = backgroundColor;
}

@end
