//
//  TBTopicColorCell.m
//  Talk
//
//  Created by teambition-ios on 14/12/12.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "TBTopicColorCell.h"

@implementation TBTopicColorCell

- (void)awakeFromNib {
    // Initialization code
    //next to lines is very important to reduce the UI jam
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Initialization code
    self.topicColorLabel.clipsToBounds = YES;
    self.topicColorLabel.layer.cornerRadius = self.topicColorLabel.bounds.size.height/2;
    self.topicColorLabel.layer.allowsEdgeAntialiasing = YES;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
     UIColor *color = self.topicColorLabel.backgroundColor;
    
    [super setHighlighted:highlighted animated:animated];
    
     self.topicColorLabel.backgroundColor = color;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *color = self.topicColorLabel.backgroundColor;
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    self.topicColorLabel.backgroundColor = color;
    
    self.userInteractionEnabled = !selected;
}

@end
