//
// Created by Zhang Zeqing on 25/7/13.
// Copyright (c) 2013 teambition. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIView+TBSnapshotView.h"

#define kWindowBgTag 1142

@implementation UIView (TBSnapshotView)

+ (UIImage *)windowBackgroundImage {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    UIGraphicsBeginImageContextWithOptions(screenRect.size, YES, 0);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates {
    return [self snapshotImageWithScale:1 afterScreenUpdates:afterUpdates];
}

- (UIImage *)snapshotImageWithScale:(CGFloat)scale afterScreenUpdates:(BOOL)afterUpdates {
    CGRect screenRect = self.bounds;

    UIGraphicsBeginImageContextWithOptions(screenRect.size, YES, 0);
    
    // render view
    CGFloat dx = screenRect.size.width * (1 - scale) * 0.5;
    CGFloat dy = screenRect.size.height * (1 - scale) * 0.5;
    [self drawViewHierarchyInRect:CGRectInset(screenRect, dx, dy) afterScreenUpdates:afterUpdates];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return resultImage;
}

- (UIImage*)snapshotViewAsImageForViewWithRect:(CGRect)rect
{
    CGRect screenRect = rect;
    UIGraphicsBeginImageContextWithOptions(screenRect.size, YES, 0);
    [self drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

@end