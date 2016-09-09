//
//  TBButton.m
//  Talk
//
//  Created by Suric on 15/3/30.
//  Copyright (c) 2015年 Teambition. All rights reserved.
//

#import "TBButton.h"
#import <Masonry/Masonry.h>

@interface TBButton()
@end

@implementation TBButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _loadingView.hidesWhenStopped = YES;
    [self addSubview:_loadingView];
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

- (void)startLoading {
    self.enabled = NO;
    [self setTitleColor:self.backgroundColor forState:UIControlStateNormal];
    [self bringSubviewToFront:_loadingView];
    [self.loadingView startAnimating];
}

- (void)stopLoading {
    self.enabled = YES;
    [self.loadingView stopAnimating];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (enabled) {
        self.alpha = 1.0;
    } else {
        self.alpha = 0.7;
    }
}

@end
