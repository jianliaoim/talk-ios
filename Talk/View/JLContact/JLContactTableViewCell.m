//
//  JLContactTableViewCell.m
//  Talk
//
//  Created by 王卫 on 15/11/4.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "JLContactTableViewCell.h"
#import "MOUser.h"
#import "TBUtility.h"

@interface JLContactTableViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;

@end

@implementation JLContactTableViewCell

- (void)awakeFromNib {
    //next to lines is very important to reduce the UI jam
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Initialization code
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.height/2;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.allowsEdgeAntialiasing = YES;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setCellPosition:(JLContactCellPosition)cellPosition {
    if (cellPosition == JLContactCellPositionTop) {
        self.topLayoutConstraint.constant = JLContactCellDefaultOffset * 2;
    } else {
        self.topLayoutConstraint.constant = JLContactCellDefaultOffset;
    }
}

@end
