//
// Created by Zhang Zeqing on 25/7/13.
// Copyright (c) 2013 teambition. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <UIKit/UIKit.h>

@interface UIView (TBSnapshotView)
+ (UIImage *)windowBackgroundImage;

- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;
- (UIImage *)snapshotImageWithScale:(CGFloat)scale afterScreenUpdates:(BOOL)afterUpdates;

- (UIImage*)snapshotViewAsImageForViewWithRect:(CGRect)rect;
@end