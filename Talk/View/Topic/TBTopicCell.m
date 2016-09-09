//
//  TBTopicCell.m
//  Talk
//
//  Created by Shire on 10/9/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBTopicCell.h"

@implementation TBTopicCell

- (void)awakeFromNib {
    // Initialization code
    UIImage *image = [[UIImage imageNamed:@"icon-topic"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.cellImageView setImage:image];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
