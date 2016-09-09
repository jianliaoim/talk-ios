//
//  TBContactCell.m
//  Talk
//
//  Created by 史丹青 on 6/26/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "TBContactCell.h"
#import "NSString+Emoji.h"
#import "UIColor+TBColor.h"

@implementation TBContactCell

- (void)awakeFromNib {
    // Initialization code
    self.contactNameAvator.layer.masksToBounds = YES;
    self.contactNameAvator.layer.cornerRadius = 20;
    self.contactAvator.layer.masksToBounds = YES;
    self.contactAvator.layer.cornerRadius = 20;
    self.contactInviteButton.tintColor = [UIColor jl_redColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupCellWithTBContact:(TBContact *)contact {
    [self.contactName setText:contact.name];
    if (contact.originPhone) {
        [self.contactPhone setText:contact.originPhone];
    } else {
        [self.contactPhone setText:contact.email];
    }
    if (contact.isInTeam) {
        [self.contactIsInTeam setHidden:NO];
        [self.contactInviteButton setHidden:YES];
    } else {
        [self.contactIsInTeam setHidden:YES];
        [self.contactInviteButton setHidden:NO];
        if (contact.isInvited) {
            [self.contactInviteButton setEnabled:NO];
            self.contactInviteButton.tintColor = [UIColor darkGrayColor];
        } else {
            [self.contactInviteButton setEnabled:YES];
            self.contactInviteButton.tintColor = [UIColor jl_redColor];
        }
    }
    if (contact.hasAvator) {
        [self.contactAvator setHidden:NO];
        [self.contactNameAvator setHidden:YES];
        [self.contactAvator setImage:contact.avator];
    } else {
        [self.contactAvator setHidden:YES];
        [self.contactNameAvator setHidden:NO];
        [self.contactNameAvator setBackgroundColor:[UIColor jl_redColor]];
        [self.contactNameAvator setText:[NSString getFirstWordWithEmojiForString:contact.name]];
    }
}

@end
