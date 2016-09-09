//
//  TBSearchTextCell.h
//  Talk
//
//  Created by Suric on 15/4/29.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBAttachment.h"
#import <MGSwipeTableCell/MGSwipeTableCell.h>

@interface TBSearchMessageCell : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet UILabel *creatorNamelabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *fileButton;
@property (weak, nonatomic) IBOutlet UILabel *messageContent;
@property (weak, nonatomic) IBOutlet UILabel *quoteLinkLabel;
@property (weak, nonatomic) IBOutlet UIView *seperator;

@property (strong, nonatomic) NSString *currentSearchString;
@property (strong, nonatomic) TBMessage *model;
@property (strong, nonatomic) TBAttachment *attachment;
@property (nonatomic) UILongPressGestureRecognizer *longPressRecognizer;

- (void)setModel:(TBMessage *)model andAttachemnt:(TBAttachment *)attachment;
+ (CGFloat)calculateCellHeightWithMessage:(TBMessage *)model;

@end
