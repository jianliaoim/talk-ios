//
//  JLSimpleStackView.m
//  Talk
//
//  Created by 王卫 on 15/11/13.
//  Copyright © 2015年 Teambition. All rights reserved.
//

#import "JLSimpleStackView.h"
#import <Masonry.h>

@interface JLSimpleStackView ()

@property (strong, nonatomic) NSMutableArray *subviews;

@end

@implementation JLSimpleStackView

- (void)scrollView:(UIScrollView *)scrollView layoutSubviews:(NSArray *)subviews inFrame:(CGRect)frame {
    
    for (UIView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    CGFloat textViewWidth = CGRectGetWidth(frame) - 2*15;
    CGFloat scrollViewContentHeight = 0;
    
    UIView *anchorView = nil;
    for (UIView *view in subviews) {
        [scrollView addSubview:view];
        
        CGFloat viewHeight = 0;
        CGFloat viewWidth = 0;
        if ([view isKindOfClass:[UITextView class]]) {
            CGSize sizeThatFitsTextView = [view sizeThatFits:CGSizeMake(textViewWidth, MAXFLOAT)];
            scrollViewContentHeight += (sizeThatFitsTextView.height + 15);
            viewWidth = textViewWidth;
            viewHeight = sizeThatFitsTextView.height;
        } else if ([view isKindOfClass:[UIImageView class]]) {
            UIImage *image = ((UIImageView *)view).image;
            CGFloat originalImageWidth = image.size.width > 0 ? image.size.width: 100;
            CGFloat originalImageHeight = image.size.height > 0 ? image.size.height: 100;
            viewWidth = MIN(originalImageWidth, (CGRectGetWidth(frame) - 2*15));
            viewHeight = originalImageHeight*(viewWidth/originalImageWidth);
            scrollViewContentHeight += (viewHeight + 10);
        } else {
            viewWidth = textViewWidth;
            viewHeight = 2*(1/[UIScreen mainScreen].scale);
            scrollViewContentHeight += (1+ 10);
        }
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            if (anchorView) {
                make.top.equalTo(anchorView.mas_bottom).with.offset(10);
            } else {
                make.top.equalTo(scrollView.mas_top).with.offset(15);
            }
            make.leading.equalTo(scrollView.mas_leading).with.offset(15);
            
            make.width.mas_equalTo(viewWidth);
            make.height.mas_equalTo(viewHeight);
        }];
        anchorView = view;
    }
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(frame), scrollViewContentHeight + 100);
}


@end
