//
//  JLFilterScrollView.m
//  Talk
//
//  Created by Suric on 16/2/17.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "JLFilterScrollView.h"

@implementation JLFilterScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delaysContentTouches = NO;
    }
    
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:UIButton.class]) {
        return YES;
    }
    
    return [super touchesShouldCancelInContentView:view];
}
@end
