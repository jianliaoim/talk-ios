//
//  TBDotsView.h
//  Talk
//
//  Created by Suric on 14/11/2.
//  Copyright (c) 2014年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLLoadingTableView.h"

@interface TBDotsView : UIView <JLLoadingViewProtocol>
@property(nonatomic,strong) UIColor *dotsColor;
-(instancetype)initWithFrame:(CGRect)frame;
-(void)startAnimating;
-(void)stopAnimating;
@end
