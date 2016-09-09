//
//  TBChatBaseCell.m
//  Talk
//
//  Created by Suric on 15/5/29.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TBChatBaseCell.h"
#import "UIColor+TBColor.h"
@implementation TBChatBaseCell

- (void)awakeFromNib {
    // Initialization code
    //next to lines is very important to reduce the UI jam
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    if (self.userAvatorImageView) {
        self.userAvatorImageView.layer.masksToBounds = YES;
        self.userAvatorImageView.layer.cornerRadius = CGRectGetHeight(self.userAvatorImageView.frame)/2;
        self.userAvatorImageView.userInteractionEnabled = YES;
    }
    
    CGFloat shadowRadius = 0.2f;
    if (self.imageShadowView) {
        self.imageShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.imageShadowView.layer.cornerRadius = CGRectGetHeight(self.userAvatorImageView.frame)/2;
        self.imageShadowView.layer.shadowOpacity = 0.2;
        self.imageShadowView.layer.shadowOffset = CGSizeMake(0, shadowRadius);
        self.imageShadowView.layer.shadowRadius = shadowRadius;
    }

    self.contentView.backgroundColor = [UIColor tb_BackgroundColor];
    self.bubbleContainer.backgroundColor = [UIColor tb_BackgroundColor];
    self.bubbleContainer.layer.cornerRadius = 18.0f;
    self.bubbleContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bubbleContainer.layer.shadowOpacity = 0.2;
    self.bubbleContainer.layer.shadowOffset = CGSizeMake(0, shadowRadius);
    self.bubbleContainer.layer.shadowRadius = shadowRadius;
    
    self.tagImg.hidden = YES;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)setShowMenu:(BOOL)showMenu {
    _showMenu = showMenu;
    if (showMenu) {
        CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.bubbleContainer.frame), CGRectGetHeight(self.bubbleContainer.frame));
        UIView *darkMask = [[UIView alloc] initWithFrame:frame];
        darkMask.backgroundColor = [UIColor blackColor];
        darkMask.alpha = 0.12f;
        self.bubbleContainer.clipsToBounds = YES;
        [self.bubbleContainer addSubview:darkMask];
    } else {
        UIView *maskView = self.bubbleContainer.subviews.lastObject;
        [maskView removeFromSuperview];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
