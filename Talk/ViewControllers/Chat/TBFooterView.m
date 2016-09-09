
//  ZXLFooterView.m
//  Created by zhangxiaolian on 14-11-2.
//  Copyright (c) 2014年 zhangxiaolian. All rights reserved.
//

#import "TBFooterView.h"
#import "UIColor+TBColor.h"

@implementation TBFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _dotsView = [[TBDotsView alloc]initWithFrame:frame];
        _dotsView.backgroundColor = [UIColor tb_BackgroundColor];
        [self addSubview:_dotsView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
