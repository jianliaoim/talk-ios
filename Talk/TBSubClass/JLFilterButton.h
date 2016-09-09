//
//  JLFilterButton.h
//  Talk
//
//  Created by Suric on 16/2/17.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLFilterButton : UIButton
@property (strong, nonnull, nonatomic) UIImageView *directionImageView;
@property (strong, nonnull, nonatomic) UIView *seperatorLine;
- (void)setTitleColor:(nullable UIColor *)color forState:(UIControlState)state;
@end
