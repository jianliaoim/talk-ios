//
//  TalkGuideView.m
//  Talk
//
//  Created by 史丹青 on 7/29/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "TalkGuideView.h"
#import "AppDelegate.h"

@implementation TalkGuideView

- (id)init {
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    if (self) {
        self.alpha = 0;
        [self commonInit];
        self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    }
    return self;
}

#pragma mark - IBAction

- (IBAction)dismiss:(UIButton *)sender {
    [self removeFromSuperview];
}

#pragma mark - Public

- (void)showWithTitle:(NSString *)title andSubtitle:(NSString *)subtitle andReminder:(NSString *)reminder {
    
    [self.title setText:title];
    [self.subtitle setText:subtitle];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:reminder];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    self.reminder.attributedText = text;

    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self];
    
    [UIView animateWithDuration:0.3 delay:0.5 usingSpringWithDamping:1 initialSpringVelocity:5 options:7<<16 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        DDLogDebug(@"finished");
    }];
}

#pragma mark - Private

- (void)commonInit {
    self.guideView.layer.masksToBounds = YES;
    self.guideView.layer.cornerRadius = 5;
}

@end
