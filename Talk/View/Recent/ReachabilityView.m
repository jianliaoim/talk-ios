//
//  ReachabilityView.m
//  Talk
//
//  Created by 史丹青 on 8/20/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import "ReachabilityView.h"
#import "constants.h"

@implementation ReachabilityView

- (instancetype)initReachabilityView {
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, 32)];
    if (self) {
        self.reachabilityStatus = ReachabilityConnected;
        
        self.connectionStatusLabel = [[UILabel alloc] init];
        self.connectionStatusLabel.textColor = [UIColor whiteColor];
        self.connectionStatusLabel.font = [UIFont fontWithName:@"Heiti SC" size:15];
        [self addSubview:self.connectionStatusLabel];
        self.connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStatusLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.connectionStatusLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        
        self.refreshImageView = [[UIImageView alloc] init];
        [self.refreshImageView setImage:[UIImage imageNamed:@"network-refresh"]];
        [self addSubview:self.refreshImageView];
        [self setRefreshImageViewConstraint];
    }
    return self;
}

- (void) setRefreshImageViewConstraint {
    self.refreshImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.refreshImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.refreshImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.connectionStatusLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.refreshImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:12.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.refreshImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:12.0]];
}

#pragma mark - custom view

- (void)networkConnectedView {
    self.reachabilityStatus = ReachabilityConnected;
    [self.connectionStatusLabel setText:NSLocalizedString(@"Connected", @"Connected")];
    [self setBackgroundColor:[UIColor colorWithRed:156/255.f green:204/255.f blue:101/255.f alpha:1]];
    [self.refreshImageView.layer removeAllAnimations];
    [self.refreshImageView removeFromSuperview];
};

- (void)networkConnectingView {
    self.reachabilityStatus = ReachabilityConnecting;
    [self.connectionStatusLabel setText:NSLocalizedString(@"Connecting", @"Connecting")];
    [self setBackgroundColor:[UIColor colorWithRed:255/255.f green:185/255.f blue:9/255.f alpha:1]];
    
    [self addSubview:self.refreshImageView];
    [self setRefreshImageViewConstraint];
    [self connectingAnimation];
};

- (void)networkNotConnectedView {
    self.reachabilityStatus = ReachabilityUnconnected;
    [self.connectionStatusLabel setText:NSLocalizedString(@"No Internet connection", @"No Internet connection")];
    [self setBackgroundColor:[UIColor colorWithRed:255/255.f green:112/255.f blue:67/255.f alpha:1]];
    [self.refreshImageView.layer removeAllAnimations];
    [self.refreshImageView removeFromSuperview];
};

#pragma mark - Animation

- (void)connectingAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 1.0;
    animation.repeatCount = CGFLOAT_MAX;
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    [self.refreshImageView.layer addAnimation:animation forKey:@"rotate-layer"];
}

@end
