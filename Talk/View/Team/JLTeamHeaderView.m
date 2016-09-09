//
//  JLTeamHeaderView.m
//  Talk
//
//  Created by 王卫 on 16/1/13.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "JLTeamHeaderView.h"
#import "UIView+TBSnapshotView.h"
#import <Masonry.h>

@interface JLTeamHeaderView ()

@property (nonatomic) CGFloat initHeight;
@property (nonatomic, strong) NSLayoutConstraint *backgroundHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *backgroundTopConstraint;

@end

@implementation JLTeamHeaderView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.initHeight = CGRectGetHeight(frame);
        [self setupConstraints];
    }
    return self;
}

- (void)setupConstraints {
    [self addSubview:self.backgroudImageView];
    [self.backgroudImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
    }];
    self.backgroundHeightConstraint = [NSLayoutConstraint constraintWithItem:self.backgroudImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:self.initHeight];
    [self addConstraint:self.backgroundHeightConstraint];
    
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(64);
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(64);
        make.height.mas_equalTo(64);
    }];
    
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).with.offset(16);
        make.centerX.equalTo(self.mas_centerX);
    }];
}

- (void)setCurrentHeight:(CGFloat)currentHeight {
    _currentHeight = currentHeight;
    if (currentHeight > self.initHeight) {
        self.backgroundHeightConstraint.constant = currentHeight;
    } else if (currentHeight > 0) {
        self.imageView.alpha = 1 - (self.initHeight - currentHeight)/100;
    }
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.text = NSLocalizedString(@"Talk", @"Talk");
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar"]];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 32;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIImageView *)backgroudImageView {
    if (!_backgroudImageView) {
        _backgroudImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drawer-header"]];
        _backgroudImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _backgroudImageView;
}

@end
