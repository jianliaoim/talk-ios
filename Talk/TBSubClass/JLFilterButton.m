//
//  JLFilterButton.m
//  Talk
//
//  Created by Suric on 16/2/17.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "JLFilterButton.h"
#import <Masonry/Masonry.h>
#import "UIColor+TBColor.h"

@interface JLFilterButton()
@end

@implementation JLFilterButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIImage *directionImage = [[UIImage imageNamed:@"icon-unread-arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _directionImageView = [[UIImageView alloc]initWithImage:directionImage];
    _directionImageView.tintColor = self.currentTitleColor;
    _directionImageView.userInteractionEnabled = NO;
    [self insertSubview:_directionImageView atIndex:0];
    [self sendSubviewToBack:_directionImageView];
    
    [_directionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).with.offset(0);
    }];
    
    _seperatorLine = [[UIView alloc]init];
    _seperatorLine.userInteractionEnabled = YES;
    _seperatorLine.backgroundColor = [UIColor tb_tableViewSeperatorColor];
    [self addSubview:_seperatorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.top.equalTo(self.mas_top).with.offset(10);
        make.bottom.equalTo(self.mas_bottom).with.offset(-10);
        make.right.equalTo(self.mas_right);
        make.width.mas_equalTo(@1.0);
    }];
}

- (void)setTitleColor:(nullable UIColor *)color forState:(UIControlState)state {
    [super setTitleColor:color forState:UIControlStateNormal];
    self.directionImageView.tintColor = color;
}

@end
