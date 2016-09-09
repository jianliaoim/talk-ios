//
//  TBRecentCell.m
//  Talk
//
//  Created by Shire on 10/21/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import "TBRecentCell.h"
#import "NSDate+TBUtilities.h"
#import "TBUtility.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "TBNotification.h"
#import "TBUser.h"
#import "MONotification.h"
#import "MODraft.h"

static NSString * const BadgeFrame = @"frame";

@implementation TBRecentCell

- (void)awakeFromNib {
    // Initialization code
    //next to lines is very important to reduce the UI jam
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    _aImageView.layer.cornerRadius = _aImageView.bounds.size.height/2;
    _aImageView.layer.masksToBounds = YES;
    _aImageView.layer.allowsEdgeAntialiasing = YES;
    _muteImageView.hidden = YES;
    _unPinImageView.hidden = YES;
    
    CGFloat badgeHeight = 19.5;
    _badge = [[M13BadgeView alloc] initWithFrame:CGRectMake(0, 0, badgeHeight, badgeHeight)];
    _badge.cornerRadius = badgeHeight/2;
    _badge.font = [UIFont systemFontOfSize:12.0];
    _badge.badgeBackgroundColor = [UIColor jl_redColor];
    _badge.borderWidth = 3;
    _badge.borderColor = [UIColor whiteColor];
    _badge.hidden = YES;
    [_badgeSuperView addSubview:_badge];
    _badge.horizontalAlignment = M13BadgeViewHorizontalAlignmentRight;
    _badge.verticalAlignment = M13BadgeViewVerticalAlignmentBottom;
//    [_badge setAlignmentShift:CGSizeMake(-CGRectGetWidth(_badge.frame)/2, 0)];
    
    _unreadDotImageView.image = [UIImage imageNamed:@"icon-unread"];
    _unreadDotImageView.layer.cornerRadius = _unreadDotImageView.frame.size.width/2;
    _unreadDotImageView.layer.masksToBounds = YES;
    _unreadDotImageView.hidden = YES;
}

- (void)setIsPined:(BOOL)isPined {
    _isPined = isPined;
    if (isPined) {
        self.muteImageViewRightCOnstrait.constant = 34;
    } else {
        self.muteImageViewRightCOnstrait.constant = 4;
    }
}

- (void)setUnreadBadgeHidden:(BOOL)hidden {
    self.badge.hidden = hidden;
    self.titleLabel.textColor = [UIColor tb_otherFileColor];
    self.contentLabel.textColor = [UIColor tb_subTextColor];
}

