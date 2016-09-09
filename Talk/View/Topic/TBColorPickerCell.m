//
//  TBColorPickerCell.m
//  Talk
//
//  Created by teambition-ios on 14/12/12.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "TBColorPickerCell.h"

@implementation TBColorPickerCell

- (void)awakeFromNib {
    // Initialization code
    //next to lines is very important to reduce the UI jam
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Initialization code
    self.colorLabel.clipsToBounds = YES;
    self.colorLabel.layer.cornerRadius = self.colorLabel.bounds.size.height/2;
    self.colorLabel.layer.allowsEdgeAntialiasing = YES;
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    UIColor *color = self.colorLabel.backgroundColor;
    
    [super setHighlighted:highlighted animated:animated];
    
    self.colorLabel.backgroundColor = color;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *color = self.colorLabel.backgroundColor;
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    self.colorLabel.backgroundColor = color;
    
    self.userInteractionEnabled = !selected;
}

@end
