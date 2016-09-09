//
//  TBAddTagCell.m
//  Talk
//
//  Created by 史丹青 on 7/16/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "TBAddTagCell.h"
#import "UIColor+TBColor.h"

@implementation TBAddTagCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupCellWithTagName:(NSString *)name isSelected:(BOOL)isSelected {
    [self.tagName setText:name];
    [self changeStatus:isSelected];
}

- (void)changeStatus:(BOOL)isSelected {
    self.selectImageView.tintColor = [UIColor jl_redColor];
    if (isSelected) {
        [self.selectImageView setImage:[[UIImage imageNamed:@"icon-tag-selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    } else {
        [self.selectImageView setImage:[UIImage imageNamed:@"icon-tag-unselected"]];
    }
}

@end
