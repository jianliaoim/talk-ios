//
//  TBShareToCell.m
//  Talk
//
//  Created by teambition-ios on 15/3/17.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TBShareToCell.h"
#import "TBUser.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "constants.h"
#import "TBUtility.h"
#import <Hanzi2Pinyin/Hanzi2Pinyin.h>

@implementation TBShareToCell

- (void)awakeFromNib {
    // Initialization code
    //next to lines is very important to reduce the UI jam
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Initialization code
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.height/2;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.allowsEdgeAntialiasing = YES;
    
    self.searchTintColor = [UIColor jl_redColor];
}

-(void)setRoom:(MORoom *)room {
    _room = room;
    NSString *roomName = [TBUtility getTopicNameWithIsGeneral:room.isGeneralValue andTopicName:room.topic];
    
    self.avatarImageView.tintColor = [TBUtility getTopicRoomColorWith:room.color];
    UIImage *image;
    if (room.isPrivateValue) {
        image = [[UIImage imageNamed:@"icon-lock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        image = [[UIImage imageNamed:@"icon-topic"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    [self.avatarImageView setImage:image];
    
    if (!self.searchString) {
        self.nameLabel.text = roomName;
    } else {
        self.nameLabel.attributedText = [TBUtility highLightString:self.searchString inString:roomName];
    }
}

-(void)setUser:(MOUser *)user {
    NSString *targetUserAvatar = user.avatarURL;
    NSString *targetUserName = [TBUtility getFinalUserNameWithMOUser:user];
    
    NSURL *avatarURL = [NSURL URLWithString:targetUserAvatar];
    [self.avatarImageView sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    NSMutableAttributedString *nameAttrString = [[NSMutableAttributedString alloc] initWithString:targetUserName
                                                                                       attributes:@{ NSForegroundColorAttributeName : [UIColor tb_otherFileColor],
                                                                                                     NSFontAttributeName : [UIFont systemFontOfSize:17]
                                                                                                     }];
    if (!self.searchString) {
        self.nameLabel.attributedText = nameAttrString;
    } else {
        NSMutableAttributedString *nameAttributeString = [TBUtility highLightString:self.searchString inString:[nameAttrString string]];
        if (user.isQuitValue) {
            NSString *roleString = NSLocalizedString(@"・Left member", @"・Left member");
            NSAttributedString *roleAttrString = [[NSAttributedString alloc]
                                                  initWithString:roleString
                                                  attributes:@{
                                                               NSForegroundColorAttributeName : [UIColor tb_textGray],
                                                               NSFontAttributeName : [UIFont systemFontOfSize:14]
                                                               }];
            [nameAttributeString appendAttributedString:roleAttrString];
        }
        self.nameLabel.attributedText = nameAttributeString;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
