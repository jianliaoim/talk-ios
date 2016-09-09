//
//  TBSearchQuoteCell.m
//  Talk
//
//  Created by Suric on 15/5/2.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TBSearchQuoteCell.h"
#import "TBUtility.h"
#import "MORoom.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "TBAttachment.h"
#import "UIColor+TBColor.h"

@implementation TBSearchQuoteCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(TBMessage *)model andAttachemnt:(TBAttachment *)attachment {
    [super setModel:model andAttachemnt:attachment];
    
    //link or text
    NSString *attachmentCategory = attachment.category;
    NSString *quoteCategory = attachment.data[kQuoteCategory];
    //message with attachment && quoteCategory is @"url"
    if ([attachmentCategory isEqualToString:kDisplayModeQuote] && [quoteCategory isEqualToString:kQuoteCategoryURL]) {
        //avatar
        self.avatarImageView.image = [UIImage imageNamed:@"icon-search-link"];
        
        NSString *contentString = [NSString stringWithFormat:@"  "];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:contentString];
        if (!model.highlight) {
            if (attachment.data[kQuoteTitle]) {
                [attributedString appendAttributedString:[[NSMutableAttributedString alloc]initWithString:attachment.data[kQuoteTitle]]];
            }
        } else {
            if ([model.highlight.allKeys containsObject:kHighlightKeyAttachmentTitle]) {
                [attributedString appendAttributedString:[TBUtility getHighlightStringFromMessageHighlightDictionary:model.highlight withKeyString:kHighlightKeyAttachmentTitle]];
            } else if ([model.highlight.allKeys containsObject:kHighlightKeyAttachmentText]) {
                [attributedString appendAttributedString:[TBUtility getHighlightStringFromMessageHighlightDictionary:model.highlight withKeyString:kHighlightKeyAttachmentText]];
            }
            else {
                if (attachment.data[kQuoteTitle]) {
                    [attributedString appendAttributedString:[[NSMutableAttributedString alloc]initWithString:attachment.data[kQuoteTitle]]];
                }
            }
        }
        
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIImage imageNamed:@"icon-url-link"];
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attributedString replaceCharactersInRange:NSMakeRange(0, 1) withAttributedString:attrStringWithImage];
        self.quoteLinkLabel.numberOfLines = 1;
        self.quoteLinkLabel.attributedText = attributedString;
    }
}

@end
