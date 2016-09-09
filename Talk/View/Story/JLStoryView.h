//
//  JLStoryView.h
//  Talk
//
//  Created by 王卫 on 15/11/9.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLStoryEditorViewController.h"

@class MOStory;

@interface JLStoryView : UIScrollView <JLStoryEditorViewControllerDelegate>

@property (weak, nonatomic) UIViewController *parentViewController;

- (instancetype)initWithFrame:(CGRect)frame story:(MOStory *)story;
- (CGFloat)heightForContentViewWithStory:(MOStory *)story;
- (void)shrink:(id)sender;

@end
