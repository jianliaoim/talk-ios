//
//  TBInvitationCell.m
//  Talk
//
//  Created by 史丹青 on 9/16/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "TBInvitationCell.h"
#import "NSString+Emoji.h"
#import "UIColor+TBColor.h"

@implementation TBInvitationCell

- (void)awakeFromNib {
    // Initialization code
    [self.invitedLabel setText:NSLocalizedString(@"Invited member", @"Invited member")];
}

- (void)setupCellWithName:(NSString *)name {
    [self.nameLabel setText:name];
    self.avatarLabel.layer.cornerRadius = 20;
    self.avatarLabel.layer.masksToBounds = YES;
    [self.avatarLabel setBackgroundColor:[UIColor jl_redColor]];
    [self.avatarLabel setText:[NSString getFirstWordWithEmojiForString:name]];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *imageViewBackgroundColor = self.avatarLabel.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    self.avatarLabel.backgroundColor = imageViewBackgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *imageViewBackgroundColor = self.avatarLabel.backgroundColor;
    [super setSelected:selected animated:animated];
    self.avatarLabel.backgroundColor = imageViewBackgroundColor;
}

@end
