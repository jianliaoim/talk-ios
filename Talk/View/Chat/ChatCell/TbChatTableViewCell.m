//
//  TbChatTableViewCell.m
//  Talk
//
//  Created by teambition-ios on 14/10/28.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "TbChatTableViewCell.h"
#import "UIColor+TBColor.h"
#import "NSString+Emoji.h"
#import "constants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TBUtility.h"
#import "NSDate+TBUtilities.h"
#import "TBUser.h"

@implementation TbChatTableViewCell

#define cellDefaultHeight 47
#define contentViewDefaultHieght 65
#define messageContentLabelMinHeight 26
#define contentLableFont   16
#define messageContentLableLeftMargin 71
#define messageContentLableRightMargin 45
#define sendMessageContentLableRightMargin 25

- (void)awakeFromNib {
    [super awakeFromNib];
    self.messageContentLabel.enabledTextCheckingTypes = NSTextCheckingTypePhoneNumber|NSTextCheckingTypeLink;
    self.messageContentLabel.extendsLinkTouchArea = NO;
    self.bubbleImageView.userInteractionEnabled = YES;
}

-(void)setMessage:(TBMessage *)message
{
    _message = message;
    BOOL isSend = message.isSend;
    
    // link color settting
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableLinkAttributes setValue:(__bridge id)[self.bubbleTintColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    [mutableLinkAttributes setValue:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] forKey:(NSString *)kCTFontAttributeName];
    [mutableActiveLinkAttributes setValue:(__bridge id)[[UIColor lightGrayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    self.messageContentLabel.linkAttributes = mutableLinkAttributes;
    self.messageContentLabel.activeLinkAttributes = mutableActiveLinkAttributes;
    self.messageContentLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    //avator
    self.userAvatorImageView.hidden = NO;
    self.imageShadowView.hidden = NO;
    [self.userAvatorImageView sd_setImageWithURL:self.message.creator.avatarURL placeholderImage:[UIImage imageNamed:@"avatar"] options:CACHE_POLICY];
    //resend button
    if (isSend) {
        switch (message.sendStatus) {
            case sendStatusSucceed:
                [self.resendBtn setEnabled:NO];
                break;
            case sendStatusSending:
                [self.resendBtn setEnabled:NO];
                break;
            case sendStatusFailed:
                [self.resendBtn setEnabled:YES];
                break;
                
            default:
                break;
        }
    }
    //content
    UIImage *bubbleImage = [UIImage imageNamed:@"icon-bubble-gray"];
    UIEdgeInsets imageInsets  = UIEdgeInsetsMake(18, 18, 18, 18);
    bubbleImage  = [bubbleImage resizableImageWithCapInsets:imageInsets resizingMode:UIImageResizingModeStretch];
    bubbleImage = [bubbleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.bubbleImageView.tintColor = [UIColor whiteColor];
    self.bubbleImageView.image = bubbleImage;
    self.messageContentLabel.text = message.messageStr;
    if (self.isMentionMessage) {
        self.bubbleImageView.layer.masksToBounds = YES;
        self.bubbleImageView.layer.cornerRadius = 18;
        self.bubbleImageView.layer.borderWidth = 1;
        self.bubbleImageView.layer.borderColor = [UIColor jl_redColor].CGColor;
    } else {
        self.bubbleImageView.layer.borderWidth = 0;
    }
}

- (void)setLongPressRecognizer:(UILongPressGestureRecognizer *)newLongPressRecognizer {
    if (_longPressRecognizer != newLongPressRecognizer) {
        if (_longPressRecognizer != nil) {
            [self.bubbleContainer removeGestureRecognizer:_longPressRecognizer];
        }
        if (newLongPressRecognizer != nil) {
            [self.bubbleContainer addGestureRecognizer:newLongPressRecognizer];
        }
        
        _longPressRecognizer = newLongPressRecognizer;
    }
}

- (void)setAvatarLongPressRecognizer:(UILongPressGestureRecognizer *)avatarLongPressRecognizer {
    if (_avatarLongPressRecognizer != avatarLongPressRecognizer) {
        if (_avatarLongPressRecognizer != nil) {
            [self.userAvatorImageView removeGestureRecognizer:_avatarLongPressRecognizer];
        }
        if (avatarLongPressRecognizer != nil) {
            [self.userAvatorImageView addGestureRecognizer:avatarLongPressRecognizer];
        }
        
        _avatarLongPressRecognizer = avatarLongPressRecognizer;
    }
}

- (void)setAvatarGestureRecognizer:(UITapGestureRecognizer *)avatarGestureRecognizer {
    if (_avatarGestureRecognizer != avatarGestureRecognizer) {
        if (_avatarGestureRecognizer != nil) {
            [self.userAvatorImageView removeGestureRecognizer:_avatarGestureRecognizer];
        }
        if (avatarGestureRecognizer != nil) {
            [self.userAvatorImageView addGestureRecognizer:avatarGestureRecognizer];
        }
        
        _avatarGestureRecognizer = avatarGestureRecognizer;
    }
}

- (IBAction)resendMessage:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:kResendMessageNotification object:self.message];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - 

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.message.mentions.count > 0) {
        if ([self.receiptDelegate respondsToSelector:@selector(checkReceiptForMessage:)]) {
            [self.receiptDelegate checkReceiptForMessage:self.message];
        }
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

#pragma mark - Class Methods

+ (CGFloat)calculateCellHeightWithMessage:(TBMessage *)model {
    CGFloat height = [TbChatTableViewCell getSizeWith:model.messageStr].height;
    if (height <= messageContentLabelMinHeight) {
        return cellDefaultHeight;
    } else {
        return height + cellDefaultHeight - messageContentLabelMinHeight + 10;
    }
}

+ (CGSize)getSizeWith:(NSString *)messageStr {
    NSString *importStr = messageStr;
    CGFloat contentViewWidth = [[UIScreen mainScreen] bounds].size.width-messageContentLableLeftMargin - messageContentLableRightMargin;
    CGSize tempsize = CGSizeMake(contentViewWidth,CGFLOAT_MAX);
    
    TTTAttributedLabel *temLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectZero];
    temLabel.numberOfLines  = 0;
    temLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    temLabel.lineBreakMode = NSLineBreakByWordWrapping;
    temLabel.text = importStr;
    CGSize size = [temLabel sizeThatFits:tempsize];
    
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

@end
