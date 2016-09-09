//
//  TBImageTableViewCell.h
//  Talk
//
//  Created by teambition-ios on 15/1/6.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "TBChatBaseCell.h"
#import <FLAnimatedImageView.h>
#import "TBAttachment.h"

#define imageMinHeight 36
#define imageDefaultHeight 80

@interface TBImageTableViewCell : TBChatBaseCell
@property (weak, nonatomic) IBOutlet UIButton *bubbleBgBtn;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *mediaImageView; //message type image
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleContainerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bubbleContainerHeightConstraint;

@property(strong, nonatomic) TBMessage *message;
@property(strong, nonatomic) TBAttachment *attachment;
@property(strong, nonatomic) UIColor *bubbleTintColor;
@property (nonatomic) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic) UILongPressGestureRecognizer *avatarLongPressRecognizer;
@property (nonatomic) UITapGestureRecognizer *avatarGestureRecognizer;

-(void)setMessage:(TBMessage *)message andAttachment:(TBAttachment *)attachment;
+ (CGSize)imageSizeWithImageWidth:(CGFloat)imageWidth imageHeight:(CGFloat)imageHeight imageMaxHeight:(CGFloat)imageMaxHeight;
+ (CGFloat)calculateCellHeightWithMessage:(TBMessage *)model andAttachment:(TBAttachment *)attachment;
@end