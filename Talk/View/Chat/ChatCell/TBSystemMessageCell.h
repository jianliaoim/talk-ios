//
//  TBSystemMessageCell.h
//  Talk
//
//  Created by teambition-ios on 15/1/20.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBChatBaseCell.h"
#import "TBMessage.h"

@interface TBSystemMessageCell : TBChatBaseCell
@property(nonatomic,strong) TBMessage *message;
@property (weak, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (nonatomic,weak) IBOutlet  UILabel *messageContentLabel;

+ (CGFloat)calculateCellHeightWithMessage:(TBMessage *)message;
+(CGSize)getSizeWith:(TBMessage *)message;
@end
