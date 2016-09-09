//
//  UITabBar+JLTabbar.m
//  Talk
//
//  Created by 史丹青 on 12/28/15.
//  Copyright © 2015 Teambition. All rights reserved.
//

#import "UITabBar+JLTabbar.h"

@implementation UITabBar (JLTabbar)

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.hidden || self.clipsToBounds || self.alpha == 0) {
        return nil;
    }
    for (UIView *subview in self.subviews.reverseObjectEnumerator) {
        CGPoint subPoint = [subview convertPoint:point fromView:self];
        UIView *resultView = [subview hitTest:subPoint withEvent:event];
        if (resultView) {
            return resultView;
        }
    }
    return nil;
}

@end
