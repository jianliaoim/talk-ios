//
//  JLLoadingTableView.m
//  Talk
//
//  Created by 王卫 on 16/1/29.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import "JLLoadingTableView.h"
#import "TBDotsView.h"

@interface JLLoadingTableView ()

@end

@implementation JLLoadingTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.loadingView = [[TBDotsView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 44)];
    self.loadingView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2.0, self.center.y);
}

- (void)setLoadingView:(UIView<JLLoadingViewProtocol> *)loadingView {
    _loadingView = loadingView;
    [self addSubview:self.loadingView];
    [self.loadingView setHidden:YES];
}

- (void)startLoadingAnimation {
    [self.loadingView setHidden:NO];
    [self bringSubviewToFront:self.loadingView];
    if ([self.loadingView respondsToSelector:@selector(startAnimating)]) {
        [self.loadingView startAnimating];
    }
}

- (void)stopLoadingAnimation {
    if ([self.loadingView respondsToSelector:@selector(stopAnimating)]) {
        [self.loadingView stopAnimating];
    }
    [self.loadingView setHidden:YES];
}

@end
