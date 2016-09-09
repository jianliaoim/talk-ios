//
//  TBWeiboCell.h
//  Talk
//
//  Created by Suric on 15/4/21.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBQuoteTableViewCell.h"
#import "TBAttachment.h"

@interface TBWeiboCell : TBQuoteTableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quoteBubbleBottomConstraint;
+ (CGFloat)calculateCellHeightWithMessage:(TBMessage *)model andAttachment:(TBAttachment *)attachment;
@end
