//
//  PlaceHolderView.m
//  Talk
//
//  Created by Suric on 15/6/18.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "PlaceHolderView.h"

@implementation PlaceHolderView

//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    [super drawRect:rect];
//    //no data placeHolder
//}

- (void)setPlaceHolderWithImage:(UIImage *)img andTitle:(NSString *)title andReminder:(NSString *)reminder {
    [self.noContentImage setImage:img];
    self.noContentLabel.text = title;
    self.reminderLabel.text = reminder;
}

@end
