//
//  TBQuoteTableViewCell.h
//  Talk
//
//  Created by teambition-ios on 14/11/18.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "TBChatBaseCell.h"
#import "TBAttachment.h"

@protocol TBQuoteTableViewCellDelegate <NSObject>

-(void)jumpToQuoteURLWithAttachment:(TBAttachment *)attachment;

@end

@interface TBQuoteTableViewCell : TBChatBaseCell<TTTAttributedLabelDelegate>
//qute bubble releated
@property (weak, nonatomic) IBOutlet UIButton *quoteBubbleBgBtn;
@property (weak, nonatomic) IBOutlet UIImageView *quoteAvatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *quoteTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *quoteContentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quoteContentTopConstraint;

@property (strong, nonatomic) TBMessage *message;
@property (strong, nonatomic) TBAttachment *attachment;
@property (assign, nonatomic) id <TBQuoteTableViewCellDelegate> delegate;
@property (strong, nonatomic) UIColor *bubbleTintColor;

@property (nonatomic) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic) UILongPressGestureRecognizer *avatarLongPressRecognizer;
@property (nonatomic) UITapGestureRecognizer *avatarGestureRecognizer;

- (void)setMessage:(TBMessage *)message  andAttachment:(TBAttachment *)attachment;

@end
