//
//  TBWeiboCell.m
//  Talk
//
//  Created by Suric on 15/4/21.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TBWeiboCell.h"
#import "UIColor+TBColor.h"
#import "constants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "TBUtility.h"
#import <Haneke/UIImageView+Haneke.h>
#import "TBAttachment.h"

#define titleLableFont   17
#define contentLableFont   14
#define contentLableLineSpace  5
#define contentLabelLeftMargin 71
#define contentLabelRightMargin 45
#define sendContentLableRightMargin 25
#define quoteCellDeafaultHeight 193
#define quotecontentlabelDefaultHeight 51
#define quoteImageViewDefaultHeight 85
#define quoteTitleDefalutHeight    21

@implementation TBWeiboCell

- (void)setMessage:(TBMessage *)message andAttachment:(TBAttachment *)attachment {
    [super setMessage:message andAttachment:(TBAttachment *)attachment];
    
    if (message.messageStr.length > 0) {
        self.userAvatorImageView.hidden = YES;
    } else {
        self.userAvatorImageView.hidden = NO;
    }
    self.imageShadowView.hidden = self.userAvatorImageView.hidden;
    
    NSString *quoteUrlString = self.attachment.data[kQuoteThumbnailPicUrl];
    if (!quoteUrlString) {
        quoteUrlString =  attachment.data[kQuoteImageUrl];
    }
    if (quoteUrlString || message.captureImageUrlStr) {
        self.quoteBubbleBottomConstraint.constant = 10 + quoteImageViewDefaultHeight;
    } else {
        self.quoteBubbleBottomConstraint.constant = 10;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - Class Methods

+ (CGFloat)calculateCellHeightWithMessage:(TBMessage *)model andAttachment:(TBAttachment *)attachment {
    CGFloat quoteTitleHeight = [TBWeiboCell getQuoteTitleSizeForAttachment:attachment].height;
    CGFloat quoteContentTitleHeight = [TBWeiboCell getContentTitleSizeForAttachment:attachment].height;
    
    CGFloat baseHeight = quoteCellDeafaultHeight - quotecontentlabelDefaultHeight - quoteTitleDefalutHeight;
    if (quoteTitleHeight == 0) {
        baseHeight = baseHeight - 5;
    }
    CGFloat cellHeight = baseHeight  + quoteContentTitleHeight + quoteTitleHeight - quoteImageViewDefaultHeight;
    if (attachment.data[kQuoteThumbnailPicUrl] || attachment.data[kQuoteImageUrl] || model.captureImageUrlStr.length > 0) {
        cellHeight = cellHeight + quoteImageViewDefaultHeight;
    }
    if (quoteTitleHeight == 0 && quoteContentTitleHeight == 0) {
        cellHeight = cellHeight + 10;
    }
    return cellHeight;
}

+ (CGSize)getContentTitleSizeForAttachment:(TBAttachment *)attachment {
    CGFloat contentViewWidth = [[UIScreen mainScreen] bounds].size.width - contentLabelRightMargin - contentLabelLeftMargin;
    CGSize tempsize = CGSizeMake(contentViewWidth,124);
    
    TTTAttributedLabel *temLabel = [[TTTAttributedLabel alloc]initWithFrame:CGRectZero];
    temLabel.numberOfLines  = 6;
    temLabel.font = [UIFont systemFontOfSize:contentLableFont];
    temLabel.lineBreakMode = NSLineBreakByWordWrapping;
    NSString *attachmentCategory = attachment.data[kQuoteCategory];
    if ([attachmentCategory isEqualToString:kDisplayModeGithub]) {
        NSString *noBrString = [attachment.data[kQuoteText] stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        temLabel.text = [TBUtility getStringWithoutHtmlFromString:noBrString];
    } else {
        temLabel.text = [TBUtility getStringWithoutHtmlFromString:attachment.data[kQuoteText]];
    }
    CGSize size = [temLabel sizeThatFits:tempsize];
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

+ (CGSize)getQuoteTitleSizeForAttachment:(TBAttachment *)attachment {
    CGFloat contentViewWidth = [[UIScreen mainScreen] bounds].size.width - contentLabelRightMargin - contentLabelLeftMargin;
    CGSize tempsize = CGSizeMake(contentViewWidth,50);
    
    UILabel *temLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    temLabel.numberOfLines = 2;
    temLabel.font = [UIFont boldSystemFontOfSize:titleLableFont];
    temLabel.lineBreakMode = NSLineBreakByWordWrapping;
    temLabel.text = attachment.data[kQuoteTitle];
    CGSize size = [temLabel sizeThatFits:tempsize];
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

+ (CGSize)getGithubContentSizeWithMessage:(TBMessage *)messageModel andAttachment:(TBAttachment *)attachment {
    CGFloat contentViewWidth = [[UIScreen mainScreen] bounds].size.width - contentLabelRightMargin - contentLabelLeftMargin;
    CGSize tempsize = CGSizeMake(contentViewWidth,62);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[attachment.data[kQuoteTitle] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSFontAttributeName: [UIFont systemFontOfSize:contentLableFont] } documentAttributes:nil error:nil];
    
    UILabel *temLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    temLabel.numberOfLines  = 3;
    temLabel.font = [UIFont systemFontOfSize:contentLableFont];
    temLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [temLabel setAttributedText:attributedString];
    CGSize needSize = [temLabel sizeThatFits:tempsize];
    return CGSizeMake(ceil(needSize.width), ceil(needSize.height));
}

@end
