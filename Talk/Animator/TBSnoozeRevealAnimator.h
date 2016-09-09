//
// Created by Zhang Zeqing on 9/1/14.
// Copyright (c) 2014 teambition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TBSnoozeRevealAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property(nonatomic) CGFloat blurRadius;
@property(nonatomic) BOOL presenting;
@end