//
//  TalkSuggestionView.m
//  Talk
//
//  Created by 史丹青 on 7/31/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "TalkSuggestionView.h"
#import "AppDelegate.h"

@implementation TalkSuggestionView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    if (self) {
        self.alpha = 0;
        [self commonInit];
        self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    }
    return self;
}

#pragma mark - IBAction

- (IBAction)cancelButton:(UIButton *)sender {
    [self removeFromSuperview];
}

- (IBAction)doitButton:(UIButton *)sender {
    [self removeFromSuperview];
    [self.delegate suggestionMethod];
}

#pragma mark - Public

- (void)showWithTitle:(NSString *)title andSubtitle:(NSString *)subtitle andSuggestion:(NSString *)suggestion {
    
    [self.title setText:title];
    [self.subtitle setText:subtitle];
    [self.suggestion setText:suggestion];
    
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
    
    [self.cancelButton setTitle:NSLocalizedString(@"Skip", @"Skip") forState:UIControlStateNormal];
    [self.doitButton setTitle:NSLocalizedString(@"Link", @"Link") forState:UIControlStateNormal];
}

@end
