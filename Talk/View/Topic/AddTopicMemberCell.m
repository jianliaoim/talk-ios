//
//  AddTopicMemberCell.m
//  Talk
//
//  Created by Suric on 14/10/21.
//  Copyright (c) 2014年 jiaoliao. All rights reserved.
//

#import "AddTopicMemberCell.h"
#import "UIColor+TBColor.h"

@implementation AddTopicMemberCell

- (void)awakeFromNib {
    // Initialization code
    
    //next to lines is very important to reduce the UI jam
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    self.selectedImageView.layer.masksToBounds = YES;
    self.selectedImageView.layer.cornerRadius =self.selectedImageView.frame.size.height/2;
    self.selectedImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius =self.avatarImageView.frame.size.height/2;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
