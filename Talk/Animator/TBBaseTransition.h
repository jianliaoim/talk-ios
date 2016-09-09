//
//  TBBaseTransition.h
//  Talk
//
//  Created by teambition-ios on 14/12/8.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TBBaseTransition : NSObject <UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning>

@property(nonatomic,readwrite,assign,getter = isPresenting) BOOL presenting;

@end
