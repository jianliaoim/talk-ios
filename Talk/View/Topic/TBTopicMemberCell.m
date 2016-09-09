//
//  TBTopicMemberCell.m
//  Talk
//
//  Created by teambition-ios on 15/4/3.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TBTopicMemberCell.h"
#import "UIColor+TBColor.h"

@implementation TBTopicMemberCell

- (void)awakeFromNib {
    // Initialization code
    //next to lines is very important to reduce the UI jam
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Initialization code
    self.cellImageView.layer.cornerRadius = self.cellImageView.bounds.size.height/2;
    self.cellImageView.clipsToBounds = YES;
    self.cellImageView.layer.allowsEdgeAntialiasing = YES;
    
    UIImage *addTemplateImage = [[UIImage imageNamed:@"icon-remove"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.deleteButton setImage:addTemplateImage forState:UIControlStateNormal];
    self.deleteButton.tintColor = [UIColor jl_redColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
