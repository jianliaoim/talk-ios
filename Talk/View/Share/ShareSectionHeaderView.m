//
//  ShareSectionHeaderView.m
//  Talk
//
//  Created by teambition-ios on 15/3/18.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "ShareSectionHeaderView.h"

@implementation ShareSectionHeaderView

- (void)awakeFromNib {
    CGFloat colorValue = 247.0 / 255.0;
    self.contentView.backgroundColor = [UIColor colorWithRed:colorValue green:colorValue blue:colorValue alpha:1.0];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
