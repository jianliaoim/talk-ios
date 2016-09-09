//
//  MessageShelfButtonGuideView.m
//  Talk
//
//  Created by 史丹青 on 7/30/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "MessageShelfButtonGuideView.h"
#import "AppDelegate.h"

@implementation MessageShelfButtonGuideView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    if (self) {
        self.alpha = 0;
        [self addSingleGesture];
        self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    }
    return self;
}

- (void)show {
    self.title.text = NSLocalizedString(@"Items", @"Items");
    self.subtitle.text = NSLocalizedString(@"Message Shelf will save all your file, rich text and links.", @"Message Shelf will save all your file, rich text and links.");
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self];
    
    [UIView animateWithDuration:0.3 delay:0.5 usingSpringWithDamping:1 initialSpringVelocity:5 options:7<<16 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        DDLogDebug(@"successful");
    }];
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)addSingleGesture {
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    singleTapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTapGesture];
}

@end
