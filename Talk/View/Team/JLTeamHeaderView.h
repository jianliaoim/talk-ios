//
//  JLTeamHeaderView.h
//  Talk
//
//  Created by 王卫 on 16/1/13.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLTeamHeaderView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *backgroudImageView;

@property (nonatomic, strong) UIImage *imageForNavigationBar;
@property (nonatomic) CGFloat currentHeight;

@end
