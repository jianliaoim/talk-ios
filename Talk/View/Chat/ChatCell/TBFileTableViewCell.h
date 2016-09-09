//
//  TBFileTableViewCell.h
//  Talk
//
//  Created by teambition-ios on 15/1/4.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "TBChatBaseCell.h"
#import "TBAttachment.h"

@interface TBFileTableViewCell : TBChatBaseCell

@property (weak, nonatomic) IBOutlet UIButton *bubbleBgBtn;
@property (weak, nonatomic) IBOutlet UIImageView *mediaTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *mediaTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mediaNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mediaSizeLbl;

@property (strong, nonatomic) TBMessage *message;
@property (strong, nonatomic) TBAttachment *attachment;
@property (nonatomic) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic) UILongPressGestureRecognizer *avatarLongPressRecognizer;
@property (nonatomic) UITapGestureRecognizer *avatarGestureRecognizer;

-(void)setMessage:(TBMessage *)message andAttachment:(TBAttachment *)attachment;
+ (CGFloat)calculateCellHeight;

@end
