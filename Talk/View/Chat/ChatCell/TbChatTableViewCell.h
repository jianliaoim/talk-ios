//
//  TbChatTableViewCell.h
//  Talk
//
//  Created by teambition-ios on 14/10/28.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "UIColor+TBColor.h"
#import "TBChatBaseCell.h"
#import "TBAttachment.h"
#import "TBMessage.h"

@protocol TbChatTableViewCellDelegate <NSObject>
- (void)checkReceiptForMessage:(TBMessage *)message;
@end

@interface TbChatTableViewCell : TBChatBaseCell
@property (weak, nonatomic) IBOutlet UILabel *userNameAndTimeLbl;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *messageContentLabel;

@property (assign, nonatomic) id <TbChatTableViewCellDelegate> receiptDelegate;
@property (strong, nonatomic) TBMessage *message;
@property (nonatomic) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic) UILongPressGestureRecognizer *avatarLongPressRecognizer;
@property (nonatomic) UITapGestureRecognizer *avatarGestureRecognizer;
@property (strong, nonatomic) UIColor *bubbleTintColor;
@property (nonatomic, assign) BOOL isMentionMessage;

+ (CGFloat)calculateCellHeightWithMessage:(TBMessage *)model;
+ (CGSize)getSizeWith:(NSString *)messageStr;
@end
