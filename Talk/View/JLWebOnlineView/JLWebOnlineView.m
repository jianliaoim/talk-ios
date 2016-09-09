//
//  JLWebOnlineView.m
//  Talk
//
//  Created by Suric on 16/2/23.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "JLWebOnlineView.h"
#import "constants.h"

static CGFloat const defaultHeight = 40;

@implementation JLWebOnlineView

- (id)init {
    self = [[[NSBundle mainBundle]loadNibNamed:@"JLWebOnlineView" owner:self options:nil] lastObject];
    if (self) {
        self.frame = CGRectMake(0, 0, kScreenWidth, defaultHeight);
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1].CGColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = CGRectMake(0, 0, kScreenWidth, defaultHeight);
}

@end
