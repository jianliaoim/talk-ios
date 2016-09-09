//
//  TBImageTableViewCell.m
//  Talk
//
//  Created by teambition-ios on 15/1/6.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TBImageTableViewCell.h"
#import "UIColor+TBColor.h"
#import "NSString+Emoji.h"
#import "constants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TBUtility.h"
#import "TBUser.h"

@implementation TBImageTableViewCell

#define imageCellDefaultAddedHeight 10
#define imageLeftMargin 56
#define imageRightMargin 30

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    _mediaImageView.layer.masksToBounds = YES;
    _mediaImageView.layer.cornerRadius = 15;
}

-(void)setMessage:(TBMessage *)message andAttachment:(TBAttachment *)attachment {
    _message = message;
    _attachment = attachment;
    
    if (message.isSend) {
        self.mediaImageView.layer.borderColor = self.bubbleTintColor.CGColor;
        [self.bubbleBgBtn setTintColor:self.bubbleTintColor];
    }
    
    BOOL isFirstAttachment = message.attachments.firstObject == attachment ? YES : NO;
    if (message.messageStr.length > 0 ||!isFirstAttachment) {
        self.userAvatorImageView.hidden = YES;
    } else {
        self.userAvatorImageView.hidden = NO;
    }
    self.imageShadowView.hidden = self.userAvatorImageView.hidden;
    
    //avator
    [self.userAvatorImageView sd_setImageWithURL:message.creator.avatarURL placeholderImage:[UIImage imageNamed:@"avatar"] options:CACHE_POLICY];

    //userNameAndTime
    if (message.isSend) {
        //userNameAndTime and set resendBtn enable or not
        switch (message.sendStatus) {
            case sendStatusSucceed:{
                self.bubbleBgBtn.enabled = YES;
            }
                break;
            case sendStatusSending:{
                self.bubbleBgBtn.enabled = NO;
            }
                break;
            case sendStatusFailed:{
                self.bubbleBgBtn.enabled = YES;
            }
                break;
            default:
                break;
        }
    }
    
    //image size
    CGSize imageSize = [self imageSizeForAttachment:attachment];
    self.bubbleContainerWidthConstraint.constant = imageSize.width;
    self.bubbleContainerHeightConstraint.constant = imageSize.height;
}

- (CGSize)imageSizeForAttachment:(TBAttachment *)attachment {
    CGFloat imageHeight = [attachment.data[kImageHeight] floatValue];
    CGFloat imageWidth = [attachment.data[kImageWidth] floatValue];
    CGFloat imageMaxHeight = [[UIScreen mainScreen] bounds].size.width-imageLeftMargin - imageRightMargin;
    
    CGSize imageSize = [TBImageTableViewCell imageSizeWithImageWidth:imageWidth imageHeight:imageHeight imageMaxHeight:imageMaxHeight];
    return imageSize;
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

//tap to preview
- (IBAction)tapMediaBgBtn:(id)sender {
    if (self.message.sendStatus == sendStatusFailed) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kResendImageNotification object:self.message];
        return;
    }
    DDLogDebug(@"click other");
    [[NSNotificationCenter defaultCenter]postNotificationName:kTapOtherMedia object:self.attachment];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Class Methods

+ (CGSize)imageSizeWithImageWidth:(CGFloat)imageWidth imageHeight:(CGFloat)imageHeight imageMaxHeight:(CGFloat)imageMaxHeight {
    CGFloat heightConstraint;
    CGFloat widthConstraint;
    if (!imageWidth || !imageHeight) {
        heightConstraint = imageDefaultHeight;
        widthConstraint= imageDefaultHeight;
    } else {
        if (imageHeight  < imageMinHeight && imageWidth  < imageMinHeight ) {
            heightConstraint = imageMinHeight;
            widthConstraint= imageMinHeight;
        } else {
            CGFloat multiple = [TBImageTableViewCell imageZoomMultipleWithImageWidth:imageWidth imageHeight:imageHeight imageMaxHeight:imageMaxHeight];
            heightConstraint = imageHeight * multiple;
            widthConstraint= imageWidth *multiple;
            if (heightConstraint  < imageMinHeight) {
                heightConstraint = imageMinHeight;
            }
            if (widthConstraint  < imageMinHeight) {
                widthConstraint = imageMinHeight;
            }
        }
    }
    return CGSizeMake(widthConstraint, heightConstraint);
}

+ (CGFloat)imageZoomMultipleWithImageWidth:(CGFloat)imageWidth imageHeight:(CGFloat)imageHeight imageMaxHeight:(CGFloat)imageMaxHeight {
    CGFloat multiple;
    if (imageWidth <= imageHeight) {
        if (imageHeight > imageMaxHeight ) {
            multiple = imageMaxHeight/imageHeight;
        } else {
            multiple = 1;
        }
    } else {
        if (imageWidth > imageMaxHeight ) {
            multiple = imageMaxHeight/imageWidth;
        } else {
            multiple = 1;
        }
    }
    
    return multiple;
}

+ (CGFloat)calculateCellHeightWithMessage:(TBMessage *)model andAttachment:(TBAttachment *)attachment {
    CGFloat imageHeight,imageWidth;
    if (model.sendStatus == sendStatusSucceed) {
        if (!attachment.data[kImageHeight] || !attachment.data[kImageWidth]) {
            return imageCellDefaultAddedHeight + imageDefaultHeight;
        }
        imageHeight = [attachment.data[kImageHeight] floatValue];
        imageWidth = [attachment.data[kImageWidth] floatValue];
    } else {
        imageHeight = [attachment.data[kImageHeight] floatValue];
        imageWidth = [attachment.data[kImageWidth] floatValue];
    }
    
    CGFloat imageMaxHeight = [[UIScreen mainScreen] bounds].size.width-imageLeftMargin - imageRightMargin;
    CGFloat multiple = [TBImageTableViewCell imageZoomMultipleWithImageWidth:imageWidth imageHeight:imageHeight imageMaxHeight:imageMaxHeight];
    if (imageHeight *multiple < imageMinHeight ) {
        return imageCellDefaultAddedHeight + imageMinHeight;
    }
    if (imageWidth *multiple < imageMinHeight ) {
        return imageCellDefaultAddedHeight + imageHeight * multiple;
    }

    return imageCellDefaultAddedHeight + imageHeight * multiple;
}

@end
