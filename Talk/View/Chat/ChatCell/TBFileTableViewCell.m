//
//  TBFileTableViewCell.m
//  Talk
//
//  Created by teambition-ios on 15/1/4.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TBFileTableViewCell.h"
#import "UIColor+TBColor.h"
#import "NSString+Emoji.h"
#import "constants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TBUtility.h"
#import "TBAttachment.h"
#import "TBUser.h"

@implementation TBFileTableViewCell

#define fileCellDefaultHeight 71
#define fileContainerViewDefaultHeight 60

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)setMessage:(TBMessage *)message andAttachment:(TBAttachment *)attachment
{
    _message = message;
    _attachment = attachment;
    
    //avator
    [self.userAvatorImageView sd_setImageWithURL:self.message.creator.avatarURL placeholderImage:[UIImage imageNamed:@"avatar"] options:CACHE_POLICY];
    BOOL isFirstAttachment = message.attachments.firstObject == attachment ? YES : NO;
    if (message.messageStr.length > 0 || !isFirstAttachment) {
        self.userAvatorImageView.hidden = YES;
    } else {
        self.userAvatorImageView.hidden = NO;
    }
    self.imageShadowView.hidden = self.userAvatorImageView.hidden;
    
    //content
    NSString *fileName = attachment.data[kFileName];
    NSString *fileType = attachment.data[kFileType];
    NSString *fileSize = attachment.data[kFileSize];
    NSString *mediaSizeString = [NSString stringWithFormat:@"%@",[TBUtility convertBytes:fileSize.intValue]];
    UIImage *bubbleImage;
    CGFloat top= 18;
    CGFloat bottom= 18;
    CGFloat left = 18;
    CGFloat right = 18;
    bubbleImage = [UIImage imageNamed:@"icon-bubble-gray"];
    UIEdgeInsets imageInsets  = UIEdgeInsetsMake(top, left, bottom, right);
    bubbleImage  = [bubbleImage resizableImageWithCapInsets:imageInsets resizingMode:UIImageResizingModeStretch];
    bubbleImage = [bubbleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    if (message.isSend) {
//        [self.bubbleBgBtn setTintColor:[UIColor tb_lightDocColor]];
//    } else {
        [self.bubbleBgBtn setTintColor:[UIColor whiteColor]];
//    }
    self.bubbleBgBtn.layer.borderColor = [UIColor clearColor].CGColor;
    [self.bubbleBgBtn setBackgroundImage:bubbleImage forState:UIControlStateNormal];
    self.bubbleContainer.backgroundColor = [UIColor whiteColor];
    
    NSString *fileNameStr = fileName;
    [self.mediaTypeImageView setImage:[[UIImage imageNamed:@"icon-file-type"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    self.mediaTypeImageView.tintColor = [TBUtility fileColorWithType: fileType];
    [self.mediaTypeLabel setText:fileType];
        
    self.mediaNameLabel.text = fileNameStr;
    self.mediaSizeLbl.text = mediaSizeString;
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
- (IBAction)tapMediaBgBtn:(id)sender
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kTapOtherMedia object:self.attachment];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Class Methods

+ (CGFloat)calculateCellHeight
{
    return fileCellDefaultHeight;
}

@end