- (void)setModel:(TBNotification *)model {
    //deal for unread
    self.unreadDotImageView.hidden = YES;
    if (model.unreadNum) {
        if (model.unreadNum.intValue > 0) {
            NSString *unreadNumber = [NSString stringWithFormat:@"%@",model.unreadNum];
            if (unreadNumber) {
                self.badge.text = unreadNumber;
                self.badge.alignmentShift = CGSizeMake(0, -6);
            }
            [self setUnreadBadgeHidden:NO];
            if (model.isMute) {
                self.badge.hidden = YES;
                self.unreadDotImageView.hidden = NO;
            }
        } else {
            [self setUnreadBadgeHidden:YES];
        }
    } else {
        [self setUnreadBadgeHidden:YES];
    }
    
    //deal for pin
    NSString *pinTitle;
    if (model.isPinned) {
        self.isPined = YES;
        self.unPinImageView.hidden = NO;
        self.backgroundColor = [UIColor tb_pinedCellbackgoundColor];
        pinTitle = NSLocalizedString(@"Unpin", @"Unpin");
    } else {
        self.isPined = NO;
        self.unPinImageView.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
        pinTitle = NSLocalizedString(@"Pin", @"Pin");
    }
    
    //deal for mute
    if (model.isMute) {
        self.muteImageView.hidden = NO;
    }
    else {
        self.muteImageView.hidden = YES;
    }

    //avatar
    if ([model.type isEqualToString:kNotificationTypeRoom]) {
        self.aImageView.tintColor = [UIColor jl_redColor];
        UIImage *image = [UIImage imageNamed:@"TopicLogo"];
        [self.aImageView setImage:image];
        }
    else if ([model.type isEqualToString:kNotificationTypeDMS]) {
        NSURL *avatarURL = [NSURL URLWithString:model.target[@"avatarUrl"]];
        [self.aImageView  sd_setImageWithPreviousCachedImageWithURL:avatarURL andPlaceholderImage:[UIImage imageNamed:@"avatar"] options:0 progress:nil completed:nil];
    } else {
        if ([model.target[@"category"] isEqualToString:kStoryCategoryFile]) {
            [self.aImageView setImage:[UIImage imageNamed:@"ImageStoryLogo"]];
        } else if ([model.target[@"category"] isEqualToString:kStoryCategoryLink]) {
            [self.aImageView setImage:[UIImage imageNamed:@"LinkStoryLogo"]];
        } else if ([model.target[@"category"] isEqualToString:kStoryCategoryTopic]) {
            [self.aImageView setImage:[UIImage imageNamed:@"TopicStoryLogo"]];
        }
        
    }
    
    //title
    if ([model.type isEqualToString:kNotificationTypeStory]) {
        self.titleLabel.text = model.target[@"title"];
    } else if ([model.type isEqualToString:kNotificationTypeRoom]) {
        BOOL isGeneral = [model.target[@"isGeneral"] boolValue];
        if (isGeneral) {
            self.titleLabel.text = NSLocalizedString(@"General", @"General");
        } else {
            self.titleLabel.text = model.target[@"topic"];
        }
    } else if ([model.type isEqualToString:kNotificationTypeDMS]) {
        self.titleLabel.text = model.creatorName;
    }
    
    
    //content Label
    MONotification *moNotification = [MONotification MR_findFirstByAttribute:@"id" withValue:model.id];
    if (moNotification.draft.content.length > 0) {
        self.contentLabel.attributedText = [self draftAttributedString:moNotification.draft.content];
    } else {
        self.contentLabel.text = [TBUtility getStringWithoutRegexFromString:model.text];
    }
    
    //time
    self.timeLabel.text = [model.updatedAt tb_timeAgo];;

    //deal for send message
    if (model.sendStatus.integerValue == sendStatusSending) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.contentLabel.text = [NSString stringWithFormat:@"⬅︎ %@", self.contentLabel.text];
    } else if  (model.sendStatus.integerValue == sendStatusFailed) {
        self.accessoryType = UITableViewCellAccessoryDetailButton;
        self.tintColor = [UIColor redColor];
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
//    if (model.message.id)
//    {
//        self.accessoryType = UITableViewCellAccessoryNone;
//    } else {
//        if (model.sendStatus.integerValue == sendStatusSending) {
//            self.accessoryType = UITableViewCellAccessoryNone;
//            self.contentLabel.text = [NSString stringWithFormat:@"⬅︎ %@", self.contentLabel.text];
//        } else {
//            self.accessoryType = UITableViewCellAccessoryDetailButton;
//            self.tintColor = [UIColor redColor];
//        }
//    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    UIColor *backgroundColor = self.badge.backgroundColor;
    UIColor *imageViewBackgroundColor = self.aImageView.backgroundColor;
    
    [super setHighlighted:highlighted animated:animated];
    self.badge.backgroundColor = backgroundColor;
    self.aImageView.backgroundColor = imageViewBackgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    UIColor *backgroundColor = self.badge.backgroundColor;
    UIColor *imageViewBackgroundColor = self.aImageView.backgroundColor;
    [super setSelected:selected animated:animated];
    self.badge.backgroundColor = backgroundColor;
    self.aImageView.backgroundColor = imageViewBackgroundColor;
}

- (NSAttributedString *)draftAttributedString:(NSString *)content {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    NSDictionary *notationAttributes = @{NSForegroundColorAttributeName:[UIColor redColor]};
    NSMutableAttributedString *notationString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@]",NSLocalizedString(@"Draft", @"draft")] attributes:notationAttributes];
    
    NSDictionary *contentAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:161/255.0
                                                                                        green:161/255.0
                                                                                         blue:161/255.0
                                                                                        alpha:1.0],
                                         NSFontAttributeName:[UIFont systemFontOfSize:12]};
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:content attributes:contentAttributes];
    [attributedString appendAttributedString:notationString];
    [attributedString appendAttributedString:contentString];
    
    return attributedString;
}

@end
