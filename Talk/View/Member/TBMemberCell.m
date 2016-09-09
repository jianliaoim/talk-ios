//
//  TBMemberCell.m
//  Talk
//
//  Created by Shire on 10/9/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBMemberCell.h"

@implementation TBMemberCell

- (void)awakeFromNib {
    //next to lines is very important to reduce the UI jam
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Initialization code
    self.cellImageView.layer.cornerRadius = self.cellImageView.bounds.size.height/2;
    self.cellImageView.clipsToBounds = YES;
    self.cellImageView.layer.allowsEdgeAntialiasing = YES;
}

- (void)setType:(TBCellType)type {
    switch (type) {
        case TBCellTypeTop: {
             self.imageViewTopConstraint.constant = 2;
             self.imageViewBottomContraint.constant = -4;
             break;
        }
        case TBCellTypeCommon: {
            self.imageViewTopConstraint.constant = -3;
            self.imageViewBottomContraint.constant = -4;
             break;
        }
        case TBCellTypeBottom: {
            self.imageViewTopConstraint.constant = -3;
            self.imageViewBottomContraint.constant = 1;
             break;
        }
        case TBCellTypeOnly: {
            self.imageViewTopConstraint.constant = 2;
            self.imageViewBottomContraint.constant = 1;
            break;
        }
            
        default:
            break;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    UIColor *imageViewBackgroundColor = self.cellImageView.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    self.cellImageView.backgroundColor = imageViewBackgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    UIColor *imageViewBackgroundColor = self.cellImageView.backgroundColor;
    [super setSelected:selected animated:animated];
    self.cellImageView.backgroundColor = imageViewBackgroundColor;
}

@end
