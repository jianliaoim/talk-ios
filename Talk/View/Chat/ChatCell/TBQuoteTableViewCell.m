//
//  TBQuoteTableViewCell.m
//  Talk
//
//  Created by teambition-ios on 14/11/18.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "TBQuoteTableViewCell.h"
#import "UIColor+TBColor.h"
#import "constants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "TBUtility.h"
#import <Haneke/UIImageView+Haneke.h>
#import "TBUser.h"

#define titleLableFont   17
#define contentLableFont   14
#define contentLableLineSpace  5
#define contentLabelLeftMargin 71
#define contentLabelRightMargin 45
#define sendContentLableRightMargin 25
#define quoteCellDeafaultHeight 145
#define quotecontentlabelDefaultHeight 17

@implementation TBQuoteTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _quoteAvatorImageView.layer.masksToBounds = YES;
    _quoteAvatorImageView.layer.cornerRadius = 12.0f;
    
    _quoteBubbleBgBtn.layer.masksToBounds = YES;
    _quoteBubbleBgBtn.layer.cornerRadius = 18.0f;
    _quoteBubbleBgBtn.layer.borderWidth = 1.0f;
}

- (void)setMessage:(TBMessage *)message  andAttachment:(TBAttachment *)attachment {
    _message = message;
    _attachment = attachment;
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
    [self.quoteBubbleBgBtn setTintColor:[UIColor whiteColor]];
    self.quoteBubbleBgBtn.layer.borderColor = [UIColor jl_redColor].CGColor;
    [self.quoteBubbleBgBtn setBackgroundColor:[UIColor clearColor]];
    self.bubbleContainer.backgroundColor = [UIColor whiteColor];
    //user avator
    NSURL *avatarURL = [TBUtility getCreatorAvatarURLForMessage:message];
    if (avatarURL) {
        [self.userAvatorImageView sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"avatar"] options:CACHE_POLICY];
    } else {
        [self.userAvatorImageView setImage:[UIImage imageNamed:@"avatar"]];
    }
    
    //update constraint
    NSString *quoteTitle = attachment.data[kQuoteTitle];
    NSString *quoteText = attachment.text;
    if (!quoteTitle || quoteTitle.length == 0) {
        self.quoteContentTopConstraint.constant = 8;
    }
    
    //quote title
    NSString *quoteCategory = attachment.data[kQuoteCategory];
    if ([quoteCategory isEqualToString:@"url"] ) {
        self.quoteTitleLabel.text = NSLocalizedString(@"Open in Teambition", @"Open in Teambition");
    } else {
        if (quoteTitle) {
            self.quoteTitleLabel.text = [TBUtility dealForNilWithString:quoteTitle];
        } else {
            self.quoteTitleLabel.text = nil;
        }
    }
    
    //quote content
    self.quoteContentLabel.text = [TBUtility dealForNilWithString:quoteText];

    //quote thumbnail Pic
    NSString *quoteUrlString = self.attachment.data[kQuoteThumbnailPicUrl];
    if (!quoteUrlString) {
        quoteUrlString =  attachment.data[kQuoteImageUrl];
    }
    if (quoteUrlString || self.message.captureImageUrlStr) {
        self.quoteAvatorImageView.hidden = NO;
        NSString *urlString = quoteUrlString;
        if (!urlString) {
            urlString = self.message.captureImageUrlStr;
        }
        [self.quoteAvatorImageView hnk_setImageFromURL:[NSURL URLWithString:urlString] placeholder:[UIImage imageNamed:@"photoDefault"] ];
    } else {
        self.quoteAvatorImageView.hidden = YES;
    }
}

- (IBAction)jumpToQuote:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(jumpToQuoteURLWithAttachment:)]) {
        [_delegate jumpToQuoteURLWithAttachment:self.attachment];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
