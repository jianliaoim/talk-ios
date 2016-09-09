//
//  TBTopicOpenCell.m
//  Talk
//
//  Created by teambition-ios on 15/2/5.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TBTopicOpenCell.h"

@implementation TBTopicOpenCell

- (void)awakeFromNib {
    // Initialization code
}

- (IBAction)openTopic:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(openTopicWith:)] || [self.delegate respondsToSelector:@selector(pinTopicWith:)] || [self.delegate respondsToSelector:@selector(muteTopicWith:)] || [self.delegate respondsToSelector:@selector(hideMobileWith:)]) {
        switch (self.switchType) {
            case TBTopicSwitchCellTypeOpen:
                [self.delegate openTopicWith:sender.on];
                break;
            case TBTopicSwitchCellTypePin:
                [self.delegate pinTopicWith:sender.on];
                break;
            case TBTopicSwitchCellTypeMute:
                [self.delegate muteTopicWith:sender.on];
                break;
            case TBTopicSwitchCellTypeHideMobile:
                [self.delegate hideMobileWith:sender.on];
                break;
                
            default:
                break;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
