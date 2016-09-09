//
//  ReachabilityView.h
//  Talk
//
//  Created by 史丹青 on 8/20/15.
//  Copyright (c) 2015 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ReachabilityConnected = 0,
    ReachabilityConnecting,
    ReachabilityUnconnected,
} ReachabilityStatus;

@interface ReachabilityView : UIView

@property (nonatomic, strong) UILabel *connectionStatusLabel;
@property (nonatomic, strong) UIImageView *refreshImageView;
@property (nonatomic) ReachabilityStatus reachabilityStatus;

- (instancetype)initReachabilityView;

- (void)networkConnectedView;
- (void)networkConnectingView;
- (void)networkNotConnectedView;

@end
