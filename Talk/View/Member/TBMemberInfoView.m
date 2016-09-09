//
//  TBMemberInfoView.m
//  Talk
//
//  Created by 史丹青 on 9/25/15.
//  Copyright © 2015 Teambition. All rights reserved.
//

#import "TBMemberInfoView.h"
#import "Masonry.h"
#import "MOUser.h"
#import "UIImageView+WebCache.h"

@implementation TBMemberInfoView

- (void)awakeFromNib {
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.midButton.hidden = YES;
    self.dialogView.layer.masksToBounds = YES;
    self.dialogView.layer.cornerRadius = 5;
}

- (void)setCustomeView {
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.backgroundView addGestureRecognizer:singleTap];
    
    UIView *lineView = [[UIView alloc] init];
    [lineView setBackgroundColor:[UIColor colorWithRed:238/255.f green:238/255.f blue:238/255.f alpha:1]];
    [self.dialogView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.dialogView.mas_bottom).with.offset(-50);
        make.left.equalTo(self.dialogView.mas_left).offset(0);
        make.right.equalTo(self.dialogView.mas_right).offset(0);
        make.height.equalTo(@1);
    }];
    [lineView layoutIfNeeded];
    
    UIView *lineView2 = [[UIView alloc] init];
    [lineView2 setBackgroundColor:[UIColor colorWithRed:238/255.f green:238/255.f blue:238/255.f alpha:1]];
    [self.dialogView addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.dialogView.mas_bottom).with.offset(0);
        make.centerX.equalTo(self.dialogView.mas_centerX).offset(0);
        make.height.equalTo(@50);
        make.width.equalTo(@1);
    }];
    [lineView2 layoutIfNeeded];
}

#pragma mark - Public

- (void)displayOneButton {
    self.leftButton.hidden = YES;
    self.rightButton.hidden = YES;
    self.midButton.hidden = NO;
}

- (void)setViewWithUser:(MOUser *)user {
    [self.userAvator sd_setImageWithURL:[NSURL URLWithString:user.avatarURL] placeholderImage:[UIImage imageNamed:@"groupCall"]];
    self.userAvator.layer.masksToBounds = YES;
    self.userAvator.layer.cornerRadius = 40;
    [self.userName setText:user.name];
    if (user.phoneForLogin) {
        [self.userPhone setText:user.phoneForLogin];
    } else {
        [self.userPhone setText:@""];
    }
    if (user.email) {
        [self.userEmail setText:user.email];
    } else {
        [self.userEmail setText:@""];
    }
    [self setCustomeView];
}

#pragma mark - User Interaction

- (IBAction)clickLeft:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(clickLeftButtonInTBMemberInfoView)]) {
        [self.delegate clickLeftButtonInTBMemberInfoView];
    }
}

- (IBAction)clickRight:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(clickRightButtonInTBMemberInfoView)]) {
        [self.delegate clickRightButtonInTBMemberInfoView];
    }
}

- (IBAction)clickMidButton:(UIButton *)sender {
    [self removeFromSuperview];
}

- (void)backgroundTapped:(UITapGestureRecognizer*)recognizer {
    [self removeFromSuperview];
}

@end
