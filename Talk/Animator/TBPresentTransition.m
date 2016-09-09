//
//  TBPresentTransition.m
//  Talk
//
//  Created by teambition-ios on 14/12/8.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import "TBPresentTransition.h"

@implementation TBPresentTransition

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    UIVisualEffectView *overlayView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    overlayView.frame = containerView.frame;
    
    if (self.isPresenting) {
        
        //[fromVC viewWillDisappear:YES];
        
        [containerView addSubview:toVC.view];
        [containerView insertSubview:overlayView belowSubview:toVC.view];
        [toVC.view setAlpha:0];
        [overlayView setAlpha:0];
        
        CGRect toViewFrame = toVC.view.frame;
        toViewFrame.origin.y = containerView.frame.size.height;
        
        toVC.view.frame = toViewFrame;
        toViewFrame.origin.y = 0;
    
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 animations:^{
            [toVC.view setAlpha:1];
            [overlayView setAlpha:1];
            toVC.view.frame = toViewFrame;
            
            fromVC.view.transform =
            CGAffineTransformScale(fromVC.view.transform, 0.95f, 0.95f);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
//            [fromVC.view removeFromSuperview];
//            [fromVC viewDidDisappear:YES];
//            [toVC viewDidAppear:YES];
        }];
        
    }
    else {
        
        //[toVC viewWillDisappear:YES];
        
        [containerView addSubview:toVC.view];
        [containerView addSubview:fromVC.view];
        [containerView insertSubview:overlayView aboveSubview:toVC.view];
    
        CGRect fromViewFrame = fromVC.view.frame;
        fromViewFrame.origin.y = containerView.frame.size.height;
        [overlayView setAlpha:1];
    
        toVC.view.transform = CGAffineTransformScale(toVC.view.transform, 0.95f, 0.95f);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 animations:^{
            //[fromVC.view setAlpha:0.3];
            [overlayView setAlpha:0];
            
            fromVC.view.frame = fromViewFrame;
            toVC.view.transform =
            CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
            
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
//            [fromVC viewDidDisappear:YES];
//            [toVC viewDidAppear:YES];
        }];
    }
}

@end
