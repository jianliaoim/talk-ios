//
// Created by Zhang Zeqing on 9/1/14.
// Copyright (c) 2014 teambition. All rights reserved.
//

#import "TBSnoozeRevealAnimator.h"
#import "UIView+TBSnapshotView.h"
#import "UIImage+ImageEffects.h"
#import "ChangeTeamViewController.h"

@interface TBSnoozeRevealAnimator ()
@property(nonatomic, strong) UIView *overlayView;
@property (nonatomic) id <UIViewControllerContextTransitioning> context;
@end



@implementation TBSnoozeRevealAnimator

- (id)init {
    self = [super init];
    if (self) {
        // preference
        _blurRadius = 20.0f;

        self.overlayView = [[UIView alloc] init];
    }

    return self;
}


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.presenting) {
        return 0.25f;
    }
    return 0.2;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    self.context = transitionContext;

    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = transitionContext.containerView;
    
    // animation frame
    CGRect revealFrame = containerView.bounds;
    CGRect hiddenFrame = CGRectOffset(revealFrame,0, 0);
    CGRect dismissFrame = CGRectOffset(revealFrame,0,containerView.bounds.size.height);

    [fromViewController viewWillDisappear:YES];
    [toViewController viewWillAppear:YES];

    if (self.presenting) {
        // present
        fromViewController.view.userInteractionEnabled = NO;
        
        self.overlayView.frame = [transitionContext initialFrameForViewController:fromViewController];
        UIImage *cutImage = [fromViewController.view snapshotImageWithScale:1.00 afterScreenUpdates:NO];
        UIImage *effectImage = [cutImage tb_applyDarkEffect];
        self.overlayView.backgroundColor = [UIColor colorWithPatternImage:effectImage];
        self.overlayView.alpha = 0;

        toViewController.view.frame = hiddenFrame;
        toViewController.view.alpha = 0;
        toViewController.navigationController.navigationBar.alpha = 0;

        [containerView insertSubview:toViewController.view
                        aboveSubview:fromViewController.view];
        [containerView insertSubview:self.overlayView
                        aboveSubview:fromViewController.view];
        
        UINavigationController *teamsVCNav = (UINavigationController *)toViewController;
        ChangeTeamViewController *tempTeamsVC  = (ChangeTeamViewController *)[teamsVCNav.viewControllers objectAtIndex:0];
        CGRect shadowRect1 = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 20);
        tempTeamsVC.shadowImage = [UIImage imageWithImage:effectImage cropInRect:shadowRect1];
        
        // animation
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            //fromViewController.view.transform = CGAffineTransformMakeScale(0.95, 0.95);;
            //toViewController.view.frame = revealFrame;
            toViewController.view.alpha = 1.0f;
            self.overlayView.alpha = 1.0f;
            toViewController.navigationController.navigationBar.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [fromViewController.view removeFromSuperview];
            [fromViewController viewDidDisappear:YES];
            [toViewController viewDidAppear:YES];
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        // dismiss
        toViewController.view.userInteractionEnabled = YES;
        toViewController.view.transform = CGAffineTransformMakeScale(0.95, 0.95);
        fromViewController.view.alpha = 1.0f;

        [containerView insertSubview:toViewController.view
                        belowSubview:fromViewController.view];
        [containerView insertSubview:self.overlayView
                        belowSubview:fromViewController.view];

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
//                           fromViewController.view.alpha = 0;
                             self.overlayView.alpha = 0;
                             toViewController.view.transform = CGAffineTransformIdentity;
                             fromViewController.view.frame = dismissFrame;
                         }
                         completion:^(BOOL finished) {
                             [containerView addSubview:toViewController.view];
                             [transitionContext completeTransition:YES];
                             [fromViewController viewDidDisappear:YES];
                             [toViewController viewDidAppear:YES];
                         }];
    }
}



@end