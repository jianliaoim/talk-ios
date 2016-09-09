//
//  JLSwitchButtonCell.m
//  Talk
//
//  Created by 史丹青 on 1/27/16.
//  Copyright © 2016 Teambition. All rights reserved.
//

#import "JLSwitchButtonCell.h"
#import "UIColor+TBColor.h"

@implementation JLSwitchButtonCell

- (void)awakeFromNib {
    // Initialization code
    self.switchButton.onTintColor = [UIColor jl_redColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)switchAction:(UISwitch *)sender {
    if ([self.delegate respondsToSelector:@selector(switchButtonTo:for:)]) {
        if (sender.on) {
            [self.delegate switchButtonTo:YES for:self.switchFor];
        } else {
            [self.delegate switchButtonTo:NO for:self.switchFor];
        }
    }
}

- (void)setCellTitle:(NSString *)title {
    [self.titleLabel setText:title];
}

@end
