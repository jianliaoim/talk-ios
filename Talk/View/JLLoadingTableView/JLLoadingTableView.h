//
//  JLLoadingTableView.h
//  Talk
//
//  Created by 王卫 on 16/1/29.
//  Copyright © 2016年 Teambition. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JLLoadingViewProtocol <NSObject>

- (void)startAnimating;
- (void)stopAnimating;

@end

@interface JLLoadingTableView : UITableView

@property (strong, nonatomic) UIView<JLLoadingViewProtocol> *loadingView;

- (void)startLoadingAnimation;
- (void)stopLoadingAnimation;

@end
