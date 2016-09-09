//
//  TBRecentCell.h
//  Talk
//
//  Created by Shire on 10/21/14.
//  Copyright (c) 2014 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <M13BadgeView/M13BadgeView.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>
@class TBNotification;

@interface TBRecentCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UIImageView *aImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (copy, nonatomic) M13BadgeView *badge;
@property (weak, nonatomic) IBOutlet UIView *badgeSuperView;
@property (weak, nonatomic) IBOutlet UIImageView *unreadDotImageView;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *muteImageView;
@property (weak, nonatomic) IBOutlet UIImageView *unPinImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *muteImageViewRightCOnstrait;

@property (strong, nonatomic) TBNotification *model;
@property (nonatomic) BOOL isPined;

- (void)setUnreadBadgeHidden:(BOOL)hidden;

@end
