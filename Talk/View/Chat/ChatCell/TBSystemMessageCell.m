//
//  TBSystemMessageCell.m
//  Talk
//
//  Created by teambition-ios on 15/1/20.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TBSystemMessageCell.h"
#import "TBUtility.h"

@implementation TBSystemMessageCell

#define cellDefaultHeight 42
#define contentLableFont   12
#define contentLableLineSpace 3
#define messageContentLableLeftMargin 69

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setMessage:(TBMessage *)message
{
    //content
    UIImage *bubbleImage;
    CGFloat top = 13;
    bubbleImage = [UIImage imageNamed:@"icon-system-bubble"];
    UIEdgeInsets imageInsets  = UIEdgeInsetsMake(top, top, top, top);
    bubbleImage  = [bubbleImage resizableImageWithCapInsets:imageInsets resizingMode:UIImageResizingModeStretch];
    bubbleImage = [bubbleImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.bubbleImageView.tintColor = [[UIColor blackColor] colorWithAlphaComponent:0.08];
    self.bubbleImageView.image = bubbleImage;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setLineSpacing:contentLableLineSpace];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:contentLableFont], NSParagraphStyleAttributeName : paragraphStyle ,NSForegroundColorAttributeName : [UIColor colorWithRed:170.0/255.0 green:170.0/255.0  blue:170.0/255.0  alpha:1.0]};
    NSString *userName = [TBUtility getCreatorNameForMessage:message];
    NSAttributedString *contentAttrabuteStr = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@  %@",userName,message.messageStr] attributes:attributes];
    [self.messageContentLabel setAttributedText:contentAttrabuteStr];
}

+ (CGFloat)calculateCellHeightWithMessage:(TBMessage *)model
{
    CGFloat quoteContentHeight = [TBSystemMessageCell getSizeWith:model].height;
    if (quoteContentHeight >=29) {
        return cellDefaultHeight - 19 + quoteContentHeight;
    }
    else
    {
        return cellDefaultHeight;
    }
}


+(CGSize)getSizeWith:(TBMessage *)message
{
    NSString *userName = [TBUtility getCreatorNameForMessage:message];
    NSString *importStr = [NSString stringWithFormat:@"%@  %@",userName,message.messageStr];
    if (!importStr) {
        importStr = @"";
    }
    
    return [TBUtility getSizeWith:importStr andMargin:messageContentLableLeftMargin andLineSpace:contentLableLineSpace andFont:contentLableFont];
}

@end
