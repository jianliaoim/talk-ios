//
//  TBAttachementMessageCell.m
//  Talk
//
//  Created by Suric on 15/9/25.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "TBAttachementMessageCell.h"
#import "TBUtility.h"

#define cellDefaultHeight 72
#define messageContentLabelMinHeight 20
#define messageContentLableLeftMargin 117
#define messageContentLableRightMargin 45
#define sendMessageContentLableRightMargin 25
#define contentLableFont   14.0

@implementation TBAttachementMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.messageLabel.enabledTextCheckingTypes = NSTextCheckingTypePhoneNumber|NSTextCheckingTypeLink;
    _bubbleButton.layer.masksToBounds = YES;
    _bubbleButton.layer.cornerRadius = 18.0f;
    _bubbleButton.layer.borderWidth = 1.0f;
}

- (void)setMessage:(TBMessage *)message  andAttachment:(TBAttachment *)attachment {
    _message = message;
    _attachment = attachment;
    // link color settting
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableLinkAttributes setValue:(__bridge id)[[UIColor jl_redColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    [mutableActiveLinkAttributes setValue:(__bridge id)[[UIColor lightGrayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    self.messageLabel.linkAttributes = mutableLinkAttributes;
    self.messageLabel.activeLinkAttributes = mutableActiveLinkAttributes;
    
    //bubble image
    UIImage *bubbleImage;
    CGFloat top = 18;
    CGFloat bottom = 18;
    CGFloat left = 18;
    CGFloat right = 18;
    bubbleImage = [UIImage imageNamed:@"icon-bubble-gray"];
    UIEdgeInsets imageInsets  = UIEdgeInsetsMake(top, left, bottom, right);
    bubbleImage  = [bubbleImage resizableImageWithCapInsets:imageInsets resizingMode:UIImageResizingModeStretch];
    bubbleImage = [bubbleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    if (message.isSend) {
//        [self.bubbleButton setTintColor:[UIColor tb_lightDocColor]];
//    } else {
//    }
    [self.bubbleButton setTintColor:[UIColor whiteColor]];
    self.bubbleButton.layer.borderColor = [UIColor jl_redColor].CGColor;
    [self.bubbleButton setBackgroundImage:bubbleImage forState:UIControlStateNormal];
    //avator
    NSString *avatarString = attachment.data[@"creator"][@"avatarUrl"];
    [self.userAvatorImageView sd_setImageWithURL:[NSURL URLWithString:avatarString] placeholderImage:[UIImage imageNamed:@"avatar"] options:CACHE_POLICY];
    //creator name
    NSString *creatorName = attachment.data[@"creator"][@"name"];
    self.creatorNameLabel.text = creatorName;
    //message
    self.messageLabel.text = [TBUtility parseTBMessageContentWithTBMessage:attachment.data[kMessageBody]];
}

#pragma IBActions

- (IBAction)jumpToTopic:(id)sender {
    NSString *roomID = self.attachment.data[@"room"][@"_id"];
    if ([self.delegate respondsToSelector:@selector(enterRoomWithId:)]) {
        [self.delegate enterRoomWithId:roomID];
    }
}

#pragma mark - Class Methods

+ (CGFloat)calculateCellHeightForAttachment:(TBAttachment *)attachment {
    NSString *messageString = [TBUtility parseTBMessageContentWithTBMessage:attachment.data[kMessageBody]];
    CGFloat height = [TBAttachementMessageCell getSizeWith:messageString].height;
    if (height <= messageContentLabelMinHeight) {
        return cellDefaultHeight;
    } else {
        return height + cellDefaultHeight - messageContentLabelMinHeight;
    }
}

+ (CGSize)getSizeWith:(NSString *)messageStr {
    NSString *importStr = messageStr;
    CGFloat contentViewWidth = [[UIScreen mainScreen] bounds].size.width-messageContentLableLeftMargin - messageContentLableRightMargin;
    CGSize tempsize = CGSizeMake(contentViewWidth,CGFLOAT_MAX);
    TTTAttributedLabel *temLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectZero];
    temLabel.numberOfLines  = 0;
    temLabel.font = [UIFont systemFontOfSize:contentLableFont];
    temLabel.lineBreakMode = NSLineBreakByWordWrapping;
    temLabel.text = importStr;
    CGSize size = [temLabel sizeThatFits:tempsize];
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

@end
